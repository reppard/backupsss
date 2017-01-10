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
      # http://docs.aws.amazon.com/AmazonS3/latest/dev/UploadingObjects.html
      #
      # > "We encourage Amazon S3 customers to use Multipart Upload for objects
      # > greater than 100 MB."
      #
      # MAX_FILE_SIZE = 104857600 # 100MB
      # if file.size > MAX_FILE_SIZE
      #   part_offset = 0
      #   part_number = 1
      #   part = file.read(MAX_FILE_SIZE, part_offset)
      #
      #   Fork.new {
      #     s3.upload_part({
			#       body:        part,
			#       bucket:      bucket,
			#       key:         key,
			#       part_number: current_part,
			#       upload_id:   mpu_create_response.upload_id,
			#     })
      #   }
      #   part_number = part_number + 1
      #   part_offset = part_offset + s3_limit
      # else
      # ... do put_object
      # end
      if file.size > 104857600 #100MB
        client.create_multipart_upload(bucket_opts)
      else
        client.put_object(bucket_opts.merge(body: file))
      end
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
