# Backupsss

[![Gem Version](https://badge.fury.io/rb/capistrano-scm-jenkins.svg)](https://badge.fury.io/rb/capistrano-scm-jenkins)
[![Circle CI](https://circleci.com/gh/manheim/backupsss.svg?style=svg)](https://circleci.com/gh/manheim/backupsss)
[![Code Climate](https://codeclimate.com/github/manheim/backupsss/badges/gpa.svg)](https://codeclimate.com/github/manheim/backupsss)
[![Test Coverage](https://codeclimate.com/github/manheim/backupsss/badges/coverage.svg)](https://codeclimate.com/github/manheim/backupsss/coverage)

Tar a thing and put it in S3.

Backup any file or directory as a tar and push the tar to a specificed
S3 bucket.

## Installation

Install it like:

```shell

    $ gem install backupsss

```

## Usage

```shell

  $ S3_BUCKET=bucket_name \
    S3_BUCKET_KEY=bucket_key \
    BACKUP_SRC_DIR=/path/to/data \
    BACKUP_DEST_DIR=/backups \
    BACKUP_FREQ="*/30 * * * *" \
    AWS_REGION=us-east-1 \
    REMOTE_RETENTION=2 backupsss

```

## Development

After checking out the repo, run `bundle install --path vendor/bundle` to
install dependencies. Then, run `bundle exec rake spec` to run the tests.
You can also run `bundle exec guard` for an interactive prompt that will allow
you to experiment as well as run rspec and style checker when you save files.

To install this gem onto your local machine, run `bundle exec rake install`.
To release a new version, update the version number in `version.rb`, and then
run `bundle exec rake release`, which will create a git tag for the version,
push git commits and tags, and push the `.gem` file to [rubygems.org][rubygems].

## Contributing

Bug reports and pull requests are welcome on
GitHub at https://github.com/manheim/backupsss.

## License

The gem is available as open source under the terms of the [MIT License][MIT].

[rubygems]: https://rubygems.org
[MIT]: http://opensource.org/licenses/MIT

