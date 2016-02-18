require 'spec_helper'
require 'backupsss/backup_dir'

describe Backupsss::BackupDir do
  before(:example, mod_fs: true) do
    FileUtils.mkdir(dir)
    ['a', 0, 1].each_with_index do |n, i|
      File.open("#{dir}/#{n}.tar", 'w') { |f| f.puts n }
      FileUtils.touch("#{dir}/#{n}.tar", mtime: Time.now + i)
    end
  end

  before(:example, empty_dir: true) { FileUtils.mkdir(dir) }
  after(:example, empty_dir: true)  { FileUtils.rm_rf(dir) }
  after(:example, mod_fs: true)     { FileUtils.rm_rf(dir) }
  let(:dir)                         { 'spec/fixtures/backups' }
  let(:opts)                        { { dir: dir } }

  describe '#ls' do
    subject { Backupsss::BackupDir.new(opts).ls }
    context 'when dir has contents', mod_fs: true do
      it { is_expected.to match_array(['0.tar', '1.tar', 'a.tar']) }
      it { is_expected.not_to include(['..', '.']) }
    end

    context 'when dir has no contents', empty_dir: true do
      it { is_expected.to eq([]) }
    end
  end

  describe '#ls_t' do
    subject { Backupsss::BackupDir.new(opts).ls_t }
    context 'when dir has contents', mod_fs: true do
      it { is_expected.to eq(['a.tar', '0.tar', '1.tar']) }
    end

    context 'when dir has no contents', empty_dir: true do
      it { is_expected.to eq([]) }
    end
  end

  describe '#ls_rt' do
    subject { Backupsss::BackupDir.new(opts).ls_rt }
    context 'returns filenames sorted oldest to newest', mod_fs: true do
      it { is_expected.to eq(['1.tar', '0.tar', 'a.tar']) }
    end
  end

  describe '#rm' do
    context 'when given a file that currently exists', mod_fs: true do
      subject { Backupsss::BackupDir.new(opts).rm('a.tar') }

      it { is_expected.to eq('a.tar') }
    end

    context 'when given a non-existent file' do
      subject { -> { Backupsss::BackupDir.new(opts).rm('fram.tar') } }

      it { is_expected.to raise_error(Backupsss::RemovalError) }
    end

    context 'when given a file that is not modifiable' do
      subject { -> { Backupsss::BackupDir.new(opts).rm('1.tar') } }
      before do
        allow(FileUtils).to receive(:rm).with(dir + '/1.tar')
          .and_raise(Errno::EPERM)
      end

      it { is_expected.to raise_error(Backupsss::RemovalError) }
    end
  end
end
