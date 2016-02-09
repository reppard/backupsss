require 'spec_helper'
require 'backupsss/configuration'

describe Backupsss::Configuration do
  it 'can receive custom attributes' do
    config = Backupsss::Configuration.new(
      s3_bucket:      'a_bucket',
      s3_bucket_key:  'mah_bucket_key',
      backup_src_dir: '/local/path',
      backup_freq:    '0 * * * *',
      aws_region:     'us-east-1'
    )

    expect(config.s3_bucket).to      eq('a_bucket')
    expect(config.s3_bucket_key).to  eq('mah_bucket_key')
    expect(config.backup_src_dir).to eq('/local/path')
    expect(config.backup_freq).to    eq('0 * * * *')
    expect(config.aws_region).to     eq('us-east-1')
  end

  it 'can set attributes with env vars' do
    stub_const(
      'ENV',
      'S3_BUCKET'      => 'mah_bucket',
      'S3_BUCKET_KEY'  => 'mah_bucket_key',
      'BACKUP_SRC_DIR' => '/local/path',
      'BACKUP_FREQ'    => '0 * * * *',
      'AWS_REGION'     => 'us-east-1'
    )
    config = Backupsss::Configuration.new

    expect(config.s3_bucket).to      eq('mah_bucket')
    expect(config.s3_bucket_key).to  eq('mah_bucket_key')
    expect(config.backup_src_dir).to eq('/local/path')
    expect(config.backup_freq).to    eq('0 * * * *')
    expect(config.aws_region).to     eq('us-east-1')
  end
end
