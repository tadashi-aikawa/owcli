owcli
=====

[![pypi](https://img.shields.io/pypi/v/owcli.svg)](https://pypi.org/project/owcli/)
[![versions](https://img.shields.io/pypi/pyversions/owcli.svg)](https://pypi.org/project/owcli/)
[![Actions Status](https://github.com/tadashi-aikawa/owcli/workflows/Tests/badge.svg)](https://github.com/tadashi-aikawa/owcli/actions)
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)](https://github.com/tadashi-aikawa/owcli/blob/master/LICENSE)

CLI framework which supports both command and subcommand based on [docopt].

[docopt]: http://docopt.org/


## Install

```
$ pip install owcli
```


## Quick start

Create owcli project.

```
$ owcli init <app_name> --python <python_version>
```

Run

```
$ cd <app_name>
$ pipenv install
$ pipenv run python <app_name>/main.py --help
```

### Concrete example

```bash
$ owcli init testapp --python 3.13
------------------------
| Create entries...    |
------------------------
📂 /mnt/c/Users/syoum/git/github.com/tadashi-aikawa/owcli/testapp
 ∟📄 Pipfile
 ∟📄 README.md
 ∟📄 setup.py
 ∟📂 testapp
   ∟📂 commands
     ∟📂 cmd1
       ∟📄 main.py
       ∟📄 __init__.py
     ∟📂 cmd2
       ∟📄 main.py
       ∟📂 subcmd1
         ∟📄 main.py
         ∟📄 __init__.py
       ∟📂 subcmd2
         ∟📄 main.py
         ∟📄 __init__.py
       ∟📄 __init__.py
     ∟📄 __init__.py
   ∟📄 main.py
   ∟📄 __init__.py

------------------------
| Next you have to ... |
------------------------
.
.

$ cd testapp
$ pipenv install
$ pipenv shell
$ python testapp/main.py --help
Usage:
  testapp <command> [<subcommand>] [<args>...]
  testapp <command> [<subcommand>] (-h | --help)
  testapp (-h | --help)
  testapp --version

Commands:
  cmd1                Command1
  cmd2                Command2

$ python testapp/main.py cmd2 -h
Usage:
  testapp cmd2 [<subcommand>] [<args>...]
  testapp cmd2 (-h | --help)

Subcommands:
  subcmd1                       Subcommand1
  subcmd2                       Subcommand2

$ python testapp/main.py cmd2 subcmd1 --help
Subcommand1

Usage:
  testapp cmd2 subcmd1 <names>... [-f|--flag]
  testapp cmd2 subcmd1 (-h | --help)

Options:
  <names>...                           Names
  -f --flag                            Flag
  -h --help                            Show this screen.
  
$ python testapp/main.py cmd2 subcmd1 hoge hoga hogu -f
flag: true
names:
  - hoge
  - hoga
  - hogu
```

## For developer

### Requirements

* uv
* make
* bats

### Commands


#### Integration test

```
$ make test-cli
```

## 📦 Release

https://github.com/tadashi-aikawa/owcli/actions/workflows/release.yaml?query=workflow%3ARelease

## Licence

### MIT

This software is released under the MIT License, see LICENSE.txt.

