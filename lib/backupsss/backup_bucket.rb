require 'aws-sdk'

module Backupsss
  # A class for listing and sorting files in an s3 bucket
  class BackupBucket
    attr_reader :dir, :region

    def initialize(opts = {})
      @dir    = opts[:dir]
      @region = opts[:region]
    end

    def ls
      list_objects.map(&:key)
    end

    def ls_t
      list_objects.sort_by(&:last_modified).map(&:key)
    end

    def ls_rt
      ls_t.reverse
    end

    def rm(file)
      s3_client.delete_object(bucket: bucket, key: file)
      file
    end

    private

    def list_objects
      s3_client.list_objects(bucket: bucket, prefix: prefix).contents
    end

    def s3_client
      Aws::S3::Client.new(region: region)
    end

    def bucket
      dir.split('/').first
    end

    def prefix
      dir.split('/').drop(1).join('/')
    end
  end
end
