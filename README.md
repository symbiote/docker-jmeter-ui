# Docker-based JMeter UI

Note: Linux and macOS only (expects X to exist)

## Overview

Runs a full UI JMeter instance from docker. Binds to your local X socket
_things_ to display the UI, allows for full UI capability

Includes the extra graphs and timers modules

## macOS prerequisites

Install and configure XQuartz

    # Install XQuartz
    brew cask install xquartz

    # Configure
    open -a XQuartz
    # ... and go to Preferences -> Security -> Tick "Allow connections from network clients"

    export IP=$(ifconfig en0 | grep inet | awk '$1=="inet" {print $2}')
    export DISPLAY=$IP:0

    # Set ACL to allow connections from ourselves (as in docker)
    # If this step fails you might need to restart your terminal or even mac
    xhost + $IP

Credits to:

- https://sourabhbajaj.com/blog/2017/02/07/gui-applications-docker-mac/

## Usage

_Make sure you followed the steps before if you're using macOS._

* Run ./build.sh to build the image
* Run

```
docker run --rm -it  \
  -e DISPLAY=$DISPLAY \
  -p :3128 \
  -v /tmp/.X11-unix:/tmp/.X11-unix \
  -v $(pwd):/tmp \
  -v $HOME/.Xauthority:/root/.Xauthority \
  -w /tmp \
  symbiote/jmeter:5.1.1
```

from your project's directory to start jmeter
