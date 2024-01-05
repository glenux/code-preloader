require "./spec_helper"
require "../src/config"

CONFIG_FILE_SIMPLE = "spec/config_data/simple_config.yml"
CONFIG_FILE_COMPLEX = "spec/config_data/complex_config.yml"

alias Config = CodePreloader::Config
describe CodePreloader::Config do

  context "Initialization" do
    it "initializes with default values" do
      config = Config.new
      config.pack_options.should be_nil
      config.init_options.should be_nil
    end
  end

  context "Handles global arguments" do
    it "parses version option correctly" do
      args = ["--version"]
      config = Config.new
      config.parse_arguments(args)
      config.subcommand == Config::Subcommand::Version
      config.pack_options.should be_nil
      config.init_options.should be_nil
    end

    it "parses help options correctly" do
      args = ["-h"]
      config = Config.new
      config.parse_arguments(args)
      config.subcommand.should eq(Config::Subcommand::Help)
      config.pack_options.should be_nil
      config.init_options.should be_nil

      args = ["--help"]
      config = Config.new
      config.parse_arguments(args)
      config.subcommand.should eq(Config::Subcommand::Help)
      config.pack_options.should be_nil
      config.init_options.should be_nil
    end
  end

  context "Handles pack arguments" do
    it "parses repository paths correctly" do
      args = ["pack", "path/to/repo1", "path/to/repo2"]
      config = Config.new
      config.parse_arguments(args)
      config.subcommand.should eq(Config::Subcommand::Pack)
      config.pack_options.should be_truthy
      config.pack_options.try do |opts| 
        opts.source_list.should eq ["path/to/repo1", "path/to/repo2"]
      end
    end

    it "parses ignore paths correctly" do
      args = ["pack", "-i", "path/to/ignore", "path/to/repo"]
      config = Config.new
      config.parse_arguments(args)
      config.subcommand.should eq(Config::Subcommand::Pack)
      config.pack_options.should be_truthy
      config.pack_options.try do |opts|
        opts.ignore_list.should eq ["path/to/ignore"]
      end
    end

    it "parses output file path correctly" do
      args = ["pack", "-o", "output.txt", "path/to/repo"]
      config = Config.new
      config.parse_arguments(args)
      config.subcommand.should eq(Config::Subcommand::Pack)
      config.pack_options.should be_truthy
      config.pack_options.try do |opts|
        opts.output_path.should eq "output.txt"
      end
    end

  end


  context "loads config file" do
    it "loads settings from a simple config file" do
      config = Config.new
      args = ["pack", "-c", CONFIG_FILE_SIMPLE, "path/to/repo"]
      config.parse_arguments(args)
      
      # Assuming the simple_config.yml has specific settings
      config.pack_options.should be_truthy
      config.pack_options.try do |opts|
        opts.source_list.should eq ["path/to/repo"]
        opts.ignore_list.should eq ["simple/ignore"]
        opts.output_path.should eq "simple_output.txt"
      end
    end

    it "loads settings from a complex config file" do
      repo_path ="path/to/repo"
      config = Config.new
      args = ["pack", "-c", CONFIG_FILE_COMPLEX, repo_path]
      config.parse_arguments(args)
      
      # Assuming the complex_config.yml has specific settings
      config.pack_options.should be_truthy
      config.pack_options.try do |opts|
        opts.source_list.should eq [repo_path]
        opts.ignore_list.should eq ["complex/ignore1", "complex/ignore2"]
        opts.output_path.should eq "complex_output.txt"
      end
    end

  end

end
