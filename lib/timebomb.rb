require "timebomb/version"
require "yaml"
require "thor"
require "chronic"
require "pathname"
require "fileutils"

module Timebomb
  class CLI < Thor
    include FileUtils

    DEFAULT_PATH = Pathname.new("./timebomb").freeze
    DEFAULT_PATTERN = DEFAULT_PATH.join("**/**.tb").freeze
    DEFAULT_DATE_FROM_NOW = "1 month from today".freeze

    default_task :report

    desc "report PATH", "run a report for timebombs in PATH"
    def report(path = DEFAULT_PATTERN)
      suite = Suite.new
      suite.load_files Dir.glob(path)
      report = CLIReport.new suite
      report.print $stdout
      exit suite.has_exploded? ? 1 : 0
    end

    desc "init PATH", "initialize timebomb in project at PATH"
    def init(path = ".")
      path = Pathname.new(path).join(DEFAULT_PATH)
      mkdir path
      puts "Timebomb project initialized at #{path}"
    end

    desc "create", "create a new timebomb"
    long_desc <<-LONGDESC
      `timebomb create` will create a `*.tb` file in the #{DEFAULT_PATH} directory.

      A title is required via the `-t` flag. It should be a brief
      sentence that gives the person in the future something actionable to do when
      the timebomb blows up. More details and context can be provided in the description.

      A date is required so the timebomb explodes on the given future date. The date is
      parsed by a natrual language parser, so you can give absolute dates or relative dates
      like:

      > $ timebomb create -d "2 months from now" -t "Remove the feature"

      > $ timebomb create -d "next year" -t "Remove the feature"

      > $ timebomb create -d "tomorrow" -t "Remove the feature"

      Absolute dates can be given too such as:

      > $ timebomb create -d "Jan 14 2050" -t "Remove the feature"

      > $ timebomb create -d "Sunday, June 13 at 7pm" -t "Remove the feature"

      > $ timebomb create -d "2013-08-01T19:30:00.34-07:00" -t "Remove the feature"

      You can optionally specify an extended description via the `-m` flag. The description
      is meant to have all of the detail and context for why a timebomb was created and
      what should be removed when it blows up.

      > $ timebomb create -t "Remove the feature" -d "2 months from now" -m "Delete the Foo and Bar class"

      Would create the file #{DEFAULT_PATH.join("remove_the_feature.tb")}
    LONGDESC
    option :title, required: true, aliases: :t
    option :date, aliases: :d, default: DEFAULT_DATE_FROM_NOW
    option :description, aliases: :m
    def create
      path = DEFAULT_PATH.join tb_file(options[:title])
      file = BombFile.new(path)
      file.bomb.tap do |b|
        b.title = options[:title]
        b.description = options[:description]
        b.date = options[:date]
      end
      file.write
      puts "Timebomb created at #{path}"
    end

    desc "bump", "bumps all exploded timebombs to specified date"
    option :date, aliases: :d, default: DEFAULT_DATE_FROM_NOW
    def bump(path = DEFAULT_PATTERN)
      date = options[:date]
      suite = Suite.new
      suite.load_files Dir.glob(path)
      suite.timebomb_files.each do |file|
        file.read
        if file.bomb.has_exploded?
          file.bomb.date = date
          file.write
          puts "Bumped #{file.path} to #{date}"
        end
      end
    end

    private
      def underscore(title)
        title.downcase.split(/\W/).reject{ |word| word == "" || word.nil? }.join("_")
      end

      def tb_file(title)
        "#{underscore(title)}.tb"
      end
  end

  class CLIReport
    RED_COLOR_CODE = 31
    EXPLODED_CHARACTER = "💥"
    UNEXPLODED_CHARACTER = "💣"

    attr_reader :suite

    def initialize(suite)
      @suite = suite
    end

    def print(out)
      out.puts "Detected #{suite.timebombs.count} timebombs"
      suite.timebombs.each do |tb|
        out.puts row " #{explosion_symbol(tb)} ", format_date(tb.date), days_until(tb), tb.title
      end
      if suite.has_exploded?
        out.puts "#{suite.exploded_timebombs.count} timebombs have exploded!"
      end
    end

    private
      def row(*columns)
        columns.join("\t")
      end

      def days_until(tb)
        days = tb.days_difference
        if days < 0
          "Exploded #{-days.to_i} days ago"
        else
          "Explodes in #{days.to_i} days"
        end
      end

      def explosion_symbol(tb)
        tb.has_exploded? ? EXPLODED_CHARACTER : UNEXPLODED_CHARACTER
      end

      def format_date(date)
        date.strftime "%b %e, %Y"
      end
  end

  class Frontmatter
    DELIMITER = "---".freeze
    NEWLINE = /\r\n?|\n/.freeze
    PATTERN = /\A(#{DELIMITER}#{NEWLINE}(.+?)#{NEWLINE}#{DELIMITER}#{NEWLINE}*)?(.+)\Z/m

    attr_reader :body

    def initialize(content)
      _, @data, @body = content.match(PATTERN).captures
    end

    def data
      @data ? YAML.load(@data) : {}
    end
  end

  # Handles reading and writing to a Timebomb file `*.tb`.
  class BombFile
    EXTENSION = ".tb".freeze

    attr_reader :path, :bomb

    def initialize(path)
      @path = Pathname.new(path)
      @bomb = Bomb.new
    end

    def read
      File.open(path, 'r') do |file|
        data = file.read
        frontmatter = Frontmatter.new(data)
        bomb.title = frontmatter.data.fetch("title")
        bomb.date = frontmatter.data.fetch("date")
        bomb.description = frontmatter.body
      end
    end

    def write
      data = { "title" => bomb.title, "date" => bomb.date }

      File.open(path, 'w') do |file|
        file.puts data.to_yaml
        file.puts "---"
        file.puts
        file.puts bomb.description
      end
    end
  end

  class Bomb
    SECONDS_IN_DAY = 86400

    attr_accessor :title, :date, :description

    def date=(date)
      @date = date.is_a?(String) ? Chronic.parse(date) : date
    end

    def has_exploded?
      date < Timebomb.current_time
    end

    def days_difference
      (date - Timebomb.current_time) / SECONDS_IN_DAY
    end
  end

  class Suite
    def load_files(paths)
      paths.each do |path|
        self.timebomb_files << BombFile.new(path)
      end
    end

    def has_exploded?
      exploded_timebombs.any?
    end

    def exploded_timebombs
      timebombs.lazy.select(&:has_exploded?)
    end

    def unexploded_timebombs
      timebombs.lazy.reject(&:has_exploded?)
    end

    def timebombs
      timebomb_files.map do |file|
        file.read
        file.bomb
      end
    end

    def timebomb_files
      @timebomb_files ||= []
    end
  end

  # Override this if you want to use a different current time.
  def self.current_time
    Time.now
  end
end
