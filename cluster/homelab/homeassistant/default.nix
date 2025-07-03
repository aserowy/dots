{ charts, ... }:
let
  application = "homeassistant";
  namespace = application;
in
{
  imports = [
    (import ./emqx-operator.nix { inherit application namespace charts; })
    (import ./zigbee2mqtt.nix { inherit application namespace charts; })
  ];

  applications."${application}" = {
    inherit namespace;
    createNamespace = true;

    yamls = [
      (builtins.readFile ./homeassistant-secrets.sops.yaml)

      ''
        apiVersion: akri.sh/v0
        kind: Configuration
        metadata:
          name: akri-zigbee-stick
        spec:
          capacity: 1
          discoveryHandler:
            discoveryDetails: |
              groupRecursive: true
              udevRules:
              - ATTRS{idVendor}=="1a86", ATTRS{idProduct}=="7523", ATTRS{bcdDevice}=="0264"
            name: udev
      ''
    ];
  };
}
