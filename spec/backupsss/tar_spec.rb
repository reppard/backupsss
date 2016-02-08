require 'spec_helper'
require 'backupsss/tar'

describe Backupsss::Tar do
  describe '#valid_src?' do
    let(:src) do
      'spec/fixtures/backup_src'
    end

    subject do
      Backupsss::Tar.new(src, '')
    end

    context 'when src does not exist on the file system' do
      before do
        allow(File).to receive(:exist?) { false }
      end

      it 'will raise Errno::ENOENT' do
        expect { subject.valid_src? }.to raise_error(Errno::ENOENT)
      end

      it 'will raise with the value of src in the message' do
        expect { subject.valid_src? }.to raise_error(/#{src}$/)
      end
    end

    context 'when src is not readable' do
      before do
        allow(File).to receive(:exist?)    { true }
        allow(File).to receive(:readable?) { false }
      end

      it 'will raise Errno::EPERM' do
        expect { subject.valid_src? }.to raise_error(Errno::EPERM)
      end

      it 'will raise with the value of src in the message' do
        expect { subject.valid_src? }.to raise_error(/#{src}$/)
      end
    end

    context 'when src exists and is readable' do
      before do
        allow(File).to receive(:exist?)    { true }
        allow(File).to receive(:readable?) { true }
      end

      it 'will return true' do
        expect(subject.valid_src?).to be true
      end
    end
  end

  describe '#valid_dest?' do
    let(:dest) do
      'spec/fixtures/backups/backup.tar'
    end

    subject do
      Backupsss::Tar.new('', dest)
    end

    context 'when dest dir does not exist on the file system' do
      before do
        allow(File).to receive(:exist?) { false }
      end

      it 'will raise Errno::ENOENT' do
        expect { subject.valid_dest? }.to raise_error(Errno::ENOENT)
      end

      it 'will raise with the dirname of dest in the message' do
        err_regex = /#{File.dirname(dest)}$/
        expect { subject.valid_dest? }.to raise_error(err_regex)
      end
    end

    context 'when dest dir is not writable' do
      before do
        allow(File).to receive(:exist?)    { true }
        allow(File).to receive(:writable?) { false }
      end

      it 'will raise Errno::EPERM' do
        expect { subject.valid_dest? }.to raise_error(Errno::EPERM)
      end

      it 'will raise with the dirname of dest in the message' do
        err_regex = /#{File.dirname(dest)}$/
        expect { subject.valid_dest? }.to raise_error(err_regex)
      end
    end

    context 'when dest dir exists and is writable' do
      before do
        allow(File).to receive(:exist?)    { true }
        allow(File).to receive(:writable?) { true }
      end

      it 'will return true' do
        expect(subject.valid_dest?).to be true
      end
    end
  end

  describe '#make' do
    context 'when src and dest dir exist with correct permissions' do
      before do
        FileUtils.mkdir_p(src)
        FileUtils.mkdir_p(File.dirname(dest))
      end

      after do
        FileUtils.rm_rf(src)
        FileUtils.rm_rf(File.dirname(dest))
      end

      let(:src) do
        'spec/fixtures/backup_src'
      end

      let(:dest) do
        'spec/fixtures/backup/backup.tar'
      end

      subject do
        Backupsss::Tar.new(src, dest)
      end

      it 'will return a file' do
        expect(subject.make).to be_a(File)
      end
    end

    context 'when src is not readable' do
      before do
        allow(File).to receive(:readable?) { false }
        allow(File).to receive(:writable?) { true }
        allow(File).to receive(:exist?)    { true }
      end

      subject do
        Backupsss::Tar.new('some/src', 'some/dest.tar')
      end

      it 'will re-raise Errno::EPERM' do
        expect { subject.make }.to raise_error(Errno::EPERM)
      end
    end

    context 'when dest is not writable' do
      before do
        allow(File).to receive(:writable?) { false }
        allow(File).to receive(:readable?) { true }
        allow(File).to receive(:exist?)    { true }
      end

      subject do
        Backupsss::Tar.new('some/src', 'some/dest.tar')
      end

      it 'will re-raise Errno::EPERM' do
        expect { subject.make }.to raise_error(Errno::EPERM)
      end
    end

    context 'when src or dest do not exist' do
      before do
        allow(File).to receive(:writable?) { true }
        allow(File).to receive(:readable?) { true }
        allow(File).to receive(:exist?)    { false }
      end

      subject do
        Backupsss::Tar.new('some/src', 'some/dest.tar')
      end

      it 'will re-raise Errno::ENOENT' do
        expect { subject.make }.to raise_error(Errno::ENOENT)
      end
    end
  end
end
