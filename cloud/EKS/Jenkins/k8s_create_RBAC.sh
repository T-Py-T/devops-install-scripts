#!/bin/bash

# setup namespace for credentials
kubectl create namespace webapps

kubectl apply -f svc.yaml
kubectl apply -f role.yaml
kubectl apply -f bind.yaml
kubectl apply -f jen-secrets.yaml -n webapps # create secret in the webapps namespace

# used to generate the cred in the webapps namespace for jenkins to access
kubectl create secret docker-registry regcred \
    --docker-server=https://index.docker.io/v1/ \
    --docker-username=tnt850910 \
    --docker-password=dockerhubpassword \
    --namespace=webapps 

kubectl get secrets -n webapps

echo kubectl describe secret mysecretname -n webapps
