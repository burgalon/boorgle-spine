#!/bin/sh
hem build
mv public/application.css src/application.css
mv public/application.js src/application.js
cp public/index.html src/index.html
cp -r public/images src/
forge build android
forge build ios
forge package ios && forge package android