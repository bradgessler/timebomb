require "chronic"

module Timebomb
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
end