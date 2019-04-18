import os
import sys
from importlib import import_module

from docopt import docopt

_DOC_TMPL_ = """
Usage:
  {cli} <command> [<subcommand>] [<args>...]
  {cli} [<command>] (-h | --help)
  {cli} --version

Commands:
{commands}
"""

_DOC_COMMAND_TMPL_ = """
Usage:
  {cli} {command} [<subcommand>] [<args>...]
  {cli} {command} (-h | --help)

Subcommands:
{subcommands}
"""


def command_not_found_format(command: str) -> str:
    return f"""
Command `{command}` is not found.
Show available commands.
-------------------------------------
"""


def subcommand_not_found_format(subcommand: str, command: str) -> str:
    return f"""
Subcommand `{subcommand}` is not found in `{command}` command.
Show available subcommands.
---------------------------------------
"""


def first_line_in_doc(module) -> str:
    return module.__doc__.split("\n")[0]


def run(cli: str, version: str, root: str):
    """
    :param cli: CLI file name
    :param version: version
    :param root: root package path

    Example:
        ----
        docowl.run(cli="gtfs", version=VERSION, root='gtfsandbox')
        ----
    """
    # Remove <args> to avoid parse errors.
    root_dir = os.path.abspath(f"{os.path.dirname(__file__)}/../{root}")
    commands = [f'  {x:20}{first_line_in_doc(import_module(root+".commands."+x+".main"))}'
                for x
                in os.listdir(f'{root_dir}/commands')
                if os.path.isdir(f'{root_dir}/commands/{x}')]

    doc = _DOC_TMPL_.format(cli=cli, commands='\n'.join(commands))
    main_args = docopt(doc, argv=sys.argv[1:3], version=version, options_first=True)

    command: str = main_args.pop('<command>')
    try:
        cmd_module = import_module(f'{root}.commands.{command}.main')
    except ModuleNotFoundError:
        print(command_not_found_format(command))
        print(doc)
        sys.exit(1)

    subcommand: str = main_args.pop('<subcommand>')
    # Show global docs and abort
    if subcommand in ["-h", "--help", None]:
        command_dir = os.path.abspath(f"{os.path.dirname(__file__)}/../{root}/commands/{command}")
        subcommands = [f'  {x:20}          {first_line_in_doc(import_module(root+".commands."+command+"."+x+".main"))}'
                       for x
                       in os.listdir(f'{root_dir}/commands/{command}')
                       if os.path.isdir(f'{root_dir}/commands/{command}/{x}')]

        if subcommands:
            command_doc = _DOC_COMMAND_TMPL_.format(cli=cli, command=command, subcommands='\n'.join(subcommands))
            print(command_doc)
        else:
            print(cmd_module.__doc__.format(cli=cli))
        sys.exit(0)

    try:
        # Run without subcommand if there are no subcommands
        cmd_module.run(
            cmd_module.Args.from_dict(docopt(cmd_module.__doc__.format(cli=cli)), restrict=False, force_cast=True)
        )
    except AttributeError:
        # Subcommand exists
        try:
            sub_cmd_module = import_module(f'gtfsandbox.commands.{command}.{subcommand}.main')
            sub_cmd_module.run(
                sub_cmd_module.Args.from_dict(docopt(sub_cmd_module.__doc__.format(cli=cli)), restrict=False, force_cast=True)
            )
        except AttributeError as e:
            print(e)
            print(subcommand_not_found_format(subcommand, command))
            print(cmd_module.__doc__.format(cli=cli))
            sys.exit(1)
        except ModuleNotFoundError as e:
            print(e)
            print(subcommand_not_found_format(subcommand, command))
            print(cmd_module.__doc__.format(cli=cli))
            sys.exit(1)
