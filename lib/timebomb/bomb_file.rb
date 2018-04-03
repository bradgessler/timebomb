require "yaml"
require "pathname"

module Timebomb
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
end