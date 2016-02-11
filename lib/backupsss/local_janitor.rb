module Backupsss
  # A class for cleaning up backup artifacts
  class LocalJanitor
    attr_reader :dir

    def initialize(dir)
      @dir = dir
    end

    def ls_garbage
      garbage = Dir.entries(dir).reject { |f| (f == '..' || f == '.') }
      puts garbage_message(filter_garbage)
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

    def garbage_message(garbage)
      if garbage.empty?
        'No garbage found'
      else
        ['Found garbage...', garbage.sort].flatten.join("\n")
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