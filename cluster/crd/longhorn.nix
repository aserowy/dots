# This file was generated with nixidy CRD generator, do not edit.
{
  lib,
  options,
  config,
  ...
}:
with lib; let
  hasAttrNotNull = attr: set: hasAttr attr set && set.${attr} != null;

  attrsToList = values:
    if values != null
    then
      sort (
        a: b:
          if (hasAttrNotNull "_priority" a && hasAttrNotNull "_priority" b)
          then a._priority < b._priority
          else false
      ) (mapAttrsToList (n: v: v) values)
    else values;

  getDefaults = resource: group: version: kind:
    catAttrs "default" (filter (
        default:
          (default.resource == null || default.resource == resource)
          && (default.group == null || default.group == group)
          && (default.version == null || default.version == version)
          && (default.kind == null || default.kind == kind)
      )
      config.defaults);

  types =
    lib.types
    // rec {
      str = mkOptionType {
        name = "str";
        description = "string";
        check = isString;
        merge = mergeEqualOption;
      };

      # Either value of type `finalType` or `coercedType`, the latter is
      # converted to `finalType` using `coerceFunc`.
      coercedTo = coercedType: coerceFunc: finalType:
        mkOptionType rec {
          inherit (finalType) getSubOptions getSubModules;

          name = "coercedTo";
          description = "${finalType.description} or ${coercedType.description}";
          check = x: finalType.check x || coercedType.check x;
          merge = loc: defs: let
            coerceVal = val:
              if finalType.check val
              then val
              else let
                coerced = coerceFunc val;
              in
                assert finalType.check coerced; coerced;
          in
            finalType.merge loc (map (def: def // {value = coerceVal def.value;}) defs);
          substSubModules = m: coercedTo coercedType coerceFunc (finalType.substSubModules m);
          typeMerge = t1: t2: null;
          functor = (defaultFunctor name) // {wrapped = finalType;};
        };
    };

  mkOptionDefault = mkOverride 1001;

  mergeValuesByKey = attrMergeKey: listMergeKeys: values:
    listToAttrs (imap0
      (i: value:
        nameValuePair (
          if hasAttr attrMergeKey value
          then
            if isAttrs value.${attrMergeKey}
            then toString value.${attrMergeKey}.content
            else (toString value.${attrMergeKey})
          else
            # generate merge key for list elements if it's not present
            "__kubenix_list_merge_key_"
            + (concatStringsSep "" (map (
                key:
                  if isAttrs value.${key}
                  then toString value.${key}.content
                  else (toString value.${key})
              )
              listMergeKeys))
        ) (value // {_priority = i;}))
      values);

  submoduleOf = ref:
    types.submodule ({name, ...}: {
      options = definitions."${ref}".options or {};
      config = definitions."${ref}".config or {};
    });

  globalSubmoduleOf = ref:
    types.submodule ({name, ...}: {
      options = config.definitions."${ref}".options or {};
      config = config.definitions."${ref}".config or {};
    });

  submoduleWithMergeOf = ref: mergeKey:
    types.submodule ({name, ...}: let
      convertName = name:
        if definitions."${ref}".options.${mergeKey}.type == types.int
        then toInt name
        else name;
    in {
      options =
        definitions."${ref}".options
        // {
          # position in original array
          _priority = mkOption {
            type = types.nullOr types.int;
            default = null;
          };
        };
      config =
        definitions."${ref}".config
        // {
          ${mergeKey} = mkOverride 1002 (
            # use name as mergeKey only if it is not coming from mergeValuesByKey
            if (!hasPrefix "__kubenix_list_merge_key_" name)
            then convertName name
            else null
          );
        };
    });

  submoduleForDefinition = ref: resource: kind: group: version: let
    apiVersion =
      if group == "core"
      then version
      else "${group}/${version}";
  in
    types.submodule ({name, ...}: {
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
    });

  coerceAttrsOfSubmodulesToListByKey = ref: attrMergeKey: listMergeKeys: (
    types.coercedTo
    (types.listOf (submoduleOf ref))
    (mergeValuesByKey attrMergeKey listMergeKeys)
    (types.attrsOf (submoduleWithMergeOf ref attrMergeKey))
  );

  definitions = {
    "longhorn.io.v1beta2.RecurringJob" = {
      options = {
        "apiVersion" = mkOption {
          description = "APIVersion defines the versioned schema of this representation of an object.\nServers should convert recognized schemas to the latest internal value, and\nmay reject unrecognized values.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources";
          type = types.nullOr types.str;
        };
        "kind" = mkOption {
          description = "Kind is a string value representing the REST resource this object represents.\nServers may infer this from the endpoint the client submits requests to.\nCannot be updated.\nIn CamelCase.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds";
          type = types.nullOr types.str;
        };
        "metadata" = mkOption {
          description = "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata";
          type = types.nullOr (globalSubmoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta");
        };
        "spec" = mkOption {
          description = "RecurringJobSpec defines the desired state of the Longhorn recurring job";
          type = types.nullOr (submoduleOf "longhorn.io.v1beta2.RecurringJobSpec");
        };
        "status" = mkOption {
          description = "RecurringJobStatus defines the observed state of the Longhorn recurring job";
          type = types.nullOr (submoduleOf "longhorn.io.v1beta2.RecurringJobStatus");
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };
    };
    "longhorn.io.v1beta2.RecurringJobSpec" = {
      options = {
        "concurrency" = mkOption {
          description = "The concurrency of taking the snapshot/backup.";
          type = types.nullOr types.int;
        };
        "cron" = mkOption {
          description = "The cron setting.";
          type = types.nullOr types.str;
        };
        "groups" = mkOption {
          description = "The recurring job group.";
          type = types.nullOr (types.listOf types.str);
        };
        "labels" = mkOption {
          description = "The label of the snapshot/backup.";
          type = types.nullOr (types.attrsOf types.str);
        };
        "name" = mkOption {
          description = "The recurring job name.";
          type = types.nullOr types.str;
        };
        "parameters" = mkOption {
          description = "The parameters of the snapshot/backup.\nSupport parameters: \"full-backup-interval\", \"volume-backup-policy\".";
          type = types.nullOr (types.attrsOf types.str);
        };
        "retain" = mkOption {
          description = "The retain count of the snapshot/backup.";
          type = types.nullOr types.int;
        };
        "task" = mkOption {
          description = "The recurring job task.\nCan be \"snapshot\", \"snapshot-force-create\", \"snapshot-cleanup\", \"snapshot-delete\", \"backup\", \"backup-force-create\", \"filesystem-trim\" or \"system-backup\".";
          type = types.nullOr types.str;
        };
      };

      config = {
        "concurrency" = mkOverride 1002 null;
        "cron" = mkOverride 1002 null;
        "groups" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "parameters" = mkOverride 1002 null;
        "retain" = mkOverride 1002 null;
        "task" = mkOverride 1002 null;
      };
    };
    "longhorn.io.v1beta2.RecurringJobStatus" = {
      options = {
        "executionCount" = mkOption {
          description = "The number of jobs that have been triggered.";
          type = types.nullOr types.int;
        };
        "ownerID" = mkOption {
          description = "The owner ID which is responsible to reconcile this recurring job CR.";
          type = types.nullOr types.str;
        };
      };

      config = {
        "executionCount" = mkOverride 1002 null;
        "ownerID" = mkOverride 1002 null;
      };
    };
  };
in {
  # all resource versions
  options = {
    resources =
      {
        "longhorn.io"."v1beta2"."RecurringJob" = mkOption {
          description = "RecurringJob is where Longhorn stores recurring job object.";
          type = types.attrsOf (submoduleForDefinition "longhorn.io.v1beta2.RecurringJob" "recurringjobs" "RecurringJob" "longhorn.io" "v1beta2");
          default = {};
        };
      }
      // {
        "recurringJobs" = mkOption {
          description = "RecurringJob is where Longhorn stores recurring job object.";
          type = types.attrsOf (submoduleForDefinition "longhorn.io.v1beta2.RecurringJob" "recurringjobs" "RecurringJob" "longhorn.io" "v1beta2");
          default = {};
        };
      };
  };

  config = {
    # expose resource definitions
    inherit definitions;

    # register resource types
    types = [
      {
        name = "recurringjobs";
        group = "longhorn.io";
        version = "v1beta2";
        kind = "RecurringJob";
        attrName = "recurringJobs";
      }
    ];

    resources = {
      "longhorn.io"."v1beta2"."RecurringJob" =
        mkAliasDefinitions options.resources."recurringJobs";
    };

    defaults = [
      {
        group = "longhorn.io";
        version = "v1beta2";
        kind = "RecurringJob";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
    ];
  };
}
