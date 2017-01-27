module Backupsss
  # A class for delivering a tar to S3
  class Backup
    MAX_FILE_SIZE = 1024 * 1024 * 100 # 100MB

    attr_reader :config, :client, :filename

    def initialize(config, client)
      @config   = config
      @client   = client
      @filename = config[:filename]
    end

    def put_file(file)
      large_file(file) ? multi_upload(file) : single_upload(file)
    end

    private

    def create_multipart_upload
      $stdout.puts 'Creating a multipart upload'

      client.create_multipart_upload(bucket_opts)
    end

    def large_file(file)
      file.size > MAX_FILE_SIZE
    end

    def complete_multipart_upload_request(upload_id, parts)
      bucket_opts.merge(
        upload_id: upload_id,
        multipart_upload: { parts: parts }
      )
    end

    def multi_upload(file)
      upload_id = create_multipart_upload.upload_id

      client.complete_multipart_upload(
        bucket_opts.merge(
          upload_id: multipart_resp.upload_id
        )
      )
    end

    def upload_parts(file, upload_id)
      (1..part_count(file)).inject([]) do |responses, part|
        r = client.upload_part(
          upload_part_params(file, part, upload_id)
        )
        r.on_success { $stdout.puts "Successfully uploaded part #{part}" }
        responses << r
      end
    end

    def upload_part_params(file, part, upload_id)
      bucket_opts.merge(
        part_number: part,
        body: file.read(MAX_FILE_SIZE),
        upload_id: upload_id
      )
    end

    def part_count(file)
      c = (file.size.to_f / MAX_FILE_SIZE.to_f).ceil
      $stdout.puts "Uploading backup as #{c} parts"

      c
    end

    def single_upload(file)
      client.put_object(bucket_opts.merge(body: file.read))
    end

    def bucket_opts
      {
        bucket: config[:s3_bucket],
        key:    "#{config[:s3_bucket_prefix]}/#{filename}"
      }
    end
  end
end
