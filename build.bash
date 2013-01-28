#!/bin/sh
cp $1-slug.json slug.json && hem build && cp web-slug.json slug.json
cp web-slug.json slug.json
