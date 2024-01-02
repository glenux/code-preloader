require "option_parser"
require "yaml"

require "./models/root_config"

module CodePreloader
  class Config
    property repository_path_list : Array(String) = [] of String
    property ignore_list : Array(String) = [] of String
    property output_file_path : String?
    property header_prompt_file_path : String?
    property footer_prompt_file_path : String?

    def initialize()
    end

    def parse_arguments(args : Array(String))
      OptionParser.parse(args) do |parser|
        parser.banner = "Usage: code-preloader [options] DIR1 ..."

        parser.on(
          "-c CONFIG_FILE", 
          "--config=CONFIG_FILE", 
          "Load parameters from CONFIG_FILE"
        ) do |config_file|
          load_config(config_file)
        end

        parser.on(
          "-i IGNORE_PATH", 
          "--ignore=IGNORE_PATH", 
          "Ignore file or directory"
        ) do |ignore_file|
          @ignore_list << ignore_file
        end

        parser.on(
          "-o OUTPUT_FILE", 
          "--output=OUTPUT_FILE", 
          "Write output to OUTPUT_FILE"
        ) do |output_file|
          @output_file_path = output_file
        end

        parser.on(
          "-H HEADER_PROMPT_FILE", 
          "--header-prompt=HEADER_PROMPT_FILE", 
          "Load header prompt from HEADER_PROMPT_FILE"
        ) do |header_prompt_file|
          @header_prompt_file_path = header_prompt_file
        end

        parser.on(
          "-F FOOTER_PROMPT_FILE", 
          "--footer-prompt=FOOTER_PROMPT_FILE", 
          "Load footer prompt from FOOTER_PROMPT_FILE"
        ) do |footer_prompt_file|
          @footer_prompt_file_path = footer_prompt_file
        end

        parser.on("-h", "--help", "Show this help") do
          STDERR.puts parser
          exit
        end

        parser.unknown_args do |remaining_args, _|
          remaining_args.each do |arg|
            @repository_path_list << arg
          end
        end
      end

      validate
    end

    private def validate
      abort("Missing repository path.") if @repository_path_list.empty?
 
      STDERR.puts("Output file path not specified (using STDOUT)") if @output_file_path.nil? || @output_file_path.try(&.empty?)
    end

    # Reads and returns a list of paths to ignore from the given file.
    def self.get_ignore_list(ignore_file_path : String) : Array(String)
      File.exists?(ignore_file_path) ? File.read_lines(ignore_file_path).map(&.strip) : [] of String
    rescue e : IO::Error
      STDERR.puts "Error reading ignore file: #{e.message}"
      exit(1)
    end

    private def load_config(config_file_path : String)
      config_str = File.read(config_file_path)

      root = Models::RootConfig.from_yaml(config_str)

      @repository_path = root.repository_path_list || @repository_path_list
      @ignore_list = root.ignore_list || @ignore_list
      @output_file_path = root.output_file_path || @output_file_path
      @header_prompt_file_path = root.header_prompt_file_path || @header_prompt_file_path
      @footer_prompt_file_path = root.footer_prompt_file_path || @footer_prompt_file_path

    rescue ex : Exception
      STDERR.puts "Failed to load config file: #{ex.message}"
      exit(1)
    end
  end
end

