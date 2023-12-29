
# vim: set ts=2 sw=2 et ft=crystal:

require "file"
require "option_parser"

require "./config"

# The CodePreloader module organizes classes and methods related to preloading code files.
module CodePreloader
  # The Cli class handles command-line interface operations for the CodePreloader.
  class Cli
    @config : Config

    # Initializes the Cli class with default values.
    def initialize(args)
      @output_file_path = ""
      @config = Config.new()
      @config.parse_arguments(args)
    end


      # Executes the main functionality of the CLI application.
    def exec
      header_prompt = ""
      footer_prompt = ""
      __header_prompt_file_path = @config.header_prompt_file_path
      __footer_prompt_file_path = @config.footer_prompt_file_path

      if !__header_prompt_file_path.nil?
        STDERR.puts "Loading header prompt from: #{__header_prompt_file_path}"
        header_prompt = File.read(__header_prompt_file_path)
      end

      if !__footer_prompt_file_path.nil?
        STDERR.puts "Loading footer prompt from: #{__footer_prompt_file_path}"
        footer_prompt = File.read(__footer_prompt_file_path)
      end

      STDERR.puts "Processing repository: #{@config.repository_path}"

      __output_file_path = @output_file_path
      __repository_path = @config.repository_path 

      abort("@output_file_path should be non-nil here") if __output_file_path.nil?
      abort("@repository_path should be non-nil here") if __repository_path.nil?

      invalid_output_file = true
      output_file = STDOUT

      unless __output_file_path.nil? || __output_file_path.try(&.empty?) || (__output_file_path != "-")
        output_file = File.open(__output_file_path, "w")
        invalid_output_file = false
      end 

      output_file.puts header_prompt if @config.header_prompt_file_path

      process_repository(__repository_path, output_file)

      output_file.puts footer_prompt if @config.footer_prompt_file_path

      output_file.close if !invalid_output_file
      STDERR.puts "Processing completed. Output written to: #{invalid_output_file ? "stdout" : __output_file_path}"

    rescue e : Exception
      STDERR.puts "An error occurred during execution: #{e.message}"
      exit(1)
    end

    # Processes the specified repository and writes the output to a file.
    def process_repository(repository_path : String, output_file : IO::FileDescriptor)
      process_directory(repository_path, output_file)

    rescue e : IO::Error
      STDERR.puts "Error processing repository: #{e.message}"
      exit(1)
    end

    private def process_directory(path : String, output_file : IO::FileDescriptor)
      __repository_path = @config.repository_path
      abort("@repository_path should be non-nil here") if __repository_path.nil?

      Dir.each_child(path) do |child|
        child_path = File.join(path, child)

        ignores = (
          @config.ignore_list
          .map{ |prefix| [prefix, File.expand_path(child_path) =~ /^#{File.expand_path(prefix)}/] }
          .reject!{ |item| item[1].nil? }
        )
        next if !ignores.empty?
        
        STDERR.puts "File: #{child_path}"
        child_path = File.join(path, child)
        if File.directory?(child_path)
          process_directory(child_path, output_file)
        else
          process_file(child_path, output_file)
        end
      end
    end

    private def process_file(file_path : String, output_file : IO::FileDescriptor)
      __repository_path = @config.repository_path
      abort("@repository_path should be non-nil here") if __repository_path.nil?

      relative_file_path = file_path.sub(/^#{Regex.escape(__repository_path)}/, ".").lstrip
      output_file.puts "@@ File \"#{relative_file_path}\""
      output_file.puts ""
      output_file.puts(File.read(file_path))
      output_file.puts ""
    end
  end
end
