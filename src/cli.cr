
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
        "  - \"^\\./\\.git/.*\"",
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
  STDERR.puts "Example configuration file created at: #{config_file_path}"
    rescue e : Exception
      STDERR.puts "An error occurred while creating the configuration file: #{e.message}"
      exit(1)

  end
    
    def exec_version
      abort("FIXME: Not implemented!")
    end

    def exec_none
      abort("No command specified!")
    end

    def exec_help
      abort("FIXME: Not implemented!")
    end

    def exec_pack(pack_options)
      abort("Unexpected nil value for pack_options!") if pack_options.nil?

      output_file_path = pack_options.output_file_path
      repository_path_list = pack_options.repository_path_list
      header_prompt_file_path = pack_options.header_prompt_file_path
      footer_prompt_file_path = pack_options.footer_prompt_file_path
      regular_output_file = false

      filelist = FileList.new()
      filelist.add(repository_path_list)
      pack_options.ignore_list.each do |ignore_pattern|
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

      output_file_path.try do |path|
        break if path.empty?
        break if path == "-"
        regular_output_file = true
        output_file = File.open(path, "w")
      end

      output_file = STDOUT
      header_prompt = ""
      footer_prompt = ""

      output_file.puts header_prompt if header_prompt_file_path

      STDERR.puts "Processing repository: #{repository_path_list}"
      filelist.each do |file_path|
        process_file(file_path, output_file)
      end

      output_file.puts footer_prompt if footer_prompt_file_path

      output_file.close if regular_output_file
      STDERR.puts "Processing completed. Output written to: #{regular_output_file ? output_file_path : "stdout" }"

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
