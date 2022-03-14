## Overview

This project contains the terraform scripts to deploy a complete EKS cluster inside terraform folder, Helm3 charts for deployment of a simple nginx container inside helm directory and inside app directory there are Docker file and config files which is used to create docker image.

In terraform directory there is modules folder where resources are defined. Inside addons folder there is configmap, external-dns and ingress-controller yaml files which are used for eks cluster kube-system namespace.