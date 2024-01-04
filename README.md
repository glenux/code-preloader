<!--
# SPDX-License-Identifier: LGPL-3.0-or-later
#
# SPDX-FileCopyrightText: 2023 Glenn Y. Rolland <glenux@glenux.net>
# Copyright © 2023 Glenn Y. Rolland <glenux@glenux.net>
-->

[![Build Status](https://cicd.apps.glenux.net/api/badges/glenux/code-preloader/status.svg)](https://cicd.apps.glenux.net/glenux/code-preloader)
![License LGPL3.0-or-later](https://img.shields.io/badge/license-LGPL3.0--or--later-blue.svg)
[![Donate on patreon](https://img.shields.io/badge/patreon-donate-orange.svg)](https://patreon.com/glenux)

> :information_source: This project is available on our self-hosted server and
> on CodeBerg and GitHub as mirrors. For the latest updates and comprehensive
> version of our project, please visit our primary repository at:
> <https://code.apps.glenux.net/glenux/code-preloader>. 

# Code-Preloader

Code-Preloader is a specialized tool designed to streamline the process of
working on coding projects with interactive large language models (LLM) like
ChatGPT, Claude, Mixtral 8x7B, etc. 

It preloads and concatenates files from a specified directory, allowing for the
seamless integration of customized prompts. 

This tool is ideal for those who seek an alternative to tools like GitHub
Copilot, enabling a tailored interaction with your favorite LLM.

## Features

* Preload and concatenate files from a given directory.
* Customizable header and footer prompts for your LLM.
* Simple command-line interface for easy operation.

## Limitations

**Note:** This tool is optimized for smaller codebases. For larger
repositories, performance may not be optimal due to processing constraints and
the nature of interactions with LLMs.

## Prerequisites

Before installing and using Code-Preloader, make sure your system meets the
following requirements:

1. **Crystal Language**: Code-Preloader is written in Crystal. Ensure you have
   the Crystal programming language installed on your system. For installation
   instructions, refer to the [official Crystal language
   website](https://crystal-lang.org/install/).

2. **Required Libraries**: The following libraries are necessary for the proper
   functioning of Code-Preloader:
   * `libevent`: Used for asynchronous event notification.
   * `libyaml`: Required for YAML parsing.
   * `libmagic`: Utilized for file type detection.
   * `make`: Used to define compilation rules

On a Debian-based system, you can install these libraries using the following
command:

```bash
sudo apt-get install libevent-dev libyaml-dev libmagic-dev make
```

## Installation

To get started with Code-Preloader, ensure that you have the prerequisites
installed on your system (see above).

Then follow these steps to install:

```bash
git clone https://code.apps.glenux.net/glenux/code-preloader
cd code-preloader
make prepare
make build
sudo make install                 # either to install system-wide
make install PREFIX=$HOME/.local  # or to install as a user
```

## Usage

### Packing directory content

Run Code-Preloader with the following command-line options:

```
Usage: code-preloader pack [options] DIR ...

Global options:
    --version                        Show version
    -h, --help                       Show this help

Pack options:
    -i REGEXP, --ignore=REGEXP       Ignore file or directory
    -o FILE, --output=FILE           Write output to FILE
    -H FILE, --header-prompt=FILE    Load header prompt from FILE
    -F FILE, --footer-prompt=FILE    Load footer prompt from FILE
    -c FILE, --config=FILE           Load parameters from FILE
```

#### Basic Use Case

To preload all files in the `src` directory and output to `result.txt`, while
ignoring the `git` the `bin` directory, and the result file itself:

```bash
./bin/code-preloader pack -o result.txt -i .git -i result.txt -i bin/ src
```

#### Advanced Use Case

To preload all files in the `src` directory and output to clipboard, prepending
and appending prompts, while ignoring the `git` the `bin` directory, and the
result file itself:

```bash
./bin/code-preloader pack \
    -i .git -i bin/ -i result.txt -i prompts \
    -H prompts/context.txt -F prompts/request-readme.txt \
    src \
    | ctrlc
```

__Note:__ the command `ctrlc` in previous command is an alias to `xclip
-selection clipboard -i`

### Using a config file

You can automatically create an empty configuratio file by running
Code-Preloader with the following command-line options:

```
Usage: code-preloader init [options]

Global options:
    --version                        Show version
    -h, --help                       Show this help

Init options:
    -c FILE, --config=FILE           Load parameters from FILE
```

#### Example: Advanced with configuration file

Create an empty configuration file with

```bash
./bin/code-preloader init -c .code_preloader.yml
```
Adapt the configuration file (`.code_preloader.yml`) to your needs:

```yaml
---
ignore_list:
  - .git
  - code_preloader.yml
  - bin
  - prompts

output_file_path: null
header_prompt_file_path: prompts/context.txt
footer_prompt_file_path: prompts/request-readme.txt
```

Then you can type a shorter command like:

```bash
./bin/code-preloader pack -c .code_preloader.yml src | ctrlc
```

__Note:__ the command `ctrlc` in previous command is an alias to `xclip
-selection clipboard -i`

### Prompting efficiently with CodePreloader

The goal is to maximize the effectiveness of your interactions with large
language models (LLMs) using CodePreloader for software development tasks.

1. **Preload Your Project:** Before starting a new task, ensure you preload your project. This prepares the LLM with the necessary context, making it ready to assist you effectively.
2. **Utilize Structure Separators:** Use "@@" as a delimiter to clearly separate and introduce new content. This could be for final requests, additional files, or other relevant data.
3. **State Your Goals Clearly:** Begin by explicitly informing the LLM of your objectives. A clear and concise explanation of what you aim to achieve helps the model understand your needs better.
4. **Reference Preloaded Files:** If necessary, refer to preloaded files by using "@@ File ...". This directs the LLM's attention to specific parts of your project.
5. **Direct Focus Using Specific Phrasing:** Encourage the LLM to "focus" or "concentrate" on particular elements of the preloaded context, like files, classes, methods, etc. These specific terms have been observed to enhance the model's attention to the relevant details.
6. **Approach the Task in Stages:** Divide your request into multiple stages for clarity and precision:
  * **a. First Request**: Ask the LLM to analyze the content based on your instructions and explain the approach it would take for the changes requested. At this stage, request the LLM to refrain from writing code.
  * **b. Second Request**: Instruct the LLM to focus on both the content and its previous analysis. Request a proposed fixed version of the specific file, class, or method based on the prior analysis. The more detailed your request, the better the outcome. Ask for changes to be made one at a time.
  * **c. Third and Subsequent Requests**: Follow the same pattern as the second request but apply it to different parts of the project that require changes.

#### Example: improving a README.md

First request:

> @@ REQUEST (ANALYZE)
> 
> We want to improve the README.md file as for an open-source project following the best practices.
> 
> Please focus on the code provided in the « @@ File ... » sections and analyze the existing « @@ File "README.md" », then take in account the content of class Config which analyzes the command line.
> 
> In this analysis of the existing « @@ File "README.md" », please provide me with a list of things that you appreciate, a list of things to amplify, a list of things to adjust.

Second request:

> @@ REQUEST (WRITE)
> 
> We want to improve the README.md file as for an open-source project following the best practices.
> 
> Please focus on the code provided in the « @@ File ... » sections and analyze the existing « @@ File "README.md" », then take in account the content of class Config which analyzes the command line.
>
> Please concentrate on the detail of your analysis in your previous message and write a new improved/fixed version of « @@ File "README.md"

#### Example: writing a new feature

First request:

> @@ REQUEST (ANALYZE)
>
> I would like to change CLI parameters structure add add two subcommands:
> * init : which will create an example .code_preloader.yml file (with comments)
> * pack : which will create the packed version of the current directory for LLM prompting
> 
> Most of current options (except --version and --help) must become options of the pack subcommand.
> 
> I already started some changes to achieve this goal, but it is not finished, and I need your help and expert advises.
> 
> Can you please tell me :
> * where the changes should occur (which file? which class? which method?)
> * what kind of changes must be made there?
> 
> Please do not write code yet, simply explain.

Second request:

> @@ REQUEST (WRITE)
>
> I would like to change CLI parameters structure add add two subcommands:
> * init : which will create an example .code_preloader.yml file (with comments)
> * pack : which will create the packed version of the current directory for LLM prompting
> 
> Most of current options (except --version and --help) must become options of the pack subcommand.
>
> Please concentrate on the detail of your analysis in your previous message and write a new improved/fixed version of « @@ File "README.md". Please keep in mind the separation of concerns and the single responsibility principle.
> 
> Please provide me a new version of « File ... » which include the requested change?

## Contributing

Contributions are what make the open-source community such an amazing place to
learn, inspire, and create. Any contributions you make are **greatly
appreciated**.

## Troubleshooting and Support

If you encounter any issues or need support, please open an issue in [the
project's issue
tracker](https://code.apps.glenux.net/glenux/code-preloader/issues). We strive
to be responsive and helpful.

## License

Distributed under the LGPL-3.0-or-later License. See `LICENSE` file for more
information.

## Acknowledgments

* A special thanks to all contributors and users of this project for their valuable feedback and support.
* Inspired by the community's need for efficient code preparation tools in the context of AI-assisted programming.

## Related projects

* [mpoon/gpt-repository-loader](https://github.com/mpoon/gpt-repository-loader)

