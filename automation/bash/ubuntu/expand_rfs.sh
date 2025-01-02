#!/bin/bash

# This script expands the root filesystem on an Ubuntu EC2 instance
# This assumes that the mounted EBS volume is already expanded in the AWS console

# Recreate /tmp directory with correct permissions
sudo mkdir -p /tmp
sudo chmod 1777 /tmp

# Ensure cloud-guest-utils is installed
sudo apt-get update
sudo apt-get install -y cloud-guest-utils

# Resize the partition
sudo growpart /dev/xvda 1

# Resize the filesystem
sudo resize2fs /dev/xvda1

# Check the new disk usage
df -h