require 'spec_helper'
require 'backupsss/tar'

describe Backupsss::Tar do
  let(:src)      { 'spec/fixtures/backup_src' }
  let(:filename) { 'backup.tar' }
  let(:dest)     { "spec/fixtures/backups/#{filename}" }
  before         { allow(File).to receive(:exist?) { true } }

  describe '#filename' do
    subject { Backupsss::Tar.new(src, dest).filename }

    it { is_expected.to eq(filename) }
  end

  describe '#valid_src?' do
    subject { -> { Backupsss::Tar.new(src, '').valid_src? } }

    context 'when src does not exist on the file system' do
      before { allow(File).to receive(:exist?) { false } }

      it { is_expected.to raise_error(Errno::ENOENT) }
      it { is_expected.to raise_error(/#{src}$/) }
    end

    context 'when src is not readable' do
      before { allow(File).to receive(:readable?) { false } }

      it { is_expected.to raise_error(Errno::EPERM) }
      it { is_expected.to raise_error(/#{src}$/) }
    end

    context 'when src exists and is readable' do
      before  { allow(File).to receive(:readable?) { true } }
      subject { Backupsss::Tar.new(src, '').valid_src? }

      it { is_expected.to be true }
    end
  end

  describe '#valid_dest?' do
    subject { -> { Backupsss::Tar.new('', dest).valid_dest? } }

    context 'when dest dir does not exist on the file system' do
      before { allow(File).to receive(:exist?) { false } }

      it { is_expected.to raise_error(Errno::ENOENT) }
      it { is_expected.to raise_error(/#{File.dirname(dest)}$/) }
    end

    context 'when dest dir is not writable' do
      before { allow(File).to receive(:readable?) { false } }

      it { is_expected.to raise_error(Errno::EPERM) }
      it { is_expected.to raise_error(/#{File.dirname(dest)}$/) }
    end

    context 'when dest dir exists and is writable' do
      before  { allow(File).to receive(:writable?) { true } }
      subject { Backupsss::Tar.new('', dest).valid_dest? }

      it { is_expected.to be true }
    end
  end

  describe '#make' do
    subject { -> { Backupsss::Tar.new('some/src', 'some/dest.tar').make } }

    context 'when src is not readable' do
      before { allow(File).to receive(:readable?) { false } }

      it { is_expected.to raise_error(Errno::EPERM) }
    end

    context 'when dest is not writable' do
      before { allow(File).to receive(:writable?) { false } }

      it { is_expected.to raise_error(Errno::EPERM) }
    end

    context 'when src or dest do not exist' do
      before { allow(File).to receive(:exist?) { false } }

      it { is_expected.to raise_error(Errno::ENOENT) }
    end

    context 'when src and dest dir exist with correct permissions' do
      before  { FileUtils.mkdir_p(src) }
      before  { FileUtils.mkdir_p(File.dirname(dest)) }
      after   { FileUtils.rm_rf(src) }
      after   { FileUtils.rm_rf(File.dirname(dest)) }
      subject { Backupsss::Tar.new(src, dest).make }

      it { is_expected.to be_a(File) }
    end
  end
end
