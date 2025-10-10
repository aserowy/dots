{ charts, lib, ... }:
let
  application = "homeassistant";
  namespace = application;
in
{
  imports = [
    (import ./homeassistant.nix {
      inherit
        application
        namespace
        charts
        lib
        ;
    })
    (import ./mosquitto.nix { inherit application namespace; })
    (import ./zigbee2mqtt.nix { inherit application namespace; })
  ];

  applications."${application}" = {
    inherit namespace;
    createNamespace = true;

    # NOTE: Important on updates to handle usb ressources
    syncPolicy.syncOptions.replace = true;

    yamls = [
      (builtins.readFile ./homeassistant-secrets.sops.yaml)

      ''
        apiVersion: akri.sh/v0
        kind: Configuration
        metadata:
          name: akri-bluetooth-stick
        spec:
          capacity: 1
          discoveryHandler:
            discoveryDetails: |
              groupRecursive: true
              udevRules:
              - ATTRS{idVendor}=="10d7", ATTRS{idProduct}=="b012"
            name: udev
      ''

      ''
        apiVersion: akri.sh/v0
        kind: Configuration
        metadata:
          name: akri-enocean-stick
        spec:
          capacity: 1
          discoveryHandler:
            discoveryDetails: |
              groupRecursive: true
              udevRules:
              - ATTRS{idVendor}=="0403", ATTRS{product}=="EnOcean USB 300 DC"
            name: udev
      ''

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
