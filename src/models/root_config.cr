
require "yaml"

module CodePreloader::Models
  class RootConfig
    include YAML::Serializable
    include YAML::Serializable::Strict

    @[YAML::Field(key: "repository_path_list")]
    getter repository_path_list : Array(String)?

    @[YAML::Field(key: "output_file_path")]
    getter output_file_path : String?

    @[YAML::Field(key: "header_prompt_file_path")]
    getter header_prompt_file_path : String?

    @[YAML::Field(key: "footer_prompt_file_path")]
    getter footer_prompt_file_path : String?

    @[YAML::Field(key: "ignore_list")]
    getter ignore_list : Array(String)?
  end
end
