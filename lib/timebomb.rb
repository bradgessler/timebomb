require "timebomb/version"
require "yaml"
require "thor"
require "chronic"

module Timebomb
  # class CLI < Thor::CLI
  # end

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

  class Timebomb
    attr_accessor :title, :date, :notes

    def parse_data(data)
      frontmatter = Frontmatter.new(data)
      self.title = frontmatter.data.fetch("title")
      self.date = frontmatter.data.fetch("date")
      self.notes = frontmatter.body
      self
    end

    def parse_file(path)
      parse_data File.read(path)
    end

    def date=(date)
      @date = date.is_a?(String) ? Chronic.parse(date) : date
    end

    def has_exploded?(current_time: Timebomb.current_time)
      self.date > current_time
    end
  end

  class Suite
    def load_files(paths)
      paths.each do |path|
        self.timebombs << Timebomb.new.parse_file(path)
      end
    end

    def has_exploded?(**args)
      timebombs.any? { |bomb| bomb.has_exploded?(**args) }
    end

    def timebombs
      @timebombs ||= []
    end
  end

  # Override this if you want to use a different current time.
  def self.current_time
    Time.now
  end
end
