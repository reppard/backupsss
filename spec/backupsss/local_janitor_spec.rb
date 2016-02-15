require 'spec_helper'
require 'backupsss/local_janitor'

describe Backupsss::LocalJanitor do
  before(:example, mod_fs: true) do
    FileUtils.mkdir(dir)
    ['a', 0, 1].each_with_index do |n, i|
      File.open("#{dir}/#{n}.tar", 'w') { |f| f.puts n }
      FileUtils.touch("#{dir}/#{n}.tar", mtime: Time.now + i)
    end
  end

  after(:example, mod_fs: true) { FileUtils.rm_rf(dir) }

  let(:dir)     { 'spec/fixtures/backups' }
  let(:garbage) { ['0.tar', '1.tar'] }
  subject       { Backupsss::LocalJanitor.new(dir) }

  describe '#initialize' do
    it 'has retention_count attribute with default of 0' do
      expect(subject.retention_count).to eq(0)
    end
  end

  # This test actually calls BackupDir
  describe '#dir' do
    subject { Backupsss::LocalJanitor.new(dir).dir }
    context 'it returns an object' do
      it { is_expected.to respond_to(:ls) }
      it { is_expected.to respond_to(:ls_rt) }
    end
  end

  describe '#sift_trash' do
    let(:backup_dir) { double('Backupsss::BackupDir', ls_rt: ls_rt) }
    before  { allow(janitor).to receive(:dir) { backup_dir } }

    context 'when there is no garbage to cleanup' do
      let(:ls_rt) { [] }
      let(:janitor) { Backupsss::LocalJanitor.new(dir) }
      let(:message) { "No garbage found\n" }

      subject { -> { janitor.sift_trash } }

      it { is_expected.to output(message).to_stdout }
    end

    context 'when there is garbage to cleanup', ignore_stdout: true do
      let(:ls_rt) { ['1.tar', '0.tar', 'a.tar'] }

      context 'and a retention count (n) is provided' do
        let(:retention_count) { 1 }
        let(:janitor) { Backupsss::LocalJanitor.new(dir, retention_count) }

        subject { janitor.sift_trash }

        it { is_expected.to match_array(['0.tar', 'a.tar']) }

        context 'stdout', ignore_stdout: false do
          subject { -> { janitor.sift_trash } }
          let(:message) { "Found garbage...\n1.tar (retaining)\n0.tar\na.tar" }

          it { is_expected.to output(message + "\n").to_stdout }
        end
      end

      context 'with default retention count' do
        let(:janitor) { Backupsss::LocalJanitor.new(dir) }
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
    context 'when provided garbage can be cleaned up' do
      let(:message) do
        msg = garbage.inject([]) { |a, e| a << "Cleaning up #{e}" }.join("\n")
        msg << "\nFinished cleaning up."
      end

      it 'removes the files provided', mod_fs: true, ignore_stdout: true do
        subject.rm_garbage(garbage)

        files = Dir.entries(dir)
        result = garbage.inject([]) { |a, e| a << files.include?(e) }

        expect(result.all?).to be(false)
      end

      it 'provides progress info about the clean up', mod_fs: true do
        expect { subject.rm_garbage(garbage) }
          .to output(message + "\n").to_stdout
      end
    end

    context 'when provided garbage cannot be cleand up' do
      context 'because another process has already cleaned it up' do
        let(:expected_garbage) { ['0.tar', '1.tar', '2.tar'] }
        let(:message) do
          'Could not clean up 2.tar: No such file or directory'
        end

        it 'reports which file did not exist', mod_fs: true do
          expect { subject.rm_garbage(expected_garbage) }
            .to output(/#{message}/).to_stdout
        end
      end

      context 'because it does not have permission to clean it up' do
        let(:message) do
          'Could not clean up 1.tar: Operation not permitted'
        end

        it 'reports which file could not be cleaned', mod_fs: true do
          allow(FileUtils).to receive(:rm).with(dir + '/0.tar')
          allow(FileUtils).to receive(:rm)
            .with(dir + '/1.tar').and_raise(Errno::EPERM)

          expect { subject.rm_garbage(garbage) }
            .to output(/#{message}/).to_stdout
        end
      end
    end
  end
end
