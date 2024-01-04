require "option_parser"
require "yaml"

require "./models/root_config"
require "./version"

module CodePreloader
  class Config

    enum Subcommand
      None
      Init
      Pack
      Help
      Version
    end

    class InitOptions
      property config_file_path : String? = nil
    end

    class PackOptions
      property config_file_path : String? = nil
      property repository_path_list : Array(String) = [] of String
      property ignore_list : Array(String) = [] of String
      property output_file_path : String?
      property header_prompt_file_path : String?
      property footer_prompt_file_path : String?
    end

    getter parser : OptionParser?
    property subcommand : Subcommand = Subcommand::None
    property pack_options : PackOptions?
    property init_options : InitOptions?

    def initialize()
    end

    def parse_init_options(parser)
      @init_options = InitOptions.new

      parser.banner = [
        "#{PROGRAM_NAME} v#{VERSION}",
        "Usage: code-preloader init [options]\n",
        "Global options:"
      ].join("\n")

      parser.separator "\nInit options:"
      parser.unknown_args do |remaining_args, _|
        # FIXME: detect and make error if there are more or less than one
        remaining_args.each do |arg|
          @init_options.try &.config_file_path = arg
        end
      end

      parser.on(
        "-c FILE", 
        "--config=FILE", 
        "Load parameters from FILE"
      ) do |config_file|
        @init_options.try { |opt| opt.config_file_path = config_file }
      end

      parser.separator ""

      parser.missing_option do |opt|
        puts parser
        abort("ERROR: Missing parameter for option #{opt}!")
      end

      parser.invalid_option do |opt|
        puts parser
        abort("ERROR: Invalid option #{opt}!")
      end
    end

    def parse_pack_options(parser) 
      @pack_options = PackOptions.new

      parser.banner = [
        "#{PROGRAM_NAME} v#{VERSION}",
        "Usage: code-preloader pack [options] DIR ...\n",
        "Global options:"
      ].join("\n")

      parser.separator "\nPack options:"
      parser.on(
        "-i REGEXP", 
        "--ignore=REGEXP", 
        "Ignore file or directory"
      ) do |ignore_file|
        @pack_options.try { |opt| opt.ignore_list << ignore_file }
      end

      parser.on(
        "-o FILE", 
        "--output=FILE", 
        "Write output to FILE"
      ) do |output_file|
        @pack_options.try { |opt| opt.output_file_path = output_file }
      end

      parser.on(
        "-H FILE", 
        "--header-prompt=FILE", 
        "Load header prompt from FILE"
      ) do |header_prompt_file|
        @pack_options.try { |opt| opt.header_prompt_file_path = header_prompt_file }
      end

      parser.on(
        "-F FILE", 
        "--footer-prompt=FILE", 
        "Load footer prompt from FILE"
      ) do |footer_prompt_file|
        @pack_options.try { |opt| opt.footer_prompt_file_path = footer_prompt_file }
      end

      parser.on(
        "-c FILE", 
        "--config=FILE", 
        "Load parameters from FILE"
      ) do |config_file|
        @pack_options.try { |opt| load_pack_config(config_file) }
      end

      parser.separator ""

      parser.unknown_args do |remaining_args, _|
        remaining_args.each do |arg|
          @pack_options.try { |opt| opt.repository_path_list << arg }
        end
      end

      parser.missing_option do |opt|
        puts parser
        abort("ERROR: Missing parameter for option #{opt}!")
      end

      parser.invalid_option do |ex|
        puts parser
        abort("ERROR: Invalid option #{ex}")
      end
    end

    def parse_arguments(args : Array(String))
      @parser = OptionParser.new do |parser|
        parser.banner = [
          "#{PROGRAM_NAME} v#{VERSION}",
          "Usage: code-preloader <subcommand> [options] [DIR] [...]\n",
          "Global options:"
        ].join("\n")

        parser.on("--version", "Show version") do
          STDOUT.puts "#{PROGRAM_NAME} #{VERSION}"
          exit(0)
        end

        parser.on("-h", "--help", "Show this help") do
          STDERR.puts parser
          exit
        end

        parser.separator "\nSubcommands:"

        parser.on("init", "Create an example .code_preloader.yml file") do
          @subcommand = Subcommand::Init
          parse_init_options(parser)
        end

        parser.on("pack", "Create the packed version of a directory for LLM prompting") do
          @subcommand = Subcommand::Pack
          parse_pack_options(parser)
        end

        parser.separator ""

        parser.invalid_option do |ex|
          puts parser
          abort("ERROR: Invalid option #{ex}")
        end
      end

      @parser.try &.parse(args)
      validate
    end

    def detect_config
      # FIXME: detect config name, if any
    end

    private def validate
      case @subcommand
      when Subcommand::Init then validate_init
      when Subcommand::Pack then validate_pack
      else
        abort("Unknown subcommand #{@subcommand}")
      end
    end

    private def validate_init
      abort("No init options defined!") if @init_options.nil?
    end

    private def validate_pack
      abort("No pack options defined!") if @pack_options.nil?
      @pack_options.try do |opts|
        abort("Missing repository path.") if opts.repository_path_list.empty?

        if opts.output_file_path.nil? || opts.output_file_path.try(&.empty?)
          STDERR.puts("Output file path not specified (using STDOUT)") 
        end
      end
    end

    # Reads and returns a list of paths to ignore from the given file.
    def self.get_ignore_list(ignore_file_path : String) : Array(String)
      File.exists?(ignore_file_path) ? File.read_lines(ignore_file_path).map(&.strip) : [] of String
    rescue e : IO::Error
      STDERR.puts "Error reading ignore file: #{e.message}"
      exit(1)
    end

    private def load_pack_config(config_file_path : String)
      config_str = File.read(config_file_path)

      root = Models::RootConfig.from_yaml(config_str)

      @pack_options.try do |opts|
        opts.config_file_path = config_file_path
        opts.repository_path_list = root.repository_path_list || opts.repository_path_list
        opts.ignore_list = root.ignore_list || opts.ignore_list
        opts.output_file_path = root.output_file_path || opts.output_file_path
        opts.header_prompt_file_path = root.header_prompt_file_path || opts.header_prompt_file_path
        opts.footer_prompt_file_path = root.footer_prompt_file_path || opts.footer_prompt_file_path
      end

    rescue ex : Exception
      STDERR.puts "Failed to load config file: #{ex.message}"
      exit(1)
    end
  end
end

