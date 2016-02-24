module Backupsss
  # A class for delivering a tar to S3
  class Backup
    attr_reader :config, :client, :filename

    def initialize(config, client)
      @config       = config
      @client       = client
      @filename = config[:filename]
    end

    def put_file(file)
      client.put_object(bucket_opts.merge(body: file))
    end

    private

    def bucket_opts
      {
        bucket: config[:s3_bucket],
        key:    "#{config[:s3_bucket_prefix]}/#{filename}"
      }
    end
  end
end
