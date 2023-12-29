# Code-Preloader for ChatGPT

Welcome to Code-Preloader, a tool designed to enhance the efficiency of ChatGPT
by preloading all files within a specified root directory and concatenating
them into a single file. This tool is particularly useful for preparing smaller
codebases for processing by ChatGPT, as it allows for the inclusion of
customized prompts through header and footer files.

## Features

* Preload and concatenate files from a given directory.
* Customizable header and footer prompts for ChatGPT.
* Simple command-line interface for easy operation.

## Limitations

**Note:** Code-Preloader is only suitable for smaller codebas. ChatGPT may not
perform as expected with large code repositories.

## Installation

To get started with Code-Preloader, ensure that you have Crystal language installed on your system. Follow these steps to install:

```bash
git clone https://github.com/your-repository/code-preloader.git
cd code-preloader
shards install
shards build
```

## Usage

Run Code-Preloader with the following command-line options:

```
Usage: code-preloader [options] ROOT_DIR

Options:
  -c, --config=CONFIG_FILE              Load parameters from CONFIG_FILE (not implemented yet)
  -i, --ignore=IGNORE_FILE              Ignore file or directory path
  -o, --output=OUTPUT_FILE              Write output to OUTPUT_FILE (default to stdout)
  --header-prompt=HEADER_PROMPT_FILE     Load header prompt from PROMPT_FILE
  --footer-prompt=FOOTER_PROMPT_FILE    Load footer prompt from PROMPT_FILE
  --version                             Show version
  -v, --verbose                         Enable verbose mode
  -h, --help                            Show this help
```

### Examples

To preload all files in the `src` directory and output to `result.txt`, while
ignoring the `git` the `bin` directory, and the result file itself:

```bash
./bin/code-preloader -o result.txt -i .git -i result.txt -i bin/ src
```

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

- Special thanks to all contributors and users of this project!

