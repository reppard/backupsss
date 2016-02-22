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
  let(:backup)   { Backupsss::Backup.new(config_hash, client) }
  let(:file) { instance_double('File') }
  let(:client)   { double }

  describe '#put_file' do
    it 'uploads the file to the s3 location defined by the config' do
      allow(client).to receive(:put_object)
        .with(bucket: 's3://some_bucket', key: key, body: file)
      allow(client).to receive(:wait_until)
        .with(:object_exists, bucket: 's3://some_bucket', key: key)

      backup.put_file(file)

      expect(client).to have_received(:put_object)
        .with(bucket: 's3://some_bucket', key: key, body: file)
      expect(client).to have_received(:wait_until)
        .with(:object_exists, bucket: 's3://some_bucket', key: key)
    end
  end
end
