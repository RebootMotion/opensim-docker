# docker-opensim

This repository serves as a starting point for building
our own Docker images for OpenSim.

## Current state

The image builds correctly and when you launch a python3.8 (beware, it also has python3.6 installed
for some reason) and type `import opensim` it works.

Currently used software is:

| Software  | Link                                             | Version | Status    |
--------------------------------------------------------------------------------------
| adolc     | http://github.com/coin-or/ADOL-C                 | v2.7.2  | Abandoned |
| OpenSIM   | https://github.com/opensim-org/opensim-core      | v4.1    | Developed |
| Python    | https://github.com/python/cpython                | v3.9    | Developed |
| SWIG      | https://github.com/swig/swig                     | v4.2    | Abandoned |
