# Code-Preloader for ChatGPT

Code-Preloader is a specialized tool designed to streamline the process of
working with ChatGPT on coding projects. It preloads and concatenates files
from a specified directory, allowing for the seamless integration of customized
prompts. This tool is ideal for those who seek an alternative to tools like
GitHub Copilot, enabling a more efficient and tailored interaction with
ChatGPT.

## Features

* Preload and concatenate files from a given directory.
* Customizable header and footer prompts for ChatGPT.
* Simple command-line interface for easy operation.

## Limitations

**Note:** Note: This tool is optimized for smaller codebases. For larger
repositories, performance may not be optimal due to processing constraints and
the nature of interactions with ChatGPT.

## Installation

To get started with Code-Preloader, ensure that you have Crystal language installed on your system. Follow these steps to install:

```bash
git clone https://code.apps.glenux.net/glenux/chatgpt-preloader
cd code-preloader
shards install
shards build
```

## Usage

Run Code-Preloader with the following command-line options:

```
Usage: code-preloader [options] ROOT_DIR
    -c CONFIG_FILE, --config=CONFIG_FILE
                                     Load parameters from CONFIG_FILE
    -i IGNORE_PATH, --ignore=IGNORE_PATH
                                     Ignore file or directory
    -o OUTPUT_FILE, --output=OUTPUT_FILE
                                     Write output to OUTPUT_FILE
    -H HEADER_PROMPT_FILE, --header-prompt=HEADER_PROMPT_FILE
                                     Load header prompt from HEADER_PROMPT_FILE
    -F FOOTER_PROMPT_FILE, --footer-prompt=FOOTER_PROMPT_FILE
                                     Load footer prompt from FOOTER_PROMPT_FILE
    -h, --help                       Show this help
```

### Examples

#### Basic Use Case

To preload all files in the `src` directory and output to `result.txt`, while
ignoring the `git` the `bin` directory, and the result file itself:

```bash
./bin/code-preloader -o result.txt -i .git -i result.txt -i bin/ src
```

#### Advanced Use Case

To preload all files in the `src` directory and output to clipboard, prepending
and appending prompts, while ignoring the `git` the `bin` directory, and the
result file itself:

```bash
./bin/code-preloader \
    -o result.txt \
    -i .git -i bin/ -i result.txt -i prompts \
    --header-prompt prompts/header-context.txt \
    --footer-prompt prompts/footer-write-readme.txt \
    src \
    | xclip -selection clipboard -i
```

#### Advanced with configuration file

You can also do the same by storing all parameters within a configuration file
(ex: `code_preloader.yml`).

```
---

ignore_list:
  - .git
  - .code_preloader.yml
  - bin
  - prompts

output_file_path: result.txt

header_prompt_file_path: prompts/header-context.txt

footer_prompt_file_path: prompts/footer-write-readme.txt
```

Then type

```bash
./bin/code-preloader src | xclip -selection clipboard -i
```


## Contributing

Contributions are what make the open-source community such an amazing place to
learn, inspire, and create. Any contributions you make are **greatly
appreciated**.

## Troubleshooting and Support

If you encounter any issues or need support, please open an issue in the
project's GitHub issue tracker. We strive to be responsive and helpful.

## License

Distributed under the LGPL-3.0-or-later License. See `LICENSE` file for more
information.

## Acknowledgments

* A special thanks to all contributors and users of this project for their valuable feedback and support.
* Inspired by the community's need for efficient code preparation tools in the context of AI-assisted programming.

## Related projects

* [mpoon/gpt-repository-loader](https://github.com/mpoon/gpt-repository-loader)

