require 'aws-sdk'

module Backupsss
  # A class for listing and sorting files in an s3 bucket
  class BackupBucket
    attr_reader :dir, :region

    def initialize(opts = {})
      @dir    = opts[:dir]
      @region = opts[:region]
    end

    def s3_client
      Aws::S3::Client.new(region: region)
    end

    def bucket
      dir.split('/').first
    end

    def key
      dir.split('/').drop(1).join
    end

    def ls
      list_objects.map(&:key)
    end

    def ls_t
      list_objects.sort_by { |o| o.last_modified }.map(&:key)
    end

    def ls_rt
      ls_t.reverse
    end

    private

    def list_objects
      s3_client.list_objects(bucket: bucket, prefix: key).contents
    end
  end
end
