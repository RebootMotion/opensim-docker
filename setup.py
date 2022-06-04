from setuptools import setup

setup(name='opensim',
      zip_safe=False,
      version='4.1',
      description='OpenSim Simulation Framework',
      author='OpenSim Team',
      packages=['opensim'],
      author_email='ahabib@stanford.edu',
      url='http://opensim.stanford.edu/',
      license='Apache 2.0',
      # The last 3 entries are for if OPENSIM_PYTHON_STANDALONE is ON.
      # The asterisk after the extension is to handle version numbers on Linux.
      package_data={'opensim': ['_*.*', '*.dylib', '*.dll', '*.so*']},
      include_package_data=True,
      classifiers=[
          'Intended Audience :: Science/Research',
          'Operating System :: OS Independent',
          'Programming Language :: Python :: 2.7',
          'Programming Language :: Python :: 3',
          'Topic :: Scientific/Engineering :: Physics',
          ],
      )
