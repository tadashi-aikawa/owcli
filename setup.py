#!/usr/bin/env python
# coding: utf-8

import os
import re
from setuptools import setup, find_packages

here = os.path.abspath(os.path.dirname(__file__))


def load_readme():
    with open(os.path.join(here, "README.md")) as f:
        return f.read()


target_files = []
for root, dirs, files in os.walk(f"{here}/owcli/template"):
    targets = [os.path.join(root, f) for f in files]
    target_files.extend(targets)


setup(
    name="owcli",
    version=re.search(
        r'__version__\s*=\s*[\'"]([^\'"]*)[\'"]',  # It excludes inline comment too
        open("owcli/main.py").read(),
    ).group(1),
    description="CLI framework which supports both command and subcommand.",
    long_description=load_readme(),
    long_description_content_type="text/markdown",
    license="MIT",
    author="tadashi-aikawa",
    author_email="syou.maman@gmail.com",
    maintainer="tadashi-aikawa",
    maintainer_email="syou.maman@gmail.com",
    url="https://github.com/tadashi-aikawa/owcli.git",
    keywords="cli framework",
    packages=find_packages(exclude=["tests*"]),
    package_data={"owcli": target_files},
    install_requires=["docopt", "owlmixin>=5.1.0"],
    entry_points={"console_scripts": ["owcli = owcli.main:main"]},
    classifiers=[
        "Development Status :: 2 - Pre-Alpha",
        "Intended Audience :: Developers",
        "Topic :: Software Development :: Libraries :: Application Frameworks",
        "License :: OSI Approved :: MIT License",
        "Programming Language :: Python",
        "Programming Language :: Python :: 3",
        "Programming Language :: Python :: 3.6",
        "Programming Language :: Python :: 3.7",
    ],
)
