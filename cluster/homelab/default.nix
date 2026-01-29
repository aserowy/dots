{ ... }:
{
  # TODO: postgresql migrations from bitnami to cloudnativepg
  # TODO: alerting for cluster infrastructure
  # TODO: add mailing to monitoring and nextcloud
  # TODO: HPA collabora, gotenberg, tika, imaginary
  # TODO: check if HA is possible for adguard, paperless, and other workloads

  imports = [
    ./argocd.nix

    ./certificates.nix
    ./cilium.nix
    ./devices.nix
    ./haproxy.nix
    ./monitoring.nix
    ./policies.nix
    ./secrets.nix
    ./storage.nix

    ./adguard
    ./cloudnativepg.nix
    ./homeassistant
    ./nextcloud
    ./paperless
    ./rustdesk.nix
  ];

  nixidy = {
    resourceImports = [
      # ../crd/akri.nix
      ../crd/cert-manager.nix
      ../crd/cilium.nix
      ../crd/cloudnative-pg.nix
      ../crd/sops.nix
    ];

    target = {
      repository = "https://github.com/aserowy/dots.git";
      branch = "homelab";
      rootPath = "./";
    };

    defaults = {
      syncPolicy = {
        autoSync = {
          enabled = true;
          prune = true;
          selfHeal = true;
        };
      };
    };
  };
}
