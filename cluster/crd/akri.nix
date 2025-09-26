# This file was generated with nixidy resource generator, do not edit.
{
  lib,
  options,
  config,
  ...
}:

with lib;

let
  hasAttrNotNull = attr: set: hasAttr attr set && set.${attr} != null;

  attrsToList =
    values:
    if values != null then
      sort (
        a: b:
        if (hasAttrNotNull "_priority" a && hasAttrNotNull "_priority" b) then
          a._priority < b._priority
        else
          false
      ) (mapAttrsToList (n: v: v) values)
    else
      values;

  getDefaults =
    resource: group: version: kind:
    catAttrs "default" (
      filter (
        default:
        (default.resource == null || default.resource == resource)
        && (default.group == null || default.group == group)
        && (default.version == null || default.version == version)
        && (default.kind == null || default.kind == kind)
      ) config.defaults
    );

  types = lib.types // rec {
    str = mkOptionType {
      name = "str";
      description = "string";
      check = isString;
      merge = mergeEqualOption;
    };

    # Either value of type `finalType` or `coercedType`, the latter is
    # converted to `finalType` using `coerceFunc`.
    coercedTo =
      coercedType: coerceFunc: finalType:
      mkOptionType rec {
        inherit (finalType) getSubOptions getSubModules;

        name = "coercedTo";
        description = "${finalType.description} or ${coercedType.description}";
        check = x: finalType.check x || coercedType.check x;
        merge =
          loc: defs:
          let
            coerceVal =
              val:
              if finalType.check val then
                val
              else
                let
                  coerced = coerceFunc val;
                in
                assert finalType.check coerced;
                coerced;

          in
          finalType.merge loc (map (def: def // { value = coerceVal def.value; }) defs);
        substSubModules = m: coercedTo coercedType coerceFunc (finalType.substSubModules m);
        typeMerge = t1: t2: null;
        functor = (defaultFunctor name) // {
          wrapped = finalType;
        };
      };
  };

  mkOptionDefault = mkOverride 1001;

  mergeValuesByKey =
    attrMergeKey: listMergeKeys: values:
    listToAttrs (
      imap0 (
        i: value:
        nameValuePair (
          if hasAttr attrMergeKey value then
            if isAttrs value.${attrMergeKey} then
              toString value.${attrMergeKey}.content
            else
              (toString value.${attrMergeKey})
          else
            # generate merge key for list elements if it's not present
            "__kubenix_list_merge_key_"
            + (concatStringsSep "" (
              map (
                key: if isAttrs value.${key} then toString value.${key}.content else (toString value.${key})
              ) listMergeKeys
            ))
        ) (value // { _priority = i; })
      ) values
    );

  submoduleOf =
    ref:
    types.submodule (
      { name, ... }:
      {
        options = definitions."${ref}".options or { };
        config = definitions."${ref}".config or { };
      }
    );

  globalSubmoduleOf =
    ref:
    types.submodule (
      { name, ... }:
      {
        options = config.definitions."${ref}".options or { };
        config = config.definitions."${ref}".config or { };
      }
    );

  submoduleWithMergeOf =
    ref: mergeKey:
    types.submodule (
      { name, ... }:
      let
        convertName =
          name: if definitions."${ref}".options.${mergeKey}.type == types.int then toInt name else name;
      in
      {
        options = definitions."${ref}".options // {
          # position in original array
          _priority = mkOption {
            type = types.nullOr types.int;
            default = null;
          };
        };
        config = definitions."${ref}".config // {
          ${mergeKey} = mkOverride 1002 (
            # use name as mergeKey only if it is not coming from mergeValuesByKey
            if (!hasPrefix "__kubenix_list_merge_key_" name) then convertName name else null
          );
        };
      }
    );

  submoduleForDefinition =
    ref: resource: kind: group: version:
    let
      apiVersion = if group == "core" then version else "${group}/${version}";
    in
    types.submodule (
      { name, ... }:
      {
        inherit (definitions."${ref}") options;

        imports = getDefaults resource group version kind;
        config = mkMerge [
          definitions."${ref}".config
          {
            kind = mkOptionDefault kind;
            apiVersion = mkOptionDefault apiVersion;

            # metdata.name cannot use option default, due deep config
            metadata.name = mkOptionDefault name;
          }
        ];
      }
    );

  coerceAttrsOfSubmodulesToListByKey =
    ref: attrMergeKey: listMergeKeys:
    (types.coercedTo (types.listOf (submoduleOf ref)) (mergeValuesByKey attrMergeKey listMergeKeys) (
      types.attrsOf (submoduleWithMergeOf ref attrMergeKey)
    ));

  definitions = {
    "akri.sh.v0.Configuration" = {

      options = {
        "apiVersion" = mkOption {
          description = "\nAPIVersion defines the versioned schema of this representation of an object.\nServers should convert recognized schemas to the latest internal value, and\nmay reject unrecognized values.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources\n";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "\nKind is a string value representing the REST resource this object represents.\nServers may infer this from the endpoint the client submits requests to.\nCannot be updated.\nIn CamelCase.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds\n";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata";
          type = (types.nullOr (globalSubmoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "akri.sh.v0.ConfigurationSpec"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
      };

    };
    "akri.sh.v0.ConfigurationSpec" = {

      options = {
        "brokerProperties" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "brokerSpec" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "akri.sh.v0.ConfigurationSpecBrokerSpec"));
        };
        "capacity" = mkOption {
          description = "";
          type = (types.nullOr types.int);
        };
        "configurationServiceSpec" = mkOption {
          description = "";
          type = (types.nullOr types.attrs);
        };
        "discoveryHandler" = mkOption {
          description = "";
          type = (types.nullOr (submoduleOf "akri.sh.v0.ConfigurationSpecDiscoveryHandler"));
        };
        "instanceServiceSpec" = mkOption {
          description = "";
          type = (types.nullOr types.attrs);
        };
      };

      config = {
        "brokerProperties" = mkOverride 1002 null;
        "brokerSpec" = mkOverride 1002 null;
        "capacity" = mkOverride 1002 null;
        "configurationServiceSpec" = mkOverride 1002 null;
        "discoveryHandler" = mkOverride 1002 null;
        "instanceServiceSpec" = mkOverride 1002 null;
      };

    };
    "akri.sh.v0.ConfigurationSpecBrokerSpec" = {

      options = {
        "brokerJobSpec" = mkOption {
          description = "";
          type = (types.nullOr types.attrs);
        };
        "brokerPodSpec" = mkOption {
          description = "";
          type = (types.nullOr types.attrs);
        };
      };

      config = {
        "brokerJobSpec" = mkOverride 1002 null;
        "brokerPodSpec" = mkOverride 1002 null;
      };

    };
    "akri.sh.v0.ConfigurationSpecDiscoveryHandler" = {

      options = {
        "discoveryDetails" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "discoveryProperties" = mkOption {
          description = "";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "akri.sh.v0.ConfigurationSpecDiscoveryHandlerDiscoveryProperties"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "discoveryDetails" = mkOverride 1002 null;
        "discoveryProperties" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
      };

    };
    "akri.sh.v0.ConfigurationSpecDiscoveryHandlerDiscoveryProperties" = {

      options = {
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "value" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "akri.sh.v0.ConfigurationSpecDiscoveryHandlerDiscoveryPropertiesValueFrom"
            )
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "akri.sh.v0.ConfigurationSpecDiscoveryHandlerDiscoveryPropertiesValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "akri.sh.v0.ConfigurationSpecDiscoveryHandlerDiscoveryPropertiesValueFromConfigMapKeyRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "";
          type = (
            types.nullOr (
              submoduleOf "akri.sh.v0.ConfigurationSpecDiscoveryHandlerDiscoveryPropertiesValueFromSecretKeyRef"
            )
          );
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "akri.sh.v0.ConfigurationSpecDiscoveryHandlerDiscoveryPropertiesValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "key" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "akri.sh.v0.ConfigurationSpecDiscoveryHandlerDiscoveryPropertiesValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "key" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "akri.sh.v0.Instance" = {

      options = {
        "apiVersion" = mkOption {
          description = "\nAPIVersion defines the versioned schema of this representation of an object.\nServers should convert recognized schemas to the latest internal value, and\nmay reject unrecognized values.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources\n";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "\nKind is a string value representing the REST resource this object represents.\nServers may infer this from the endpoint the client submits requests to.\nCannot be updated.\nIn CamelCase.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds\n";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata";
          type = (types.nullOr (globalSubmoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta"));
        };
        "spec" = mkOption {
          description = "Defines the information in the Instance CRD\n\nAn Instance is a specific instance described by a Configuration.  For example, a Configuration may describe many cameras, each camera will be represented by a Instance.";
          type = (submoduleOf "akri.sh.v0.InstanceSpec");
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
      };

    };
    "akri.sh.v0.InstanceSpec" = {

      options = {
        "brokerProperties" = mkOption {
          description = "This defines some properties that will be set as environment variables in broker Pods that request the resource this Instance represents. It contains the `Configuration.broker_properties` from this Instance's Configuration and the `Device.properties` set by the Discovery Handler that discovered the resource this Instance represents.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "capacity" = mkOption {
          description = "This contains the number of slots for the Instance";
          type = types.int;
        };
        "cdiName" = mkOption {
          description = "This contains the CDI fully qualified name of the device linked to the Instance";
          type = types.str;
        };
        "configurationName" = mkOption {
          description = "This contains the name of the corresponding Configuration";
          type = types.str;
        };
        "deviceUsage" = mkOption {
          description = "This contains a map of capability slots to node names.  The number of slots corresponds to the associated Configuration.capacity field.  Each slot will either map to an empty string (if the slot has not been claimed) or to a node name (corresponding to the node that has claimed the slot)";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "nodes" = mkOption {
          description = "This contains a list of the nodes that can access this capability instance";
          type = (types.nullOr (types.listOf types.str));
        };
        "shared" = mkOption {
          description = "This defines whether the capability is to be shared by multiple nodes";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "brokerProperties" = mkOverride 1002 null;
        "deviceUsage" = mkOverride 1002 null;
        "nodes" = mkOverride 1002 null;
        "shared" = mkOverride 1002 null;
      };

    };

  };
in
{
  # all resource versions
  options = {
    resources = {
      "akri.sh"."v0"."Configuration" = mkOption {
        description = "";
        type = (
          types.attrsOf (
            submoduleForDefinition "akri.sh.v0.Configuration" "configurations" "Configuration" "akri.sh" "v0"
          )
        );
        default = { };
      };
      "akri.sh"."v0"."Instance" = mkOption {
        description = "Auto-generated derived type for InstanceSpec via `CustomResource`";
        type = (
          types.attrsOf (submoduleForDefinition "akri.sh.v0.Instance" "instances" "Instance" "akri.sh" "v0")
        );
        default = { };
      };

    }
    // {
      "configurations" = mkOption {
        description = "";
        type = (
          types.attrsOf (
            submoduleForDefinition "akri.sh.v0.Configuration" "configurations" "Configuration" "akri.sh" "v0"
          )
        );
        default = { };
      };
      "instances" = mkOption {
        description = "Auto-generated derived type for InstanceSpec via `CustomResource`";
        type = (
          types.attrsOf (submoduleForDefinition "akri.sh.v0.Instance" "instances" "Instance" "akri.sh" "v0")
        );
        default = { };
      };

    };
  };

  config = {
    # expose resource definitions
    inherit definitions;

    # register resource types
    types = [
      {
        name = "configurations";
        group = "akri.sh";
        version = "v0";
        kind = "Configuration";
        attrName = "configurations";
      }
      {
        name = "instances";
        group = "akri.sh";
        version = "v0";
        kind = "Instance";
        attrName = "instances";
      }
    ];

    resources = {
      "akri.sh"."v0"."Configuration" = mkAliasDefinitions options.resources."configurations";
      "akri.sh"."v0"."Instance" = mkAliasDefinitions options.resources."instances";

    };

    # make all namespaced resources default to the
    # application's namespace
    defaults = [
      {
        group = "akri.sh";
        version = "v0";
        kind = "Configuration";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
      {
        group = "akri.sh";
        version = "v0";
        kind = "Instance";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
    ];
  };
}
