module Backupsss
  # Backupsss::Janitor
  class LocalJanitor
    attr_accessor :dir

    def initialize(dir)
      @dir = dir
    end

    def ls_garbage
      garbage = Dir.entries(dir).reject { |f| (f == '..' || f == '.') }
      puts garbage_message(garbage)
      garbage
    end

    def rm_garbage(file_array)
      file_array.each do |f|
        begin
          FileUtils.rm(File.join(dir, f))
          puts "Cleaning up #{f}"
        rescue SystemCallError => e
          puts "Could not clean up #{f}: #{e.message}"
        end
      end
      puts 'Finished cleaning up.'
    end

    private

    def garbage_message(garbage)
      if garbage.empty?
        'No garbage found'
      else
        ['Found garbage...', garbage.sort].flatten.join("\n")
      end
    end
  end
end
