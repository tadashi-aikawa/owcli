owcli
=====

[![versions](https://img.shields.io/pypi/pyversions/owcli.svg)]()
[![pypi](https://img.shields.io/pypi/v/owcli.svg)]()
[![license](https://img.shields.io/github/license/mashape/apistatus.svg)]()

CLI framework which supports both command and subcommand.


Install
-------

```
$ pip install owcli
```


Quick start
-----------

Create owcli project.

```
$ owcli init <app_name>
```

Run

```
$ cd <app_name>
$ <app_name>/main.py --help
```

### Concrete example

```bash
$ owcli init testapp
------------------------
| Create entries...    |
------------------------
📂 /home/tadashi-aikawa/tmp/lihoge/testapp
 ∟📄 Pipfile
 ∟📂 testapp

------------------------
| Next you have to ... |
------------------------
.
.

$ cd testapp
$ testapp/main.py --help
Usage:
  testapp <command> [<subcommand>] [<args>...]
  testapp <command> [<subcommand>] (-h | --help)
  testapp (-h | --help)
  testapp --version

Commands:
  cmd1                Command1
  cmd2                Command2

$ testapp/main.py cmd2
Usage:
  testapp cmd2 [<subcommand>] [<args>...]
  testapp cmd2 (-h | --help)

Subcommands:
  subcmd1                       Subcommand1
  subcmd2                       Subcommand2

$ testapp/main.py cmd2 subcmd1 --help
Subcommand1

Usage:
  testapp cmd2 subcmd1 <names>... [-f|--flag]
  testapp cmd2 subcmd1 (-h | --help)

Options:
  <names>...                           Names
  -f --flag                            Flag
  -h --help                            Show this screen.
  
$ testapp/main.py cmd2 subcmd1 hoge hoga hogu -f
flag: true
names:
  - hoge
  - hoga
  - hogu
```




For developer
-------------

### Requirements

* pipenv
* make
* bats

### Commands

#### Create and activate env

```
$ make init
$ pipenv shell
```

#### Integration test

```
$ make test-cli
```


### Version up

#### Confirm that your branch name equals release version

```
$ make release
```

Finally, create pull request and merge to master!!


Licence
-------

### MIT

This software is released under the MIT License, see LICENSE.txt.

