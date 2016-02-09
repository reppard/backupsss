module Backupsss
  # Backupsss::Backup
  class Backup
    attr_accessor :config, :client

    def initialize(config, client, tar)
      @config = config
      @client = client
      @tar    = tar
    end

    def put_tar
      file = make_tar
      @client.put_object(bucket_opts.merge(body: file))
      @client.wait_until(:object_exists, bucket_opts) do |w|
        w.before_attempt { |n| puts "Checked S3 #{n} times" }

        w.before_wait do |_, resp|
          puts "Client got: #{resp}"
          puts 'waiting before trying again'
        end
      end
    end

    private

    def bucket_opts
      { bucket: @config.s3_bucket, key: @config.s3_bucket_key }
    end

    def make_tar
      @tar.make
    end
  end
end
