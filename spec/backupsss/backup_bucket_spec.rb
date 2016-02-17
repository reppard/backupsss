require 'spec_helper'
require 'backupsss/backup_bucket'

describe Backupsss::BackupBucket do
  let(:list_objects_response) do
    {
      is_truncated: false,
      marker: '',
      contents: [
        {
          key:           'mah_bucket/mah_key/1455049150.tar',
          last_modified: Time.new('2016-02-09 20:52:03 UTC'),
          etag:          'somecrazyhashthinffffffffffsddf',
          size:          10_240,
          storage_class: 'STANDARD',
          owner: {
            display_name: 'theowner',
            id:           'ownderidhasthinglkajsdlkjasdflkj'
          }
        },
        {
          key:           'mah_bucket/mah_key/1455049148.tar',
          last_modified: Time.new('2016-02-09 20:50:01 UTC'),
          etag:          'somecrazyhashthinglkjsdlfkjsdf',
          size:          10_240,
          storage_class: 'STANDARD',
          owner: {
            display_name: 'theowner',
            id:           'ownderidhasthinglkajsdlkjasdflkj'
          }
        }
      ],
      name:          'mah_bucket',
      prefix:        'mah_key',
      max_keys:      1000,
      encoding_type: 'url'
    }
  end
  let(:s3_stub) do
    s3 = Aws::S3::Client.new(stub_responses: true)
    s3.stub_responses(:list_objects, list_objects_response)
    s3
  end
  let(:dir)           { 'mah_bucket/mah/key' }
  let(:region)        { 'us-east-1' }
  let(:backup_bucket) do
    Backupsss::BackupBucket.new(dir: dir, region: region)
  end

  before(stub_s3: true) do
    allow(backup_bucket).to receive(:s3_client).and_return(s3_stub)
  end

  describe '#initialize' do
    context 'dir' do
      subject { backup_bucket.dir }
      it      { is_expected.to eq(dir) }
    end

    context 'region' do
      subject { backup_bucket.region }
      it      { is_expected.to eq(region) }
    end
  end

  describe '#s3_client' do
    let(:fake_client) { Class.new }
    it 'should get a new s3 client' do
      stub_const('Aws::S3::Client', fake_client)

      expect(fake_client).to receive(:new).with(region: region)
      backup_bucket.s3_client
    end
  end

  describe '#bucket' do
    subject { backup_bucket.bucket }
    it      { is_expected.to eq('mah_bucket') }
  end

  describe '#prefix' do
    subject { backup_bucket.prefix }
    it      { is_expected.to eq('mah/key') }
  end

  describe '#ls' do
    it 'returns an array of s3 objects', stub_s3: true do
      expected_files = [
        'mah_bucket/mah_key/1455049148.tar',
        'mah_bucket/mah_key/1455049150.tar'
      ]
      expect(backup_bucket.ls).to match_array(expected_files)
    end
  end

  describe '#ls_t' do
    it 'returns an array of s3 objects ordered newest to oldest',
       stub_s3: true do
      expected_files = [
        'mah_bucket/mah_key/1455049150.tar',
        'mah_bucket/mah_key/1455049148.tar'
      ]
      expect(backup_bucket.ls_t).to eq(expected_files)
    end
  end

  describe '#ls_rt' do
    it 'returns an array of s3 objects ordered oldest to newest',
       stub_s3: true do
      expected_files = [
        'mah_bucket/mah_key/1455049148.tar',
        'mah_bucket/mah_key/1455049150.tar'
      ]

      expect(backup_bucket.ls_rt).to eq(expected_files)
    end
  end

  describe '#rm' do
  end
end
