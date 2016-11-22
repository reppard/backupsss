require 'spec_helper'
require 'rufus-scheduler'
require 'backupsss'

describe Backupsss do
  it 'has a version number' do
    expect(Backupsss::VERSION).not_to be nil
  end

  describe '#run' do
    let(:scheduler) { double(Rufus::Scheduler) }
    let(:config_hash) do
      {
        s3_bucket_prefix: 'some_prefix',
        s3_bucket: 's3://some_bucket',
        filename: filename,
        backup_freq: '0 * * * *'
      }
    end
    let(:subject) do
      b = Backupsss
      dbl_conf = double
      allow(dbl_conf).to receive(:backup_freq).and_return('0 * * * *')
      b.instance_variable_set(:@config, dbl_conf)
      b
    end
    it 'sets the cron target to #call and calls #join' do
      allow(Rufus::Scheduler).to receive(:new).and_return(scheduler)
      allow(scheduler).to receive(:cron) { |&block| block.call }
      allow(scheduler).to receive(:join)
      allow(subject).to receive(:call)

      expect(Rufus::Scheduler).to receive(:new).once.ordered
      expect(scheduler).to receive(:cron).once.ordered
        .with('0 * * * *', blocking: true)
      expect(subject).to receive(:call).once.ordered
      expect(scheduler).to receive(:join).once.ordered
      subject.run
    end
  end
end
