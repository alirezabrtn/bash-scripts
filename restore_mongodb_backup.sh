#!/bin/bash

main() {
    echo "Enter the absolute path of your backup archive (in .tar.xz): "
    read file

    cd /tmp
    tar -xvJf $file
    mongorestore
}

main
