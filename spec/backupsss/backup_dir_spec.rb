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

  describe '#ls' do
    subject { Backupsss::BackupDir.new(dir).ls }
    context 'when dir has contents', mod_fs: true do
      it { is_expected.to match_array(['0.tar', '1.tar', 'a.tar']) }
      it { is_expected.not_to include(['..', '.']) }
    end

    context 'when dir has no contents', empty_dir: true do
      it { is_expected.to eq([]) }
    end
  end

  describe '#ls_t' do
    subject { Backupsss::BackupDir.new(dir).ls_t }
    context 'when dir has contents', mod_fs: true do
      it { is_expected.to eq(['a.tar', '0.tar', '1.tar']) }
    end

    context 'when dir has no contents', empty_dir: true do
      it { is_expected.to eq([]) }
    end
  end

  describe '#ls_rt' do
    subject { Backupsss::BackupDir.new(dir).ls_rt }
    context 'returns filenames sorted oldest to newest', mod_fs: true do
      it { is_expected.to eq(['1.tar', '0.tar', 'a.tar']) }
    end
  end

  describe '#to_s' do
    subject { Backupsss::BackupDir.new(dir).to_s }
    it { is_expected.to eq(dir) }
  end
end
