#!/bin/bash

# Bring over the pre-written the docker_install.sh file
chmod +x docker_install.sh
./docker_install.sh

# Change the permissions of the docker socket
sudo chmod 666 /var/run/docker.sock #This is perferred bceuase it allows other users to access the Docker commands
sudo usermod –aG docker ubuntu # This adds only the ubuntu user to the docker group

# Run the nexus container
docker run -d --name nexus -p 8081:8081 sonatype/nexus3:latest

# *************************************************************************
# Get Nexus initial password (admin)
# *************************************************************************
# docker ps #1. Get Container ID
# docker exec -it <container_ID> /bin/bash #2. Access the container's bash shell, Replace `<container_ID>` with the actual ID of the Nexus container.
# cat sonatype-work/nexus3/admin.password #3. Display the contents of the `admin.password` file:
# exit #4. Exit the Container Shell
