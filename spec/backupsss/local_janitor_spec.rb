require 'spec_helper'
require 'backupsss/local_janitor'

describe Backupsss::LocalJanitor do
  let(:dir)     { 'spec/fixtures/backups' }
  let(:garbage) { ['0.tar', '1.tar', '2.tar'] }
  let(:driver)  { double('FsDriver', dir: dir) }
  let(:opts)    { { driver: driver } }
  let(:janitor) { Backupsss::LocalJanitor.new(opts) }
  subject       { janitor }

  describe '#initialize' do
    it 'has retention_count attribute with default of 0' do
      expect(subject.retention_count).to eq(0)
    end
  end

  # This test actually calls BackupDir
  describe '#dir' do
    before  { allow(driver).to receive(:ls) }
    before  { allow(driver).to receive(:ls_rt) }
    subject { janitor.dir }

    context 'it returns an object' do
      it { is_expected.to respond_to(:ls) }
      it { is_expected.to respond_to(:ls_rt) }
    end
  end

  describe '#sift_trash' do
    before { allow(janitor).to receive(:dir) { driver } }

    context 'when there is no garbage to cleanup' do
      before { allow(driver).to receive(:ls_rt) { [] } }
      let(:message) { "No garbage found\n" }

      subject { -> { janitor.sift_trash } }

      it { is_expected.to output(message).to_stdout }
    end

    context 'when there is garbage to cleanup', ignore_stdout: true do
      before do
        allow(driver).to receive(:ls_rt) { ['1.tar', '0.tar', 'a.tar'] }
      end

      context 'and a retention count (n) is provided' do
        let(:new_opts) { opts.merge(retention_count: 1) }
        let(:janitor)  { Backupsss::LocalJanitor.new(new_opts) }

        subject { janitor.sift_trash }

        it { is_expected.to match_array(['0.tar', 'a.tar']) }

        context 'stdout', ignore_stdout: false do
          subject { -> { janitor.sift_trash } }
          let(:message) { "Found garbage...\n1.tar (retaining)\n0.tar\na.tar" }

          it { is_expected.to output(message + "\n").to_stdout }
        end
      end

      context 'with default retention count' do
        subject { janitor.sift_trash }

        it { is_expected.to match_array(['0.tar', '1.tar', 'a.tar']) }

        context 'stdout', ignore_stdout: false do
          subject { -> { janitor.sift_trash } }
          let(:message) { "Found garbage...\n1.tar\n0.tar\na.tar" }

          it { is_expected.to output(message + "\n").to_stdout }
        end
      end
    end
  end

  describe '#rm_garbage' do
    before { allow(driver).to receive(:rm) }

    context 'when provided garbage can be cleaned up' do
      let(:message) do
        msg = garbage.inject([]) { |a, e| a << "Cleaning up #{e}" }.join("\n")
        msg << "\nFinished cleaning up."
      end

      it 'calls rm on the provided driver', ignore_stdout: true do
        garbage.each { |file| expect(driver).to receive(:rm).with(file) }

        subject.rm_garbage(garbage)
      end

      it 'provides progress info about the clean up' do
        expect { subject.rm_garbage(garbage) }
          .to output(message + "\n").to_stdout
      end
    end

    context 'when provided garbage cannot be cleand up' do
      context 'because another process has already cleaned it up' do
        before do
          allow(driver).to receive(:rm).with('2.tar').and_raise(Errno::ENOENT)
          allow(driver).to receive(:rm).with(['0.tar', '1.tar'])
        end

        let(:message) { 'Could not clean up 2.tar: No such file or directory' }

        it 'reports which file did not exist' do
          expect { subject.rm_garbage(garbage) }
            .to output(/#{message}/).to_stdout
        end
      end

      context 'because it does not have permission to clean it up' do
        let(:message) { 'Could not clean up 1.tar: Operation not permitted' }

        it 'reports which file could not be cleaned' do
          allow(driver).to receive(:rm).with('0.tar')
          allow(driver).to receive(:rm).with('1.tar').and_raise(Errno::EPERM)

          expect { subject.rm_garbage(garbage) }
            .to output(/#{message}/).to_stdout
        end
      end
    end
  end
end
