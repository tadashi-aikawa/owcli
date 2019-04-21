#!/usr/bin/env python
# coding: utf-8

import os
import re
from setuptools import setup, find_packages

from pipenv.project import Project
from pipenv.utils import convert_deps_to_pip

here = os.path.abspath(os.path.dirname(__file__))

pfile = Project(chdir=False).parsed_pipfile
requirements = convert_deps_to_pip(pfile['packages'], r=False)
test_requirements = convert_deps_to_pip(pfile['dev-packages'], r=False)


def load_readme():
    with open(os.path.join(here, 'README.md')) as f:
        return f.read()


setup(
    name='owcli',
    version=re.search(
        r'VERSION\s*=\s*[\'"]([^\'"]*)[\'"]',  # It excludes inline comment too
        open('owcli/main.py').read()).group(1),
    description='Check difference between two responses of API.',
    long_description=load_readme(),
    long_description_content_type='text/markdown',
    license='MIT',
    author='tadashi-aikawa',
    author_email='syou.maman@gmail.com',
    maintainer='tadashi-aikawa',
    maintainer_email='syou.maman@gmail.com',
    url='https://github.com/tadashi-aikawa/owcli.git',
    keywords='cli framework',
    packages=find_packages(exclude=['tests*']),
    install_requires=requirements,
    extras_require={'test': test_requirements},
    entry_points={
        'console_scripts': [
            'owcli = owcli.main:main'
        ],
    },
    classifiers=[
        'Development Status :: 2 - Pre-Alpha',
        'Intended Audience :: Developers',
        'Topic :: Software Development :: Libraries :: Application Frameworks',
        'License :: OSI Approved :: MIT License',
        'Programming Language :: Python',
        'Programming Language :: Python :: 3',
        'Programming Language :: Python :: 3.6',
        'Programming Language :: Python :: 3.7',
    ],
)
