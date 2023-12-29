# README

code-preloader is a tool that helps preloading all files for a given root directory
and concatenates them as a single file.

## Structure of the output file

```jinja2
{{ HEADER_PROMPT_FILE }}

{% for file in file_list %}
@@ File "{{ file.path }}"
{{ file.content }}
{% endfor %}

{{ FOOTER_PROMPT_FILE }}
```

## Usage

```
Usage: code-preloader [options] ROOT_DIR

Options:
  -c, --config=CONFIG_FILE              Load parameters from CONFIG_FILE (ignore, output, etc.)
  -i, --ignore=IGNORE_FILE              Ignore file or directory path (not a pattern)
  -o, --output=OUTPUT_FILE              Write output to OUTPUT_FILE (default to stdout if option missing or OUTPUT_FILE is "-")
  --header-prompt=HEADER_PROMPT_FILE     Load header prompt from PROMPT_FILE
  --footer-prompt=FOOTER_PROMPT_FILE    Load footer prompt from PROMPT_FILE
  --version                             Show version
  -v, --verbose                         Enable verbose mode
  -h, --help                            Show this help
```

