module Backupsss
  # A class for cleaning up backup artifacts
  class LocalJanitor
    attr_reader :dir, :retention_count

    def initialize(dir, retention_count = 0)
      @dir             = dir
      @retention_count = retention_count
    end

    def ls_garbage
      garbage = sort_garbage(filter_garbage)

      treasures = []
      retention_count.times { treasures << "#{garbage.pop} (retaining)" }

      puts garbage_message(treasures + garbage.reverse)

      garbage
    end

    def rm_garbage(file_array)
      file_array.each { |f| burn_item(f) }
      display_finished
    end

    private

    def burn_item(item)
      FileUtils.rm(File.join(dir, item))
      display_cleanup(item)
    rescue SystemCallError => e
      display_error(e, item)
    end

    def filter_garbage
      Dir.entries(dir).reject { |f| (f == '..' || f == '.') }
    end

    def sort_garbage(garbage)
      sorted_garbage = garbage.map         { |f| File.open("#{dir}/#{f}") }
      sorted_garbage = sorted_garbage.sort { |a, b| a.mtime <=> b.mtime }
      sorted_garbage.map                   { |f| f.to_path.split('/').last }
    end

    def garbage_message(garbage)
      if garbage.empty?
        'No garbage found'
      else
        ['Found garbage...', garbage].flatten.join("\n")
      end
    end

    def display_finished
      puts 'Finished cleaning up.'
    end

    def display_cleanup(item)
      puts "Cleaning up #{item}"
    end

    def display_error(e, item)
      puts "Could not clean up #{item}: #{e.message}"
    end
  end
end
