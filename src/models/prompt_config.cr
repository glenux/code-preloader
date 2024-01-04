
require "yaml"

module CodePreloader::Models
  class PromptConfig
    include YAML::Serializable
    include YAML::Serializable::Strict

    @[YAML::Field(key: "header_path")]
    getter header_path : String?

    @[YAML::Field(key: "footer_path")]
    getter footer_path : String?

    @[YAML::Field(key: "template_path")]
    getter template_path : String?
  end
end
