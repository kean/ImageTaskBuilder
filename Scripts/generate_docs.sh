#!/bin/sh

version=$1

swift doc generate ./Source \
    --module-name NukeBuilder \
    --format html \
    --base-url "https://kean-org.github.io/docs/nuke-builder/reference/$version"
