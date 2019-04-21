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


def walk_create(tmpl_current: str, dst_current: str, depth: int, root: str):
    for e in os.listdir(tmpl_current):
        if os.path.isdir(f'{tmpl_current}/{e}'):
            if e == "__pycache__":
                continue
            path_from_dst = root if e == "yourapp" else e
            print(f" {'  '*depth}∟📂 {path_from_dst}")
            os.mkdir(f'{dst_current}/{path_from_dst}')
            walk_create(f'{tmpl_current}/{e}', f'{dst_current}/{path_from_dst}', depth+1, root)
        else:
            print(f" {'  '*depth}∟📄 {e}")
            shutil.copy(f'{tmpl_current}/{e}', f'{dst_current}/{e}')


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
    walk_create(TEMPLATE_DIR, dst, 0, args.root)

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

