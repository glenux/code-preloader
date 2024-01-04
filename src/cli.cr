require "colorize"
require "file"
require "option_parser"
require "magic"
require "crinja"

require "./config"
require "./filelist"

# The CodePreloader module organizes classes and methods related to preloading code files.
module CodePreloader
  # The Cli class handles command-line interface operations for the CodePreloader.

  class Cli
    alias ProcessedFile = NamedTuple(path: String, content: String, mime_type: String)

    @config : Config

    # Initializes the Cli class with default values.
    def initialize(args)
      @output_path = ""
      @config = Config.new()
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
      config_path = init_options.config_path || default_config_path

      # Content of the .code_preloader.yml file
      config_content = [
        "---",
        "# Example configuration for Code-Preloader",
        "",
        "# List of repository paths to preload",
        "# source_list:",
        "#   - \"path/to/repo1\"",
        "#   - \"path/to/repo2\"",
        "",
        "# List of patterns to ignore during preloading",
        "ignore_list:",
        "  - ^\\.git/.*",
        "",
        "# Path to the output file (if null, output to STDOUT)",
        "output_path: null",
        "",
        "# Optional: Path to a file containing the header prompt",
        "header_path: null",
        "",
        "# Optional: Path to a file containing the footer prompt",
        "footer_path: null",
        ""
      ].join("\n")

      # Writing the configuration content to the file
      File.write(config_path, config_content)
      puts "Configuration file created at: #{config_path}"
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
      @config.help_options.try do |opts|
        puts opts.parser_snapshot
      end
      exit(0)
    end

    def exec_pack(pack_options)
      abort("Unexpected nil value for pack_options!") if pack_options.nil?

      preloaded_content = {} of String => NamedTuple(mime: String, content: String)
      config_path = pack_options.config_path
      output_path = pack_options.output_path
      source_list = pack_options.source_list
      prompt_header_path = pack_options.prompt_header_path
      prompt_footer_path = pack_options.prompt_footer_path
      prompt_template_path = pack_options.prompt_template_path
      regular_output_file = false
      prompt_header_content = nil
      prompt_footer_content = nil
      prompt_template_content = ""
      STDERR.puts "Loading config file from: #{config_path}".colorize(:yellow)

      filelist = FileList.new()
      filelist.add(source_list)
      pack_options.ignore_list.each do |ignore_pattern|
        filelist.reject { |path| !!(path =~ Regex.new(ignore_pattern)) }
      end

      abort("No prompt file defined!") if prompt_template_path.nil?
      prompt_template_content = File.read(prompt_template_path)


      if !prompt_header_path.nil?
        STDERR.puts "Loading header prompt from: #{prompt_header_path}".colorize(:yellow)
        prompt_header_content = File.read(prompt_header_path)
      end

      if !prompt_footer_path.nil?
        STDERR.puts "Loading footer prompt from: #{prompt_footer_path}".colorize(:yellow)
        prompt_footer_content = File.read(prompt_footer_path)
      end

      output_file = STDOUT
      output_path.try do |path|
        break if path.empty?
        break if path == "-"
        regular_output_file = true
        output_file = File.open(path, "w")
      end
      STDERR.puts "Writing output to: #{regular_output_file ? output_path : "stdout" }".colorize(:yellow)

      # FIXME: prompt_header_path.try { output_file.puts prompt_header_content }

      STDERR.puts "Processing source directories: #{source_list}".colorize(:yellow)
      processed_files = [] of ProcessedFile
      filelist.each do |file_path|
        STDERR.puts "Processing file: #{file_path}".colorize(:yellow)
        file_result = process_file(file_path, output_file)
        processed_files << file_result
      end

      # FIXME: prompt_footer_path.try { output_file.puts prompt_footer_content }

      output_file.puts Crinja.render(
        prompt_template_content, 
        { 
          "prompt_header": prompt_header_content,
          "prompt_files": processed_files,
          "prompt_footer": prompt_footer_content
        }
      ) 

      output_file.close if regular_output_file
      STDERR.puts "Processing completed.".colorize(:yellow)

    rescue e : Exception
      STDERR.puts "ERROR: #{e.message}"
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
        path: file_path,
        content: clean_content,
        mime_type: mime
      }
    end
  end
end
