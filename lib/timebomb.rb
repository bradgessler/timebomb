require "timebomb/version"

module Timebomb
  autoload :Bomb,         "timebomb/bomb"
  autoload :BombFile,     "timebomb/bomb_file"
  autoload :CLI,          "timebomb/cli"
  autoload :CLIReport,    "timebomb/cli_report"
  autoload :Frontmatter,  "timebomb/frontmatter"
  autoload :Suite,        "timebomb/suite"

  # Override this if you want to use a different current time.
  def self.current_time
    Time.now
  end
end
