
# vim: set ts=2 sw=2 et ft=crystal:

require "colorize"
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
      @config.detect_config()
      @config.parse_arguments(args)
    end

      # Executes the main functionality of the CLI application.
    def exec
      case @config.subcommand
      when Config::Subcommand::Init then exec_init(@config.init_options)
      when Config::Subcommand::Pack then exec_pack(@config.pack_options)
      when Config::Subcommand::Version then exec_version
      when Config::Subcommand::Help then exec_help
      when Config::Subcommand::None then exec_none
      else
        abort("Unknown subcommand #{@config.subcommand}!")
      end
    end

    def exec_init(init_options)
      abort("Unexpected nil value for init_options!") if init_options.nil?

      # Default path for the .code_preloader.yml file
      default_config_path = "example.code_preloader.yml"

      # Use the specified path if provided, otherwise use the default
      config_file_path = init_options.config_file_path || default_config_path

      # Content of the .code_preloader.yml file
      config_content = [
        "---",
        "# Example configuration for Code-Preloader",
        "",
        "# List of repository paths to preload",
        "# repository_path_list:",
        "#   - \"path/to/repo1\"",
        "#   - \"path/to/repo2\"",
        "",
        "# List of patterns to ignore during preloading",
        "ignore_list:",
        "  - ^\\.git/.*",
        "",
        "# Path to the output file (if null, output to STDOUT)",
        "output_file_path: null",
        "",
        "# Optional: Path to a file containing the header prompt",
        "header_prompt_file_path: null",
        "",
        "# Optional: Path to a file containing the footer prompt",
        "footer_prompt_file_path: null",
        ""
      ].join("\n")

      # Writing the configuration content to the file
      File.write(config_file_path, config_content)
      puts "Configuration file created at: #{config_file_path}"
    rescue e : Exception
      abort("ERROR: Unable to create the configuration file: #{e.message}")
    end
    
    def exec_version
      puts "#{PROGRAM_NAME} v#{VERSION}"
      exit(0)
    end

    def exec_none
      STDERR.puts @config.parser
      abort("ERROR: No command specified!")
    end

    def exec_help
      puts @config.parser
      exit(0)
    end

    def exec_pack(pack_options)
      abort("Unexpected nil value for pack_options!") if pack_options.nil?

      preloaded_content = {} of String => NamedTuple(mime: String, content: String)
      output_file_path = pack_options.output_file_path
      repository_path_list = pack_options.repository_path_list
      header_prompt_file_path = pack_options.header_prompt_file_path
      footer_prompt_file_path = pack_options.footer_prompt_file_path
      regular_output_file = false
      header_prompt = ""
      footer_prompt = ""

      filelist = FileList.new()
      filelist.add(repository_path_list)
      pack_options.ignore_list.each do |ignore_pattern|
        filelist.reject { |path| !!(path =~ Regex.new(ignore_pattern)) }
      end

      if !header_prompt_file_path.nil?
        STDERR.puts "Loading header prompt from: #{header_prompt_file_path}".colorize(:yellow)
        header_prompt = File.read(header_prompt_file_path)
      end

      if !footer_prompt_file_path.nil?
        STDERR.puts "Loading footer prompt from: #{footer_prompt_file_path}".colorize(:yellow)
        footer_prompt = File.read(footer_prompt_file_path)
      end

      output_file = STDOUT
      output_file_path.try do |path|
        break if path.empty?
        break if path == "-"
        regular_output_file = true
        output_file = File.open(path, "w")
      end
      STDERR.puts "Writing output to: #{regular_output_file ? output_file_path : "stdout" }".colorize(:yellow)


      header_prompt_file_path.try { output_file.puts header_prompt }

      STDERR.puts "Processing repository: #{repository_path_list}".colorize(:yellow)
      filelist.each do |file_path|
        STDERR.puts "Processing file: #{file_path}".colorize(:yellow)
        file_result = process_file(file_path, output_file)

        output_file.puts "@@ File \"#{file_path}\" (Mime-Type: #{file_result[:mime]})"
        output_file.puts ""
        if file_result[:text_content] !~ /^\s*$/
          output_file.puts(file_result[:text_content])
          output_file.puts ""
        end
      end

      footer_prompt_file_path.try { output_file.puts footer_prompt }

      output_file.close if regular_output_file
      STDERR.puts "Processing completed.".colorize(:yellow)

    rescue e : Exception
      STDERR.puts "An error occurred during execution: #{e.message}"
      exit(1)
    end

    private def process_file(file_path : String, output_file : IO::FileDescriptor)
      mime = ""
      clean_content = ""
      File.open(file_path) do |fh|
        mime = Magic.mime_type.of(fh)
        clean_content = (
          fh.gets_to_end
          .strip
          .gsub(/\n\s*\n\s*\n/,"\n\n")
        )
      end

      return {
        mime: mime,
        text_content: clean_content
      }
    end
  end
end
