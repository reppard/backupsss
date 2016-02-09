require 'aws-sdk'
require 'backupsss/tar'
require 'rufus-scheduler'
require 'backupsss/backup'
require 'backupsss/version'
require 'backupsss/configuration'

# A utility for backing things up to S3.
module Backupsss
  def self.run
    @config = Backupsss::Configuration.new
    @client = Aws::S3::Client.new(region: @config.aws_region)

    start_scheduler
  end

  def self.call
    @tar = Backupsss::Tar.new(
      @config.backup_src_dir,
      "#{@config.backup_dest_dir}/#{Time.now.to_i}.tar"
    )
    @backup = Backupsss::Backup.new(@config, @client, @tar)

    puts 'Create and Upload Tar: Starting'
    @backup.put_tar
    puts 'Create and Upload Tar: Finished'
  end

  def self.start_scheduler
    scheduler = Rufus::Scheduler.new
    scheduler.cron @config.backup_freq do
      call
    end
    scheduler.join
  end
end
