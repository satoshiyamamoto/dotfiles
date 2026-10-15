# Containers, Kubernetes and the cloud provider CLIs.
{ lib, pkgs, ... }:
{
  home.packages = with pkgs; [
    argo-workflows
    argocd
    awscli
    colima
    docker
    docker-buildx
    docker-compose
    docker-credential-helpers
    google-cloud-sdk
    gws
    k9s
    kubectl
    kubectl-tree
    kubernetes-helm
    lazydocker
    # minikube bundles its own bin/kubectl. home-manager's buildEnv, unlike
    # nix-darwin's system profile, does not ignore collisions, so say outright
    # that the real kubectl wins -- as it already did in /run/current-system.
    (lib.lowPrio minikube)
    qemu
    sops
    stern
    tfenv
  ];
}
