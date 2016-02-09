module Backupsss
  # Backupsss::Backup
  class Backup
    attr_accessor :config, :client

    def initialize(config, client, tar)
      @config = config
      @client = client
      @tar    = tar
    end

    def make_tar
      @tar.make
    end

    def put_tar
      @client.put_object(
        bucket: @config.s3_bucket,
        key:    @config.s3_bucket_key,
        body:   make_tar
      )
    end
  end
end
