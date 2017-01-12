require 'spec_helper'
require 'backupsss/backup'
require 'aws-sdk'

describe Backupsss::Backup, :ignore_stdout do
  let(:filename)    { 'somekey.tar' }
  let(:key)         { "some_prefix/#{filename}" }
  let(:client)      { Aws::S3::Client.new(stub_responses: true) }
  let(:backup)      { Backupsss::Backup.new(config_hash, client) }
  let(:filesize)    { 0 }
  let(:bucket_opts) { { bucket: 'some_bucket', key: key } }
  let(:sm)          { 1024 * 1024 * 100 }
  let(:lg)          { 1024 * 1024 * 150 }
  let(:max_size)    { 104_857_600 }
  let(:config_hash) do
    {
      s3_bucket_prefix: 'some_prefix',
      s3_bucket: 'some_bucket',
      filename: filename
    }
  end

  let(:file) { instance_double('File', read: 'foo', size: filesize) }

  describe '#put_file' do
    context 'with a file smaller than 100 MB' do
      before         { client.stub_responses(:put_object) }
      let(:filesize) { sm }

      subject { backup.put_file(file) }
      it      { is_expected.to be_a(Seahorse::Client::Response) }

      context 'on successful upload' do
        subject { backup.put_file(file).successful? }
        it      { is_expected.to be_truthy }
      end

      context 'on failed upload' do
        before  { client.stub_responses(:put_object, Timeout::Error) }
        subject { -> { backup.put_file(file) } }
        it      { is_expected.to raise_error(Timeout::Error) }
      end
    end

    context 'with a file bigger than 100 MB' do
      let(:filesize) { lg }

      subject        { backup.put_file(file) }
      it             { is_expected.to be_a(Seahorse::Client::Response) }

      context 'on successful upload' do
        let(:upload_part_responses) do
          [
            { etag: rand(100_000).to_s },
            { etag: rand(100_000).to_s }
          ]
        end

        let(:create_upload_response) do
          { upload_id: rand(100_000).to_s }
        end

        let(:complete_multipart_upload_response) do
          {
            bucket: bucket_opts[:bucket],
            key:    bucket_opts[:key]
          }
        end

        before do
          client.stub_responses(:upload_part, upload_part_responses)
          client.stub_responses(
            :create_multipart_upload,
            create_upload_response
          )
          client.stub_responses(
            :complete_multipart_upload, complete_multipart_upload_response
          )
        end

        subject { backup.put_file(file).successful? }
        it      { is_expected.to be_truthy }

        it 'returns a completed multipart upload' do
          expect(backup.put_file(file).bucket).to eq(bucket_opts[:bucket])
        end

        context 'stdout' do
          subject { -> { backup.put_file(file) } }
          let(:msg) do
            "Successfully uploaded part 1\nSuccessfully uploaded part 2\n"
          end
          it { is_expected.to output(msg).to_stdout }
        end
      end
    end
  end
end
