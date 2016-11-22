require 'spec_helper'
require 'backupsss/tar'

def dbl_exitstatus(code)
  d = double
  allow(d).to receive(:exitstatus).and_return(code)
  d
end

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

  describe '#tar_command' do
    context 'compress_archive true' do
      subject { Backupsss::Tar.new('src/', 'dest.tar').tar_command }

      it { is_expected.to eq('tar -zcvf') }
    end

    context 'compress_archive false' do
      subject { Backupsss::Tar.new('src/', 'dest.tar', false).tar_command }

      it { is_expected.to eq('tar -cvf') }
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
      let(:subject) { Backupsss::Tar.new(src, dest) }
      let(:dbl_file) { double(File) }
      let(:dbl_status) { dbl_exitstatus(0) }
      before(:each) do
        allow(subject).to receive(:valid_dest?).and_return(true)
        allow(subject).to receive(:valid_src?).and_return(true)
        allow(subject).to receive(:tar_command).and_return('tarcmd')
        allow(Open3).to receive(:capture3).and_return(['', '', dbl_status])
        allow(STDERR).to receive(:puts)
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:size).and_return(999)
        allow(File).to receive(:open).and_return(dbl_file)
      end

      it 'calls the appropriate command' do
        expect(subject).to receive(:valid_dest?).once.ordered
        expect(subject).to receive(:valid_src?).once.ordered
        expect(Open3).to receive(:capture3).once.ordered
          .with("tarcmd #{dest} #{src}")
        expect(STDERR).to_not receive(:puts)
        expect(File).to receive(:exist?).once.ordered.with(dest)
        expect(File).to receive(:size).once.ordered.with(dest)
        subject.make
      end

      it 'returns the open File object' do
        expect(subject).to receive(:valid_dest?).once.ordered
        expect(subject).to receive(:valid_src?).once.ordered
        expect(STDERR).to_not receive(:puts)
        expect(File).to receive(:exist?).once.ordered.with(dest)
        expect(File).to receive(:size).once.ordered.with(dest)
        expect(File).to receive(:open).once.ordered.with(dest)
        expect(subject.make).to eq(dbl_file)
      end
    end
    context 'when tar exits non-zero' do
      let(:subject) { Backupsss::Tar.new(src, dest) }
      let(:dbl_file) { double(File) }
      let(:dbl_status) { dbl_exitstatus(3) }
      before(:each) do
        allow(subject).to receive(:valid_dest?).and_return(true)
        allow(subject).to receive(:valid_src?).and_return(true)
        allow(subject).to receive(:tar_command).and_return('tarcmd')
        allow(Open3).to receive(:capture3)
          .and_return(['', 'some stderr', dbl_status])
        allow(STDERR).to receive(:puts)
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:size).and_return(999)
        allow(File).to receive(:open).and_return(dbl_file)
      end

      it 'raises an error' do
        expect(subject).to receive(:valid_dest?).once.ordered
        expect(subject).to receive(:valid_src?).once.ordered
        expect(Open3).to receive(:capture3).once.ordered
          .with("tarcmd #{dest} #{src}")
        expect(STDERR).to receive(:puts).once.ordered
          .with("tar command stderr:\nsome stderr")
        expect(File).to_not receive(:open)
        expect { subject.make }.to raise_error(
          RuntimeError, /ERROR: tarcmd exited 3/)
      end
    end
    context 'when destination file does not exist' do
      let(:subject) { Backupsss::Tar.new(src, dest) }
      let(:dbl_file) { double(File) }
      let(:dbl_status) { dbl_exitstatus(0) }
      before(:each) do
        allow(subject).to receive(:valid_dest?).and_return(true)
        allow(subject).to receive(:valid_src?).and_return(true)
        allow(subject).to receive(:tar_command).and_return('tarcmd')
        allow(Open3).to receive(:capture3).and_return(['', '', dbl_status])
        allow(STDERR).to receive(:puts)
        allow(File).to receive(:exist?).and_return(false)
        allow(File).to receive(:size).and_return(999)
        allow(File).to receive(:open).and_return(dbl_file)
      end

      it 'raises an error' do
        expect(subject).to receive(:valid_dest?).once.ordered
        expect(subject).to receive(:valid_src?).once.ordered
        expect(Open3).to receive(:capture3).once.ordered
          .with("tarcmd #{dest} #{src}")
        expect(STDERR).to_not receive(:puts)
        expect(File).to receive(:exist?).once.with(dest)
        expect(File).to_not receive(:open)
        expect { subject.make }.to raise_error(
          RuntimeError, /ERROR: Tar destination file does not exist/)
      end
    end
    context 'when destination file is 0 bytes' do
      let(:subject) { Backupsss::Tar.new(src, dest) }
      let(:dbl_file) { double(File) }
      let(:dbl_status) { dbl_exitstatus(0) }
      before(:each) do
        allow(subject).to receive(:valid_dest?).and_return(true)
        allow(subject).to receive(:valid_src?).and_return(true)
        allow(subject).to receive(:tar_command).and_return('tarcmd')
        allow(Open3).to receive(:capture3).and_return(['', '', dbl_status])
        allow(STDERR).to receive(:puts)
        allow(File).to receive(:exist?).and_return(true)
        allow(File).to receive(:size).and_return(0)
        allow(File).to receive(:open).and_return(dbl_file)
      end

      it 'raises an error' do
        expect(subject).to receive(:valid_dest?).once.ordered
        expect(subject).to receive(:valid_src?).once.ordered
        expect(Open3).to receive(:capture3).once.ordered
          .with("tarcmd #{dest} #{src}")
        expect(STDERR).to_not receive(:puts)
        expect(File).to receive(:exist?).once.ordered.with(dest)
        expect(File).to receive(:size).once.ordered.with(dest)
        expect(File).to_not receive(:open)
        expect { subject.make }.to raise_error(
          RuntimeError, /ERROR: Tar destionation file is 0 bytes\./)
      end
    end
  end
end
