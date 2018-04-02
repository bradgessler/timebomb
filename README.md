# Timebomb

[![Build Status](https://travis-ci.org/bradgessler/timebomb.svg?branch=master)](https://travis-ci.org/bradgessler/timebomb) [![Maintainability](https://api.codeclimate.com/v1/badges/ca9b943b703e7023e6a5/maintainability)](https://codeclimate.com/github/bradgessler/timebomb/maintainability)

Timebomb is a way for development teams to set reminders to remove or do things in their codebase by a certain date. Its best run in a CI server so that it "blows up" when a date is reached.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'timebomb'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install timebomb

## Usage

First, initialize Timebomb in your project by running:

    $ timebomb init .

Then create your first timebomb test:

    $ timebomb create --title "Remove the old feature" --date "2 months from now"

This creates a file at `./timebombs/remove_the_old_feature.tb` which you can edit to add more context:

```
---
title: Remove the old feature
date: 2018-06-16 00:00:00.000000000 -07:00
---

We're running an experiment on this feature. The metrics team said if we don't get 1,000 users in 2 months we should just pull it.
```

To check to see if any of the timebombs went off, run:

    $ timebomb report

If one went off, `timebomb` will return with a non-zero error code and details on the exceeded thresholds. If nothing went off then it will exit with 0. This is what you'd run on a CI server job.

If a bomb goes off, you can bump it by running:

    $ timebomb bump -d "2 weeks from now"

and it will automatically bump any timebombs that have exploded by the amount you've specified.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/bradgessler/timebomb. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Timebomb project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/bradgessler/timebomb/blob/master/CODE_OF_CONDUCT.md).
