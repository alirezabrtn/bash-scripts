#!/bin/bash

read -p "Enter user name: " name
useradd -G sudo -m $name -s /bin/bash