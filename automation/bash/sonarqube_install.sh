#!/bin/bash

# Bring over the pre-written the docker_install.sh file
chmod +x docker_install.sh
./docker_install.sh

# Change the permissions of the docker socket
sudo chmod 666 /var/run/docker.sock #This is perferred bceuase it allows other users to access the Docker commands
sudo usermod –aG docker ubuntu # This adds only the ubuntu user to the docker group

# Run the sonarqube container
docker run -d --name sonar -p 9000:9000 sonarqube:lts-community