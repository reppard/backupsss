require 'spec_helper'
require 'backupsss/backup'

describe Backupsss::Backup do
  let(:tar)    { instance_double('Backupsss::Tar', make: nil) }
  let(:backup) { Backupsss::Backup.new(config, client, tar) }
  let(:client) do
    instance_double(
      'AWS::S3::Client',
      put_object: nil,
      wait_until: nil
    )
  end
  let(:config) do
    instance_double(
      'Backupsss::Configuration',
      s3_bucket:     's3://some_bucket',
      s3_bucket_key: 'some_key'
    )
  end

  describe '#put_tar' do
    it 'sends #make to Tar' do
      backup.put_tar

      expect(tar).to have_received(:make)
    end

    it 'uploads the tar to the s3 location defined by the config' do
      tar_file = instance_double('File')
      allow(backup).to receive(:make_tar).and_return(tar_file)

      backup.put_tar

      expect(client).to have_received(:put_object)
        .with(bucket: 's3://some_bucket', key: 'some_key', body: tar_file)
      expect(client).to have_received(:wait_until)
        .with(:object_exists, bucket: 's3://some_bucket', key: 'some_key')
    end
  end
end
