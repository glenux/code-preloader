# vim: set ts=2 sw=2 et ft=crystal:

require "file"
require "option_parser"

# The CodePreloader module organizes classes and methods related to preloading code files.
module CodePreloader
  # The Cli class handles command-line interface operations for the CodePreloader.
  class Cli
    getter repo_path : String
    getter ignore_list : Array(String) = [] of String
    getter output_file_path : String
    getter preamble_file_path : String?
    getter header_prompt_file_path : String? # Add type annotation
    getter footer_prompt_file_path : String? # Assuming you'll also need this

    # Initializes the Cli class with default values.
    def initialize
      @repo_path = ""
      @output_file_path = ""
    end

    # Parses command-line arguments and initializes the necessary configurations.
    def parse_arguments(args : Array(String))
      OptionParser.parse(args) do |parser|
        parser.banner = "Usage: code-preloader [options] ROOT_DIR"

        parser.on("-c CONFIG_FILE", "--config=CONFIG_FILE", "Load parameters from CONFIG_FILE") do |config_file|
          load_config(config_file)
        end

        parser.on("-i IGNORE_PATH", "--ignore=IGNORE_PATH", "Ignore file or directory") do |ignore_file|
          @ignore_list << ignore_file
        end

        parser.on("-o OUTPUT_FILE", "--output=OUTPUT_FILE", "Write output to OUTPUT_FILE") do |output_file|
          @output_file_path = output_file
        end

        parser.on("--header-prompt=HEADER_PROMPT_FILE", "Load header prompt from HEADER_PROMPT_FILE") do |header_prompt_file|
          @header_prompt_file_path = header_prompt_file
        end

        parser.on("--footer-prompt=FOOTER_PROMPT_FILE", "Load footer prompt from FOOTER_PROMPT_FILE") do |footer_prompt_file|
          @footer_prompt_file_path = footer_prompt_file
        end

        parser.on("-h", "--help", "Show this help") do
          STDERR.puts parser
          exit
        end

        parser.unknown_args do |remaining_args, _|
          if remaining_args.size != 1
            abort("Invalid number of arguments. Expected exactly one argument for ROOT_DIR.")
          end
          @repo_path = remaining_args[0]
        end
      end

      validate_arguments
    end

      # Executes the main functionality of the CLI application.
    def exec
      if preamble_file_path
        STDERR.puts "Loading preamble from: #{preamble_file_path}"
      end

      if header_prompt_file_path
        STDERR.puts "Loading header prompt from: #{header_prompt_file_path}"
      end

      if footer_prompt_file_path
        STDERR.puts "Loading footer prompt from: #{footer_prompt_file_path}"
      end

      STDERR.puts "Processing repository: #{repo_path}"
      process_repository
      STDERR.puts "Processing completed. Output written to: #{@output_file_path.empty? ? "stdout" : @output_file_path}"

    rescue e : Exception
      STDERR.puts "An error occurred during execution: #{e.message}"
      exit(1)
    end

    # Processes the specified repository and writes the output to a file.
    def process_repository
      local_output_file_path = @output_file_path
      must_close = false
      output_file = STDOUT

      if !local_output_file_path.empty? && (local_output_file_path != "-")
        output_file = File.open(local_output_file_path, "w")
        must_close = true
      end 

      output_file.puts preamble_text if preamble_file_path
      process_directory(repo_path, output_file)
      output_file.close if must_close

    rescue e : IO::Error
      STDERR.puts "Error processing repository: #{e.message}"
      exit(1)
    end

    private def process_directory(path : String, output_file : IO::FileDescriptor)
      Dir.each_child(path) do |child|
        child_path = File.join(path, child)

        ignores = (
          ignore_list
          .map{ |prefix| [prefix, File.expand_path(child_path) =~ /^#{File.expand_path(prefix)}/] }
          .reject!{ |item| item[1].nil? }
        )
        next if !ignores.empty?
        
        puts "File: #{child_path}"
        child_path = File.join(path, child)
        if File.directory?(child_path)
          process_directory(child_path, output_file)
        else
          process_file(child_path, output_file)
        end
      end
    end

    private def process_file(file_path : String, output_file : IO::FileDescriptor)
      relative_file_path = file_path.sub(/^#{Regex.escape(repo_path)}/, ".").lstrip
      output_file.puts "@@ File \"#{relative_file_path}\""
      output_file.puts ""
      output_file.puts(File.read(file_path))
      output_file.puts ""
    end

    private def preamble_text : String
      local_preamble_file_path = @preamble_file_path
      return "" if local_preamble_file_path.nil?

      File.read(local_preamble_file_path)
    rescue e : IO::Error
      STDERR.puts "Error reading preamble file: #{e.message}"
      exit(1)
    end

    private def validate_arguments
      abort("Missing repository path.") if repo_path.empty?
      STDERR.puts("Output file path not specified (using STDOUT)") if output_file_path.empty?
    end

    # Reads and returns a list of paths to ignore from the given file.
    def self.get_ignore_list(ignore_file_path : String) : Array(String)
      File.exists?(ignore_file_path) ? File.read_lines(ignore_file_path).map(&.strip) : [] of String
    rescue e : IO::Error
      STDERR.puts "Error reading ignore file: #{e.message}"
      exit(1)
    end

    # Loads configuration from a config file.
    private def load_config(config_file_path : String)
      # Implement configuration loading logic here
    end
  end
end
