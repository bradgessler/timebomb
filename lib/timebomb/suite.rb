module Timebomb
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
end