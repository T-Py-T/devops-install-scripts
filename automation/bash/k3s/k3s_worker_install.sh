#!/bin/bash

curl -sfL https://get.k3s.io | K3S_URL=https://192.168.1.26:6443 K3S_TOKEN={CONTROL_TOKEN} sh -