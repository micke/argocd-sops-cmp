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

# Install kustomize
RUN install_kustomize 5.1.1
RUN install_kustomize 5.0.3
ENV LATEST_KUSTOMIZE_VERSION=5.1.1

# Install sops
RUN install_sops 3.7.3
ENV LATEST_SOPS_VERSION=3.7.3

ADD init /usr/bin
ADD generate /usr/bin
ADD discover /usr/bin

# Set up ArgoCD CMP
WORKDIR /home/argocd/cmp-server/config/
COPY plugin.yaml ./

# Sidecar containers should run as user 999
USER 999
