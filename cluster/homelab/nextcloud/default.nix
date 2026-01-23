{ charts, ... }:
let
  application = "nextcloud";
  namespace = application;
in
{
  imports = [
    (import ./collabora.nix { inherit application namespace charts; })
    (import ./nextcloud.nix { inherit application namespace charts; })
  ];

  applications."${application}" = {
    inherit namespace;
    createNamespace = true;

    yamls = [
      (builtins.readFile ./nextcloud-secrets.sops.yaml)
    ];

    resources = {
      certificates.nextcloud-tls-certificate.spec = {
        secretName = "nextcloud-tls-certificate";
        issuerRef = {
          name = "azure-acme-issuer";
          kind = "ClusterIssuer";
        };
        duration = "2160h";
        renewBefore = "720h";
        dnsNames = [
          "collabora.anderwerse.de"
          "nextcloud.anderwerse.de"
        ];
      };
    };
  };
}
