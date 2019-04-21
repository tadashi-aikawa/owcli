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
    print(f"| Create entries...    |")
    print(f"------------------------")
    if not os.path.exists(dst):
        os.mkdir(dst)
    print(f"📂 {dst}")
    for e in TEMPLATE_ENTRIES:
        if os.path.isdir(f'{TEMPLATE_DIR}/{e}'):
            real_entry = args.root if e == "yourapp" else e
            print(f" ∟📂 {real_entry}")
            shutil.copytree(f'{TEMPLATE_DIR}/yourapp', f'{dst}/{real_entry}')
        else:
            print(f" ∟📄 {e}")
            shutil.copy(f'{TEMPLATE_DIR}/{e}', f'{dst}/{e}')

    main_file = f"{dst}/{args.root}/main.py"
    with open(main_file, "r") as f:
        dt = f.read()
    with open(main_file, "w") as f:
        f.write(dt.replace("yourapp", args.root))

    print("")
    print(f"------------------------")
    print(f"| Next you have to ... |")
    print(f"------------------------")
    print(f"$ cd {args.root}")
    print(f"# Change python_version in Pipfile if you don't want to use specified version.")
    print(f"$ pipenv install")
    print(f"$ pipenv run python {args.root}/main.py --help")

