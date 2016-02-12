module Backupsss
  # A class for list and sorting files by mtime
  class BackupDir
    def initialize(dir)
      @dir = dir
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

    def to_s
      @dir
    end
  end
end
