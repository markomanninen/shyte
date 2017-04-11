from distutils.core import setup

install_requires = ['hy>=0.12.1']

#python setup.py register -r pypitest
#python setup.py register -r pypi
# next command not recommended but what can you do in Windows...
#python setup.py sdist upload -r pypitest
#python setup.py sdist upload

setup(
  name = 'shyte',
  
  packages = ['shyte'],
  package_dir = {'shyte': 'shyte'},
  package_data = {
    'shyte': ['*.hy', '*.py']
  },
  
  version = 'v0.2.0',
  description = 'sHyte 2.0 - (HyML Edition)',
  author = 'Marko Manninen',
  author_email = 'elonmedia@gmail.com',

  url = 'https://github.com/markomanninen/shyte',
  download_url = 'https://github.com/markomanninen/shyte/archive/v0.2.0.tar.gz',
  keywords = ['hylang', 'python', 'lisp', 'macros', 'markup language', 'dsl', 'xml', 'html', 'xhtml', 'flask'],
  platforms = ['any'],
  
  classifiers = [
    "Development Status :: 3 - Alpha",
    "Intended Audience :: Developers",
    "License :: OSI Approved :: MIT License",
    "Operating System :: OS Independent",
    "Programming Language :: Lisp",
    "Topic :: Software Development :: Libraries",
  ]
)
