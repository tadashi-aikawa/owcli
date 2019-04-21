"""Command1

Usage:
  {cli} <root>
  {cli} (-h | --help)

Options:
  <root>                               Root directory
  -h --help                            Show this screen.
"""
import os
import shutil
import sys

from owlmixin import OwlMixin

TEMPLATE_DIR = os.path.abspath(f"{os.path.dirname(__file__)}/../../template")
TEMPLATE_ENTRIES = os.listdir(TEMPLATE_DIR)


def exists_any(dst: str) -> bool:
    return any(map(lambda e: os.path.exists(f'{dst}/{e}'), TEMPLATE_ENTRIES))


class Args(OwlMixin):
    root: str


def run(args: Args):
    dst = os.path.abspath(args.root)

    if exists_any(dst):
        print(f"There is more than one of {TEMPLATE_ENTRIES} in {dst}.")
        print("Remove them and try again.")
        sys.exit(1)

    print(f"------------------------")
    print(f"| Success to create !! |")
    print(f"------------------------")
    print(f"📂 {dst}")
    for e in TEMPLATE_ENTRIES:
        if os.path.isdir(f'{TEMPLATE_DIR}/{e}'):
            print(f" ∟📂 {e}")
            shutil.copytree(f'{TEMPLATE_DIR}/{e}', f'{dst}/{e}')
        else:
            print(f" ∟📄 {e}")
            shutil.copy(f'{TEMPLATE_DIR}/{e}', f'{dst}/{e}')

    print("")
    print(f"------------------------")
    print(f"| Next you have to ... |")
    print(f"------------------------")
    print(f"$ cd {args.root}")
    print(f"# Change python_version in Pipfile if you don't want to use specified version.")
    print(f"$ pipenv install")
    print(f"$ pipenv run python main.py --help")

