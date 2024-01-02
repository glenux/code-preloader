require "./spec_helper"
require "../src/config"

CONFIG_FILE_SIMPLE = "spec/config_data/simple_config.yml"
CONFIG_FILE_COMPLEX = "spec/config_data/complex_config.yml"

describe CodePreloader::Config do

  context "Initialization" do
    it "initializes with default values" do
      config = CodePreloader::Config.new
      config.repository_path_list.should eq [] of String
      config.ignore_list.should eq [] of String
      config.output_file_path.should be_nil
      config.header_prompt_file_path.should be_nil
      config.footer_prompt_file_path.should be_nil
    end
  end

  context "Parse Arguments" do
    it "parses repository paths correctly" do
      args = ["path/to/repo1", "path/to/repo2"]
      config = CodePreloader::Config.new
      config.parse_arguments(args)
      config.repository_path_list.should eq ["path/to/repo1", "path/to/repo2"]
    end

    it "parses ignore paths correctly" do
      args = ["-i", "path/to/ignore", "path/to/repo"]
      config = CodePreloader::Config.new
      config.parse_arguments(args)
      config.ignore_list.should eq ["path/to/ignore"]
    end

    it "parses output file path correctly" do
      args = ["-o", "output.txt", "path/to/repo"]
      config = CodePreloader::Config.new
      config.parse_arguments(args)
      config.output_file_path.should eq "output.txt"
    end

  end


  context "Config File Loading" do
    it "loads settings from a simple config file" do
      config = CodePreloader::Config.new
      args = ["-c", CONFIG_FILE_SIMPLE, "path/to/repo"]
      config.parse_arguments(args)
      
      # Assuming the simple_config.yml has specific settings
      config.repository_path_list.should eq ["simple/repo/path"]
      config.ignore_list.should eq ["simple/ignore"]
      config.output_file_path.should eq "simple_output.txt"
      # ... assertions for other properties if needed ...
    end

    it "loads settings from a complex config file" do
      repo_path ="path/to/repo"
      config = CodePreloader::Config.new
      args = ["-c", CONFIG_FILE_COMPLEX, repo_path]
      config.parse_arguments(args)
      
      # Assuming the complex_config.yml has specific settings
      config.repository_path_list.should eq [repo_path]
      config.ignore_list.should eq ["complex/ignore1", "complex/ignore2"]
      config.output_file_path.should eq "complex_output.txt"
    end

  end

end
