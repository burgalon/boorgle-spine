#!/bin/sh
hem build
cp public/application.css src/application.css 
cp public/application.js src/application.js
cp public/index.html src/index.html
cp -r public/images src/
forge build
rm public/application.css public/application.js
#forge run ios
