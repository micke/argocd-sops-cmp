FROM debian:bullseye-slim

RUN apt-get update -y && \
      apt-get install -y \
      curl \
      age \
      git-core \
      gnupg \
      gnupg-agent && \
      apt-get clean && \
      rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ADD install_kustomize /usr/bin
ADD install_sops /usr/bin
ADD install_helm /usr/bin

# Install kustomize
RUN install_kustomize 5.4.3
RUN install_kustomize 5.5.0
ENV LATEST_KUSTOMIZE_VERSION=5.5.0

# Install sops
RUN install_sops 3.9.1
ENV LATEST_SOPS_VERSION=3.9.1

# Install helm
RUN install_helm 3.16.2
ENV LATEST_HELM_VERSION=3.16.2

ADD init /usr/bin
ADD generate /usr/bin
ADD discover /usr/bin

# Set up ArgoCD CMP
WORKDIR /home/argocd/cmp-server/config/
COPY plugin.yaml ./

# Sidecar containers should run as user 999
USER 999
