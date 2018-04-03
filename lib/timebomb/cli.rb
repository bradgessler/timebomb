require "thor"
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
end