#!/bin/sh
hem build
git reset *
git add public/application.*
git commit -m 'hem build'
rm public/application.js public/application.css