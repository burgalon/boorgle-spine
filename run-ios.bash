#!/bin/sh
env=${1:-ios}
hem build && cp public/application.css src/application.css && cp public/application.js src/application.js && $HOME/Library/Trigger\ Toolkit/forge build $env && rm public/application.css public/application.js && $HOME/Library/Trigger\ Toolkit/forge run $env