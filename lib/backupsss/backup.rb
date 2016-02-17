module Backupsss
  # A class for delivering a tar to S3
  class Backup
    attr_reader :config, :client, :tar

    def initialize(config, client, tar)
      @config = config
      @client = client
      @tar    = tar
    end

    def put_tar
      client.put_object(bucket_opts.merge(body: make_tar))
      wait_for_object
    end

    private

    def wait_for_object
      client.wait_until(:object_exists, bucket_opts) do |w|
        w.before_attempt { |n| display_checked_count_message(n) }
        w.before_wait    { |_, resp| display_before_wait_message(resp) }
      end
    end

    def display_checked_count_message(count)
      puts "Checked S3 #{count} times"
    end

    def display_before_wait_message(resp)
      puts "Client got: #{resp}\nwaiting before trying again"
    end

    def bucket_opts
      {
        bucket: config.s3_bucket,
        key: "#{config.s3_bucket_key}/#{tar.filename}"
      }
    end

    def make_tar
      tar.make
    end
  end
end
