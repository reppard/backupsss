require 'backupsss/removal_error'

module Backupsss
  # A class for listing and sorting files by mtime
  class BackupDir
    def initialize(opts = {})
      @dir = opts[:dir]
    end

    def ls
      Dir.entries(@dir).reject { |f| (f == '..' || f == '.') }
    end

    def ls_t
      ls.sort_by { |f| File.mtime("#{@dir}/#{f}") }
    end

    def ls_rt
      ls_t.reverse
    end

    def rm(file)
      FileUtils.rm(File.join(@dir, file))
      file
    rescue SystemCallError => e
      raise RemovalError, e
    end
  end
end
