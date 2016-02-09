module Backupsss
  # A class for managing the properties need for creating, uploading, and
  # cleaning up backups in S3.
  class Configuration
    def self.defaults
      {
        s3_bucket:      ENV['S3_BUCKET'],
        s3_bucket_key:  ENV['S3_BUCKET_KEY'],
        backup_src_dir: ENV['BACKUP_SRC_DIR'],
        backup_freq:    ENV['BACKUP_FREQ'],
        aws_region:     ENV['AWS_REGION']
      }
    end

    attr_accessor(*defaults.keys)

    def initialize(opts = {})
      attrs.each do |k, _|
        instance_variable_set("@#{k}", attrs.merge(opts)[k])
      end
    end

    def attrs
      self.class.defaults
    end
  end
end
