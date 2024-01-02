
# vim: set ts=2 sw=2 et ft=crystal:

require "file"
require "option_parser"
require "magic"

require "./config"
require "./filelist"

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
      # get local values for typing
      output_file_path = @output_file_path
      repository_path_list = @config.repository_path_list
      header_prompt_file_path = @config.header_prompt_file_path
      footer_prompt_file_path = @config.footer_prompt_file_path

      filelist = FileList.new()
      filelist.add(repository_path_list)
      @config.ignore_list.each do |ignore_pattern|
        filelist.reject { |path| !!(path =~ Regex.new(ignore_pattern)) }
      end

      if !header_prompt_file_path.nil?
        STDERR.puts "Loading header prompt from: #{header_prompt_file_path}"
        header_prompt = File.read(header_prompt_file_path)
      end

      if !footer_prompt_file_path.nil?
        STDERR.puts "Loading footer prompt from: #{footer_prompt_file_path}"
        footer_prompt = File.read(footer_prompt_file_path)
      end

      unless output_file_path.nil? || output_file_path.try(&.empty?) || (output_file_path != "-")
        output_file = File.open(output_file_path, "w")
        invalid_output_file = false
      end 

      invalid_output_file = true
      output_file = STDOUT
      header_prompt = ""
      footer_prompt = ""

      output_file.puts header_prompt if @config.header_prompt_file_path

      STDERR.puts "Processing repository: #{@config.repository_path_list}"
      filelist.each do |file_path|
        process_file(file_path, output_file)
      end

      output_file.puts footer_prompt if @config.footer_prompt_file_path

      output_file.close if !invalid_output_file
      STDERR.puts "Processing completed. Output written to: #{invalid_output_file ? "stdout" : output_file_path}"

    rescue e : Exception
      STDERR.puts "An error occurred during execution: #{e.message}"
      exit(1)
    end

    private def process_file(file_path : String, output_file : IO::FileDescriptor)
      fh = File.open(file_path)
      mime = Magic.mime_type.of(fh)
      output_file.puts "@@ File \"#{file_path}\" (Mime-Type: #{mime.inspect})"
      output_file.puts ""
      output_file.puts(fh.gets_to_end)
      output_file.puts ""
      fh.close
    end
  end
end
