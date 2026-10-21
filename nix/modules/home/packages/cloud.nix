# Containers, Kubernetes and the cloud provider CLIs.
{
  available,
  lib,
  pkgs,
  ...
}:
{
  home.packages =
    available (
      with pkgs;
      [
        argo-workflows
        argocd
        awscli2
        docker
        docker-buildx
        docker-compose
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
      ]
    )
    # A VM to run dockerd in is only needed on macOS; Linux uses the host's own
    # Docker Engine through /var/run/docker.sock. The credential helpers too:
    # macOS' config.json names osxkeychain, while Linux has no config.json, so
    # docker picks secretservice off PATH and a headless host cannot answer it.
    ++ lib.optionals pkgs.stdenv.hostPlatform.isDarwin [
      pkgs.colima
      pkgs.docker-credential-helpers
    ];
}
