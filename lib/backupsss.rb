require "backupsss/version"

# Authentication
# from ENV vars, file (~/.aws/credentials) or instance profile  handled by sdk

# S3_BUCKET
# S3_BUCKET_KEY
# BACKUP_SRC
# BACKUP FREQUENCY
# BACKUP RETENTION threshold
# Remote file cleanup
# Local file cleanup
# Backupsss.new(:s3_bucket => 'foo', :s3_bucket_key => 'bar')
# class Backupsss
#   def initialize(args = {})
#      @config = Configuration.new(args)
#   end
#
#   def task
#     // call out to tar
#   end
#
#   def run
#     scheduler.cron @config.backup_frequency do
#       begin
#         task
#       rescue Exception => e
#         $stdout.puts "IT SHIT THE h
#       end
#     end
#   end
# end

module Backupsss
  # Your code goes here...
end
