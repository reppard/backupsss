require 'spec_helper'
require 'backupsss/backup'

describe Backupsss::Backup do
  let(:filename) { 'somekey.tar' }
  let(:key)      { "some_prefix/#{filename}" }
  let(:config_hash) do
    {
      s3_bucket_prefix: 'some_prefix',
      s3_bucket: 's3://some_bucket',
      filename: filename
    }
  end
  let(:backup)  { Backupsss::Backup.new(config_hash, client) }
  let(:file)    { instance_double('File') }
  let(:client) { double }

  describe '#put_file' do
    let(:sm) { 1024*1024*100 }
    let(:md) { 1024*1024*150 }
    let(:lg) { 1024*1024*200 }
    context 'when the file size is less than 100 MB' do
      let(:file) { OpenStruct.new(:size => sm) }
      it 'uploads the file to the s3 location defined by the config' do
        allow(client).to receive(:put_object)
          .with(bucket: 's3://some_bucket', key: key, body: file)

        backup.put_file(file)

        expect(client).to have_received(:put_object)
          .with(bucket: 's3://some_bucket', key: key, body: file)
      end
    end

    context 'when the file size is greater than 100 MB' do
      let(:file) { OpenStruct.new(:size => md) }
      it 'creates a multipart upload' do
        allow(client).to receive(:create_multipart_upload)
          .with(bucket: 's3://some_bucket', key: key)

        backup.put_file(file)

        expect(client).to have_received(:create_multipart_upload)
          .with(bucket: 's3://some_bucket', key: key)
      end
    end
  end
end
