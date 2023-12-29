require "option_parser"
require "yaml"

module CodePreloader
  class Config
    property repository_path : String?
    property ignore_list : Array(String) = [] of String
    property output_file_path : String?
    property header_prompt_file_path : String?
    property footer_prompt_file_path : String?

    def initialize()
    end

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

        parser.on("-H HEADER_PROMPT_FILE", "--header-prompt=HEADER_PROMPT_FILE", "Load header prompt from HEADER_PROMPT_FILE") do |header_prompt_file|
          @header_prompt_file_path = header_prompt_file
        end

        parser.on("-F FOOTER_PROMPT_FILE", "--footer-prompt=FOOTER_PROMPT_FILE", "Load footer prompt from FOOTER_PROMPT_FILE") do |footer_prompt_file|
          @footer_prompt_file_path = footer_prompt_file
        end

        parser.on("-h", "--help", "Show this help") do
          STDERR.puts parser
          exit
        end

        parser.unknown_args do |remaining_args, _|
          if remaining_args.size > 1
            abort("Invalid number of arguments. Expected exactly one argument for ROOT_DIR.")
          end
          @repository_path = remaining_args[0]
        end
      end

      validate_arguments
    end

    private def validate_arguments
      abort("Missing repository path.") if @repository_path.nil? || @repository_path.try(&.empty?)
      abort("Missing repository path.") if 
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
      config_data = YAML.parse(File.read(config_file_path)).as_h

      @repository_path = config_data["repository_path"]?.try &.as_s || @repository_path

      if ignore_list_yaml = config_data["ignore_list"]?
        @ignore_list = ignore_list_yaml.as_a.map(&.as_s)
      end

      @output_file_path = config_data["output_file_path"]?.try &.as_s || @output_file_path
      @header_prompt_file_path = config_data["header_prompt_file_path"]?.try &.as_s || @header_prompt_file_path
      @footer_prompt_file_path = config_data["footer_prompt_file_path"]?.try &.as_s || @footer_prompt_file_path

    rescue ex
      STDERR.puts "Failed to load config file: #{ex.message}"
      exit(1)
    end
  end
end

