require 'spec_helper'
require 'backupsss/backup'

describe Backupsss::Backup do
  describe '#make_tar' do
    let(:tar) do
      instance_double('Backupsss::Tar', make: nil)
    end

    let(:backup) do
      Backupsss::Backup.new(tar: tar)
    end

    it 'sends #make to Tar' do
      backup.make_tar
      expect(tar).to have_received(:make)
    end
  end

  describe '#put_tar' do
    let(:client) { instance_double('AWS::S3::Client', put_object: nil) }
    let(:tar)    { instance_double('Backupsss::Tar', make: nil) }

    let(:config) do
      instance_double(
        'Backupsss::Configuration',
        s3_bucket:      's3://some_bucket',
        s3_bucket_key:  'some_key'
      )
    end

    let(:backup) do
      Backupsss::Backup.new(config: config, client: client, tar: tar)
    end

    it 'uploads the tar to the s3 location defined by the config' do
      tar_file = instance_double('File')
      allow(backup).to receive(:make_tar).and_return(tar_file)
      backup.put_tar

      expect(client).to have_received(:put_object)
        .with(bucket: 's3://some_bucket', key: 'some_key', body: tar_file)
    end
  end
end
