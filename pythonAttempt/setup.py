"""Setuptools setup for creating a .plugin bundle"""
from setuptools import setup


APP = ['Bridge.py']
OPTIONS = {
  # Any local packages to include in the bundle should go here.
  # See the py2app documentation for more
  "includes": [],
}

setup(
    plugin=APP,
    options={'py2app': OPTIONS},
    setup_requires=['py2app'],
    install_requires=['pyobjc'],
)
