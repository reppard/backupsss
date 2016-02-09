module Backupsss
  # A class for managing the properties need for creating, uploading, and
  # cleaning up backups in S3.
  class Configuration
    def self.keys
      [
        :s3_bucket,
        :s3_bucket_key,
        :backup_src_dir,
        :backup_frequency,
        :aws_region
      ]
    end

    attr_accessor(*keys)
  end
end
