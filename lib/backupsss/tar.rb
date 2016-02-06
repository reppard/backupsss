require 'open3'

module Backupsss
  class Tar
    attr_reader :src, :dest

    def initialize(src, dest)
      @src = src
      @dest = dest
    end

    def make
      if valid_dest? && valid_src?
        Open3.capture3("tar -cvf #{dest} #{src}")
        File.open(dest)
      end
    end

    def valid_dest?
      dir_exists?(dest_dir) && dest_writable?
    end

    def valid_src?
      dir_exists?(src) && src_readable?
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
      raise SystemCallError.new("#{dir}", err)
    end
  end
end
