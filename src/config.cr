require "option_parser"
require "yaml"
# require "completion"

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

    class HelpOptions
      property parser_snapshot : OptionParser? = nil
    end

    class InitOptions
      property config_path : String? = nil
    end

    class PackOptions
      property config_path : String? = nil
      property source_list : Array(String) = [] of String
      property ignore_list : Array(String) = [] of String
      property output_path : String?
      property prompt_template_path : String?
      property prompt_header_path : String?
      property prompt_footer_path : String?
    end

    getter verbose : Bool = false
    getter parser : OptionParser?
    getter subcommand : Subcommand = Subcommand::None
    getter pack_options : PackOptions?
    getter init_options : InitOptions?
    getter help_options : HelpOptions?

    def initialize()
    end

    def parse_init_options(parser)
      @init_options = InitOptions.new

      parser.banner = [
        "Usage: code-preloader init [options]\n",
        "Global options:"
      ].join("\n")

      parser.separator "\nInit options:"
      parser.unknown_args do |remaining_args, _|
        # FIXME: detect and make error if there are more or less than one
        remaining_args.each do |arg|
          @init_options.try &.config_path = arg
        end
      end

      parser.on(
        "-c FILE", 
        "--config=FILE", 
        "Load parameters from FILE"
      ) do |config_file|
        @init_options.try { |opt| opt.config_path = config_file }
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

      # complete_with "code-preloader init", parser
    end

    def parse_pack_options(parser) 
      @pack_options = PackOptions.new

      config_file = detect_config_file
      config_file.try { |path| load_pack_config(path) }

      parser.banner = [
        "Usage: code-preloader pack [options] DIR ...\n",
        "Global options:"
      ].join("\n")

      parser.separator "\nPack options:"

      parser.on(
        "-c FILE", 
        "--config=FILE", 
        "Load parameters from FILE\n(default: \".code_preload.yml\", if present)"
      ) do |config_file|
        @pack_options.try { |opt| load_pack_config(config_file) }
      end

      parser.on(
        "-F FILE", 
        "--prompt-footer=FILE", 
        "Load prompt footer from FILE (default: none)"
      ) do |prompt_footer_path|
        @pack_options.try { |opt| opt.prompt_footer_path = prompt_footer_path }
      end

      parser.on(
        "-H FILE", 
        "--prompt-header=FILE", 
        "Load prompt header from FILE (default: none)"
      ) do |prompt_header_path|
        @pack_options.try { |opt| opt.prompt_header_path = prompt_header_path }
      end

      parser.on(
        "-i REGEXP", 
        "--ignore=REGEXP", 
        "Ignore file or directory. Can be used\nmultiple times (default: none)"
      ) do |ignore_file|
        @pack_options.try { |opt| opt.ignore_list << ignore_file }
      end

      parser.on(
        "-o FILE", 
        "--output=FILE", 
        "Write output to FILE (default: \"-\", STDOUT)"
      ) do |output_file|
        @pack_options.try { |opt| opt.output_path = output_file }
      end

      parser.on(
        "-t FILE", 
        "--template=FILE", 
        "Load template from FILE (default: internal)"
      ) do |prompt_template_path|
        @pack_options.try { |opt| opt.prompt_template_path = prompt_template_path }
      end

      parser.separator ""

      parser.unknown_args do |remaining_args, _|
        remaining_args.each do |arg|
          @pack_options.try { |opt| opt.source_list << arg }
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

      # complete_with "code-preloader pack", parser
    end

    def parse_arguments(args : Array(String))
      @parser = OptionParser.new do |parser|
        parser.banner = [
          "Usage: code-preloader <subcommand> [options] [DIR] [...]\n",
          "Global options:"
        ].join("\n")

        parser.on("-h", "--help", "Show this help") do
          @subcommand = Subcommand::Help
          @help_options = HelpOptions.new
          @help_options.try do |opts|
            opts.parser_snapshot = parser.dup
          end
        end

        parser.on("-v", "--verbose", "Enable verbose mode") do
          @verbose = true
        end

        parser.on("--version", "Show version") do
          @subcommand = Subcommand::Version
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

        # complete_with "code-preloader", parser
      end

      @parser.try &.parse(args)
      validate
    end

    def detect_config_file() : String?
      home_dir = ENV["HOME"]
      possible_files = [
        File.join(".code_preloader.yaml"),
        File.join(".code_preloader.yml"),
        File.join(home_dir, ".config", "code_preloader", "config.yaml"),
        File.join(home_dir, ".config", "code_preloader", "config.yml"),
        File.join(home_dir, ".config", "code_preloader.yaml"),
        File.join(home_dir, ".config", "code_preloader.yml"),
        File.join("/etc", "code_preloader", "config.yaml"),
        File.join("/etc", "code_preloader", "config.yml"),
      ]

      possible_files.each do |file_path|
        return file_path if File.exists?(file_path)
      end

      return nil
    end

    private def validate
      case @subcommand
      when Subcommand::Init then validate_init
      when Subcommand::Pack then validate_pack
      when Subcommand::None, Subcommand::Help, Subcommand::Version
        # do nothing
      else
        abort("Unknown subcommand #{@subcommand}")
      end
    end

    private def validate_init
      abort("No init options defined!") if @init_options.nil?
    end

    private def validate_pack
      opts = @pack_options
      abort("No pack options defined!") if opts.nil?
      abort("Missing repository path.") if opts.source_list.empty?
    end

    # Reads and returns a list of paths to ignore from the given file.
    def self.get_ignore_list(ignore_path : String) : Array(String)
      File.exists?(ignore_path) ? File.read_lines(ignore_path).map(&.strip) : [] of String
    rescue e : IO::Error
      STDERR.puts "Error reading ignore file: #{e.message}"
      exit(1)
    end

    private def load_pack_config(config_path : String)
      opts = @pack_options
      abort("No pack options defined!") if opts.nil?

      config_str = File.read(config_path)
      root = Models::RootConfig.from_yaml(config_str)

      opts.config_path = config_path
      if opts.source_list.nil? || opts.source_list.try &.empty?
        root.source_list.try { |value| opts.source_list = value }
      end
      if opts.ignore_list.nil? || opts.ignore_list.try &.empty?
        root.ignore_list.try { |value| opts.ignore_list = value }
      end
      if opts.output_path.nil?
        opts.output_path = root.output_path 
      end
      if opts.prompt_header_path.nil?
        root.prompt.try &.header_path.try { |value| opts.prompt_header_path = value }
      end
      if opts.prompt_footer_path.nil?
        root.prompt.try &.footer_path.try { |value| opts.prompt_footer_path = value }
      end
      if opts.prompt_template_path.nil?
        root.prompt.try &.template_path.try { |value| opts.prompt_template_path = value }
      end

    rescue ex : Exception
      STDERR.puts "Failed to load config file: #{ex.message}"
      exit(1)
    end
  end
end

