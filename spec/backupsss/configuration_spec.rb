require 'spec_helper'
require 'backupsss/configuration'

describe Backupsss::Configuration do
  let(:configuration) { Backupsss::Configuration.new }

  it 'has an s3_bucket attribute' do
    configuration.s3_bucket = 'meh_bucket'
    expect(configuration.s3_bucket).to eq('meh_bucket')
  end

  it 'has an s3_bucket_key attribute' do
    configuration.s3_bucket_key = 'meh_bucket_key'
    expect(configuration.s3_bucket_key).to eq('meh_bucket_key')
  end

  it 'has a backup_src_dir attribute' do
    configuration.backup_src_dir = '/path/to/data'
    expect(configuration.backup_src_dir).to eq('/path/to/data')
  end

  it 'has a backup_frequency' do
    configuration.backup_frequency = '3'
    expect(configuration.backup_frequency).to eq('3')
  end

  describe '#initialize' do
  end
end
