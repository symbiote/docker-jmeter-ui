# Docker-based JMeter UI

Note: Linux only (expects X to exist)

## Overview

Runs a full UI JMeter instance from docker. Binds to your local X socket 
_things_ to display the UI, allows for full UI capability


Includes the extra graphs and timers modules

## Usage

Run ./build.sh to build the image

Run 

```
docker run --rm -it  \
	-e DISPLAY=$DISPLAY \
        -p :3128 \
	-v /tmp/.X11-unix:/tmp/.X11-unix \
	-v $(pwd):/tmp \
	-v $HOME/.Xauthority:/root/.Xauthority \
	-w /tmp \
	symbiote/jmeter:3.3
```

from your project's directory to start jmeter
