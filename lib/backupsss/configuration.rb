module Backupsss
  class Configuration
    def self.keys
      [
        :s3_bucket,
        :s3_bucket_key,
        :backup_src_dir,
        :backup_frequency
      ]
    end

    attr_accessor(*keys)
  end
end
