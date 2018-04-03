module Timebomb
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
end