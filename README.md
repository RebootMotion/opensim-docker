# Dockerized OpenSim (Ubuntu 18.04)

This project contains two separate methods for installing and running Opensim:

1. In a Docker container based on Ubuntu 18.04
2. Manual installation on your own server running Ubuntu.

# Installation instructions

## Docker

To build and run the Docker container:

```
docker build -t opensim .    
docker run opensim
```

To use this as a base for your own container, simply use

```
FROM rebootmotion/opensim:latest
```
 
at the beginning of your Dockerfile.

## Manual Install

To install this manually on Ubuntu 18.04:

```
clone git@github.com:RebootMotion/opensim-docker.git
cd opensim-docker
./install.sh
```

As this process installs system packages, you need to be logged in as a user with `sudo` privileges and will be prompted for your password during the process.

_**Important note:** On the Docker version, the libraries install to the /opensim directory so the base image provides a consistent locations for your own Dockerfiles. In the manual installation process, we install to the user's home directory._