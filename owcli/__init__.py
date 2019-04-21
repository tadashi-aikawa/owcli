import os
import sys
from importlib import import_module
from typing import List

from docopt import docopt

_DOC_TMPL_ = """Usage:
  {cli} <command> [<subcommand>] [<args>...]
  {cli} <command> [<subcommand>] (-h | --help)
  {cli} (-h | --help)
  {cli} --version

Commands:
{commands}
"""

_DOC_COMMAND_TMPL_ = """Usage:
  {cli} {command} [<subcommand>] [<args>...]
  {cli} {command} (-h | --help)

Subcommands:
{subcommands}
"""


def command_not_found_format(command: str, commands: List[str]) -> str:
    cmds = '\n'.join(commands)
    return f"""
| Command `{command}` is not found.
| Show available commands.
`{'-' * 79}

{cmds}"""


def subcommand_not_found_format(subcommand: str, command: str, subcommands: List[str]) -> str:
    cmds = '\n'.join(subcommands)
    return f"""
| Subcommand `{subcommand}` is not found in `{command}` command.
| Show available subcommands.
`{'-' * 79}

{cmds}"""


def first_line_in_doc(module) -> str:
    return module.__doc__.split("\n")[0]


def run(cli: str, version: str, root: str):
    """
    :param cli: CLI file name
    :param version: Version
    :param root: Absolute path for root

    Example:
        ----
        docowl.run(cli="gtfs", version=__version__, root=os.path.dirname(os.path.realpath(__file__)))
        ----
    """
    root_dirname = os.path.basename(root)
    # Remove <args> to avoid parse errors.
    commands = [f'  {x:20}{first_line_in_doc(import_module(root_dirname + ".commands." + x + ".main"))}'
                for x
                in os.listdir(f'{root}/commands')
                if os.path.isdir(f'{root}/commands/{x}') and not x.startswith('_')]

    doc = _DOC_TMPL_.format(cli=cli, commands='\n'.join(commands))
    main_args = docopt(doc, argv=sys.argv[1:3], version=version, options_first=True)

    command: str = main_args.pop('<command>')
    if command in ["-h", "--help", None]:
        print(doc)
        sys.exit(1)

    try:
        cmd_module = import_module(f'{root_dirname}.commands.{command}.main')
    except ModuleNotFoundError:
        print(command_not_found_format(command, commands))
        sys.exit(1)

    subcommand: str = main_args.pop('<subcommand>')
    subcommands = [
        f'  {x:20}          {first_line_in_doc(import_module(root_dirname + ".commands." + command + "." + x + ".main"))}'
        for x
        in os.listdir(f'{root}/commands/{command}')
        if os.path.isdir(f'{root}/commands/{command}/{x}') and not x.startswith('_')]

    # Show global docs and abort
    if subcommand in ["-h", "--help", None]:
        if subcommands:
            command_doc = _DOC_COMMAND_TMPL_.format(cli=cli, command=command, subcommands='\n'.join(subcommands))
            print(command_doc)
        else:
            print(cmd_module.__doc__.format(cli=f"{cli} {command}"))
        sys.exit(0)

    # Run without subcommand if there are no subcommands
    if hasattr(cmd_module, "run"):
        cmd_module.run(
            cmd_module.Args.from_dict(
                docopt(cmd_module.__doc__.format(cli=f"{cli} {command}")), restrict=False, force_cast=True
            )
        )
        sys.exit(0)

    # Subcommand exists
    try:
        sub_cmd_module = import_module(f'{root_dirname}.commands.{command}.{subcommand}.main')
    except ModuleNotFoundError:
        print(subcommand_not_found_format(subcommand, command, subcommands))
        sys.exit(1)

    if hasattr(sub_cmd_module, "run"):
        sub_cmd_module.run(
            sub_cmd_module.Args.from_dict(
                docopt(sub_cmd_module.__doc__.format(cli=f"{cli} {command} {subcommand}")), restrict=False,
                force_cast=True
            )
        )
        sys.exit(0)

    print(f"Subcommand `{subcommand}` doesn't has `run` function.")
    sys.exit(1)
