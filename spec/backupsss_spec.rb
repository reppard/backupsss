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
      allow(STDERR).to receive(:puts)

      expect(Rufus::Scheduler).to receive(:new).once.ordered
      expect(scheduler).to receive(:cron).once.ordered
        .with('0 * * * *', blocking: true)
      expect(subject).to receive(:call).once.ordered
      expect(scheduler).to receive(:join).once.ordered
      expect(STDERR).to_not receive(:puts)
      subject.run
    end
    it 'rescues from exceptions and writes a message to STDERR' do
      allow(Rufus::Scheduler).to receive(:new).and_return(scheduler)
      allow(scheduler).to receive(:cron) { |&block| block.call }
      allow(scheduler).to receive(:join)
      allow(subject).to receive(:call).and_raise(RuntimeError, "myerror")
      allow(STDERR).to receive(:puts)

      expect(Rufus::Scheduler).to receive(:new).once.ordered
      expect(scheduler).to receive(:cron).once.ordered
        .with('0 * * * *', blocking: true)
      expect(subject).to receive(:call).once.ordered
      expect(STDERR).to receive(:puts).once.ordered
        .with('ERROR - backup failed: myerror')
      expect(STDERR).to receive(:puts).once.ordered
        .with(/`block in and_raise'/)
      expect(scheduler).to receive(:join).once.ordered
      subject.run
    end
  end
end
