
require "yaml"
require "./prompt_config"

module CodePreloader::Models
  class RootConfig
    include YAML::Serializable
    include YAML::Serializable::Strict

    @[YAML::Field(key: "source_list")]
    getter source_list : Array(String)?

    @[YAML::Field(key: "output_path")]
    getter output_path : String?

    @[YAML::Field(key: "prompt")]
    getter prompt : PromptConfig?

    @[YAML::Field(key: "ignore_list")]
    getter ignore_list : Array(String)?
  end
end
