require 'open3'

module Backupsss
  # The Tar class is used for creating a tar archive.
  class Tar
    attr_reader :src, :dest, :compress_archive

    def initialize(src, dest, compress_archive = true)
      @src              = src
      @dest             = dest
      @compress_archive = compress_archive
    end

    def make
      if valid_dest? && valid_src?
        _, err, status = Open3.capture3("#{tar_command} #{dest} #{src}")
        STDERR.puts "tar command stderr:\n#{err}" unless err.empty?
        if status.exitstatus != 0
          raise "ERROR: #{tar_command} exited #{status.exitstatus}"
        end
        unless File.exist?(dest)
          raise "ERROR: Tar destination file does not exist"
        end
        if File.size(dest) == 0
          raise "ERROR: Tar destionation file is 0 bytes."
        end
        File.open(dest)
      end
    end

    def valid_dest?
      dir_exists?(dest_dir) && dest_writable?
    end

    def valid_src?
      dir_exists?(src) && src_readable?
    end

    def filename
      dest.split('/').last
    end

    def tar_command
      compress_archive ? 'tar -zcvf' : 'tar -cvf'
    end

    private

    def dest_dir
      File.dirname(dest)
    end

    def dest_writable?
      File.writable?(dest_dir) || raise_sys_err(dest_dir, Errno::EPERM::Errno)
    end

    def dir_exists?(dir)
      File.exist?(dir) || raise_sys_err(dir, Errno::ENOENT::Errno)
    end

    def src_readable?
      File.readable?(src) || raise_sys_err(src, Errno::EPERM::Errno)
    end

    def raise_sys_err(dir, err)
      raise SystemCallError.new(dir.to_s, err)
    end
  end
end
