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
            internal = true;
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
    "postgresql.cnpg.io.v1.Cluster" = {

      options = {
        "apiVersion" = mkOption {
          description = "APIVersion defines the versioned schema of this representation of an object.\nServers should convert recognized schemas to the latest internal value, and\nmay reject unrecognized values.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#resources";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "Kind is a string value representing the REST resource this object represents.\nServers may infer this from the endpoint the client submits requests to.\nCannot be updated.\nIn CamelCase.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#types-kinds";
          type = (types.nullOr types.str);
        };
        "metadata" = mkOption {
          description = "Standard object's metadata. More info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata";
          type = (globalSubmoduleOf "io.k8s.apimachinery.pkg.apis.meta.v1.ObjectMeta");
        };
        "spec" = mkOption {
          description = "Specification of the desired behavior of the cluster.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status";
          type = (submoduleOf "postgresql.cnpg.io.v1.ClusterSpec");
        };
        "status" = mkOption {
          description = "Most recently observed status of the cluster. This data may not be up\nto date. Populated by the system. Read-only.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpec" = {

      options = {
        "affinity" = mkOption {
          description = "Affinity/Anti-affinity rules for Pods";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinity"));
        };
        "backup" = mkOption {
          description = "The configuration to be used for backups";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackup"));
        };
        "bootstrap" = mkOption {
          description = "Instructions to bootstrap this cluster";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrap"));
        };
        "certificates" = mkOption {
          description = "The configuration for the CA and related certificates";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecCertificates"));
        };
        "description" = mkOption {
          description = "Description of this PostgreSQL cluster";
          type = (types.nullOr types.str);
        };
        "enablePDB" = mkOption {
          description = "Manage the `PodDisruptionBudget` resources within the cluster. When\nconfigured as `true` (default setting), the pod disruption budgets\nwill safeguard the primary node from being terminated. Conversely,\nsetting it to `false` will result in the absence of any\n`PodDisruptionBudget` resource, permitting the shutdown of all nodes\nhosting the PostgreSQL cluster. This latter configuration is\nadvisable for any PostgreSQL cluster employed for\ndevelopment/staging purposes.";
          type = (types.nullOr types.bool);
        };
        "enableSuperuserAccess" = mkOption {
          description = "When this option is enabled, the operator will use the `SuperuserSecret`\nto update the `postgres` user password (if the secret is\nnot present, the operator will automatically create one). When this\noption is disabled, the operator will ignore the `SuperuserSecret` content, delete\nit when automatically created, and then blank the password of the `postgres`\nuser by setting it to `NULL`. Disabled by default.";
          type = (types.nullOr types.bool);
        };
        "env" = mkOption {
          description = "Env follows the Env format to pass environment variables\nto the pods created in the cluster";
          type = (
            types.nullOr (coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.ClusterSpecEnv" "name" [ ])
          );
          apply = attrsToList;
        };
        "envFrom" = mkOption {
          description = "EnvFrom follows the EnvFrom format to pass environment variables\nsources to the pods to be used by Env";
          type = (types.nullOr (types.listOf (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEnvFrom")));
        };
        "ephemeralVolumeSource" = mkOption {
          description = "EphemeralVolumeSource allows the user to configure the source of ephemeral volumes.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumeSource"));
        };
        "ephemeralVolumesSizeLimit" = mkOption {
          description = "EphemeralVolumesSizeLimit allows the user to set the limits for the ephemeral\nvolumes";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumesSizeLimit"));
        };
        "externalClusters" = mkOption {
          description = "The list of external clusters which are used in the configuration";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.ClusterSpecExternalClusters" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "failoverDelay" = mkOption {
          description = "The amount of time (in seconds) to wait before triggering a failover\nafter the primary PostgreSQL instance in the cluster was detected\nto be unhealthy";
          type = (types.nullOr types.int);
        };
        "imageCatalogRef" = mkOption {
          description = "Defines the major PostgreSQL version we want to use within an ImageCatalog";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecImageCatalogRef"));
        };
        "imageName" = mkOption {
          description = "Name of the container image, supporting both tags (`<image>:<tag>`)\nand digests for deterministic and repeatable deployments\n(`<image>:<tag>@sha256:<digestValue>`)";
          type = (types.nullOr types.str);
        };
        "imagePullPolicy" = mkOption {
          description = "Image pull policy.\nOne of `Always`, `Never` or `IfNotPresent`.\nIf not defined, it defaults to `IfNotPresent`.\nCannot be updated.\nMore info: https://kubernetes.io/docs/concepts/containers/images#updating-images";
          type = (types.nullOr types.str);
        };
        "imagePullSecrets" = mkOption {
          description = "The list of pull secrets to be used to pull the images";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.ClusterSpecImagePullSecrets" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "inheritedMetadata" = mkOption {
          description = "Metadata that will be inherited by all objects related to the Cluster";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecInheritedMetadata"));
        };
        "instances" = mkOption {
          description = "Number of instances required in the cluster";
          type = types.int;
        };
        "livenessProbeTimeout" = mkOption {
          description = "LivenessProbeTimeout is the time (in seconds) that is allowed for a PostgreSQL instance\nto successfully respond to the liveness probe (default 30).\nThe Liveness probe failure threshold is derived from this value using the formula:\nceiling(livenessProbe / 10).";
          type = (types.nullOr types.int);
        };
        "logLevel" = mkOption {
          description = "The instances' log level, one of the following values: error, warning, info (default), debug, trace";
          type = (types.nullOr types.str);
        };
        "managed" = mkOption {
          description = "The configuration that is used by the portions of PostgreSQL that are managed by the instance manager";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecManaged"));
        };
        "maxSyncReplicas" = mkOption {
          description = "The target value for the synchronous replication quorum, that can be\ndecreased if the number of ready standbys is lower than this.\nUndefined or 0 disable synchronous replication.";
          type = (types.nullOr types.int);
        };
        "minSyncReplicas" = mkOption {
          description = "Minimum number of instances required in synchronous replication with the\nprimary. Undefined or 0 allow writes to complete when no standby is\navailable.";
          type = (types.nullOr types.int);
        };
        "monitoring" = mkOption {
          description = "The configuration of the monitoring infrastructure of this cluster";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecMonitoring"));
        };
        "nodeMaintenanceWindow" = mkOption {
          description = "Define a maintenance window for the Kubernetes nodes";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecNodeMaintenanceWindow"));
        };
        "plugins" = mkOption {
          description = "The plugins configuration, containing\nany plugin to be loaded with the corresponding configuration";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.ClusterSpecPlugins" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "podSecurityContext" = mkOption {
          description = "Override the PodSecurityContext applied to every Pod of the cluster.\nWhen set, this overrides the operator's default PodSecurityContext for the cluster.\nIf omitted, the operator defaults are used.\nThis field doesn't have any effect if SecurityContextConstraints are present.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecPodSecurityContext"));
        };
        "postgresGID" = mkOption {
          description = "The GID of the `postgres` user inside the image, defaults to `26`";
          type = (types.nullOr types.int);
        };
        "postgresUID" = mkOption {
          description = "The UID of the `postgres` user inside the image, defaults to `26`";
          type = (types.nullOr types.int);
        };
        "postgresql" = mkOption {
          description = "Configuration of the PostgreSQL server";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecPostgresql"));
        };
        "primaryUpdateMethod" = mkOption {
          description = "Method to follow to upgrade the primary server during a rolling\nupdate procedure, after all replicas have been successfully updated:\nit can be with a switchover (`switchover`) or in-place (`restart` - default).\nNote: when using `switchover`, the operator will reject updates that change both\nthe image name and PostgreSQL configuration parameters simultaneously to avoid\nconfiguration mismatches during the switchover process.";
          type = (types.nullOr types.str);
        };
        "primaryUpdateStrategy" = mkOption {
          description = "Deployment strategy to follow to upgrade the primary server during a rolling\nupdate procedure, after all replicas have been successfully updated:\nit can be automated (`unsupervised` - default) or manual (`supervised`)";
          type = (types.nullOr types.str);
        };
        "priorityClassName" = mkOption {
          description = "Name of the priority class which will be used in every generated Pod, if the PriorityClass\nspecified does not exist, the pod will not be able to schedule.  Please refer to\nhttps://kubernetes.io/docs/concepts/scheduling-eviction/pod-priority-preemption/#priorityclass\nfor more information";
          type = (types.nullOr types.str);
        };
        "probes" = mkOption {
          description = "The configuration of the probes to be injected\nin the PostgreSQL Pods.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProbes"));
        };
        "projectedVolumeTemplate" = mkOption {
          description = "Template to be used to define projected volumes, projected volumes will be mounted\nunder `/projected` base folder";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplate"));
        };
        "replica" = mkOption {
          description = "Replica cluster configuration";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecReplica"));
        };
        "replicationSlots" = mkOption {
          description = "Replication slots management configuration";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecReplicationSlots"));
        };
        "resources" = mkOption {
          description = "Resources requirements of every generated Pod. Please refer to\nhttps://kubernetes.io/docs/concepts/configuration/manage-resources-containers/\nfor more information.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecResources"));
        };
        "schedulerName" = mkOption {
          description = "If specified, the pod will be dispatched by specified Kubernetes\nscheduler. If not specified, the pod will be dispatched by the default\nscheduler. More info:\nhttps://kubernetes.io/docs/concepts/scheduling-eviction/kube-scheduler/";
          type = (types.nullOr types.str);
        };
        "seccompProfile" = mkOption {
          description = "The SeccompProfile applied to every Pod and Container.\nDefaults to: `RuntimeDefault`";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecSeccompProfile"));
        };
        "securityContext" = mkOption {
          description = "Override the SecurityContext applied to every Container in the Pod of the cluster.\nWhen set, this overrides the operator's default Container SecurityContext.\nIf omitted, the operator defaults are used.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecSecurityContext"));
        };
        "serviceAccountTemplate" = mkOption {
          description = "Configure the generation of the service account";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecServiceAccountTemplate"));
        };
        "smartShutdownTimeout" = mkOption {
          description = "The time in seconds that controls the window of time reserved for the smart shutdown of Postgres to complete.\nMake sure you reserve enough time for the operator to request a fast shutdown of Postgres\n(that is: `stopDelay` - `smartShutdownTimeout`). Default is 180 seconds.";
          type = (types.nullOr types.int);
        };
        "startDelay" = mkOption {
          description = "The time in seconds that is allowed for a PostgreSQL instance to\nsuccessfully start up (default 3600).\nThe startup probe failure threshold is derived from this value using the formula:\nceiling(startDelay / 10).";
          type = (types.nullOr types.int);
        };
        "stopDelay" = mkOption {
          description = "The time in seconds that is allowed for a PostgreSQL instance to\ngracefully shutdown (default 1800)";
          type = (types.nullOr types.int);
        };
        "storage" = mkOption {
          description = "Configuration of the storage of the instances";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecStorage"));
        };
        "superuserSecret" = mkOption {
          description = "The secret containing the superuser password. If not defined a new\nsecret will be created with a randomly generated password";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecSuperuserSecret"));
        };
        "switchoverDelay" = mkOption {
          description = "The time in seconds that is allowed for a primary PostgreSQL instance\nto gracefully shutdown during a switchover.\nDefault value is 3600 seconds (1 hour).";
          type = (types.nullOr types.int);
        };
        "tablespaces" = mkOption {
          description = "The tablespaces configuration";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.ClusterSpecTablespaces" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "topologySpreadConstraints" = mkOption {
          description = "TopologySpreadConstraints specifies how to spread matching pods among the given topology.\nMore info:\nhttps://kubernetes.io/docs/concepts/scheduling-eviction/topology-spread-constraints/";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecTopologySpreadConstraints")
            )
          );
        };
        "walStorage" = mkOption {
          description = "Configuration of the storage for PostgreSQL WAL (Write-Ahead Log)";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecWalStorage"));
        };
      };

      config = {
        "affinity" = mkOverride 1002 null;
        "backup" = mkOverride 1002 null;
        "bootstrap" = mkOverride 1002 null;
        "certificates" = mkOverride 1002 null;
        "description" = mkOverride 1002 null;
        "enablePDB" = mkOverride 1002 null;
        "enableSuperuserAccess" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "envFrom" = mkOverride 1002 null;
        "ephemeralVolumeSource" = mkOverride 1002 null;
        "ephemeralVolumesSizeLimit" = mkOverride 1002 null;
        "externalClusters" = mkOverride 1002 null;
        "failoverDelay" = mkOverride 1002 null;
        "imageCatalogRef" = mkOverride 1002 null;
        "imageName" = mkOverride 1002 null;
        "imagePullPolicy" = mkOverride 1002 null;
        "imagePullSecrets" = mkOverride 1002 null;
        "inheritedMetadata" = mkOverride 1002 null;
        "livenessProbeTimeout" = mkOverride 1002 null;
        "logLevel" = mkOverride 1002 null;
        "managed" = mkOverride 1002 null;
        "maxSyncReplicas" = mkOverride 1002 null;
        "minSyncReplicas" = mkOverride 1002 null;
        "monitoring" = mkOverride 1002 null;
        "nodeMaintenanceWindow" = mkOverride 1002 null;
        "plugins" = mkOverride 1002 null;
        "podSecurityContext" = mkOverride 1002 null;
        "postgresGID" = mkOverride 1002 null;
        "postgresUID" = mkOverride 1002 null;
        "postgresql" = mkOverride 1002 null;
        "primaryUpdateMethod" = mkOverride 1002 null;
        "primaryUpdateStrategy" = mkOverride 1002 null;
        "priorityClassName" = mkOverride 1002 null;
        "probes" = mkOverride 1002 null;
        "projectedVolumeTemplate" = mkOverride 1002 null;
        "replica" = mkOverride 1002 null;
        "replicationSlots" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "schedulerName" = mkOverride 1002 null;
        "seccompProfile" = mkOverride 1002 null;
        "securityContext" = mkOverride 1002 null;
        "serviceAccountTemplate" = mkOverride 1002 null;
        "smartShutdownTimeout" = mkOverride 1002 null;
        "startDelay" = mkOverride 1002 null;
        "stopDelay" = mkOverride 1002 null;
        "storage" = mkOverride 1002 null;
        "superuserSecret" = mkOverride 1002 null;
        "switchoverDelay" = mkOverride 1002 null;
        "tablespaces" = mkOverride 1002 null;
        "topologySpreadConstraints" = mkOverride 1002 null;
        "walStorage" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecAffinity" = {

      options = {
        "additionalPodAffinity" = mkOption {
          description = "AdditionalPodAffinity allows to specify pod affinity terms to be passed to all the cluster's pods.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinity")
          );
        };
        "additionalPodAntiAffinity" = mkOption {
          description = "AdditionalPodAntiAffinity allows to specify pod anti-affinity terms to be added to the ones generated\nby the operator if EnablePodAntiAffinity is set to true (default) or to be used exclusively if set to false.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinity")
          );
        };
        "enablePodAntiAffinity" = mkOption {
          description = "Activates anti-affinity for the pods. The operator will define pods\nanti-affinity unless this field is explicitly set to false";
          type = (types.nullOr types.bool);
        };
        "nodeAffinity" = mkOption {
          description = "NodeAffinity describes node affinity scheduling rules for the pod.\nMore info: https://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#node-affinity";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinity"));
        };
        "nodeSelector" = mkOption {
          description = "NodeSelector is map of key-value pairs used to define the nodes on which\nthe pods can run.\nMore info: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "podAntiAffinityType" = mkOption {
          description = "PodAntiAffinityType allows the user to decide whether pod anti-affinity between cluster instance has to be\nconsidered a strong requirement during scheduling or not. Allowed values are: \"preferred\" (default if empty) or\n\"required\". Setting it to \"required\", could lead to instances remaining pending until new kubernetes nodes are\nadded if all the existing nodes don't match the required pod anti-affinity rule.\nMore info:\nhttps://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#inter-pod-affinity-and-anti-affinity";
          type = (types.nullOr types.str);
        };
        "tolerations" = mkOption {
          description = "Tolerations is a list of Tolerations that should be set for all the pods, in order to allow them to run\non tainted nodes.\nMore info: https://kubernetes.io/docs/concepts/scheduling-eviction/taint-and-toleration/";
          type = (
            types.nullOr (types.listOf (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityTolerations"))
          );
        };
        "topologyKey" = mkOption {
          description = "TopologyKey to use for anti-affinity configuration. See k8s documentation\nfor more info on that";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "additionalPodAffinity" = mkOverride 1002 null;
        "additionalPodAntiAffinity" = mkOverride 1002 null;
        "enablePodAntiAffinity" = mkOverride 1002 null;
        "nodeAffinity" = mkOverride 1002 null;
        "nodeSelector" = mkOverride 1002 null;
        "podAntiAffinityType" = mkOverride 1002 null;
        "tolerations" = mkOverride 1002 null;
        "topologyKey" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "The scheduler will prefer to schedule pods to nodes that satisfy\nthe affinity expressions specified by this field, but it may choose\na node that violates one or more of the expressions. The node that is\nmost preferred is the one with the greatest sum of weights, i.e.\nfor each node that meets all of the scheduling requirements (resource\nrequest, requiredDuringScheduling affinity expressions, etc.),\ncompute a sum by iterating through the elements of this field and adding\n\"weight\" to the sum if the node has pods which matches the corresponding podAffinityTerm; the\nnode(s) with the highest sum are the most preferred.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "If the affinity requirements specified by this field are not met at\nscheduling time, the pod will not be scheduled onto the node.\nIf the affinity requirements specified by this field cease to be met\nat some point during pod execution (e.g. due to a pod label update), the\nsystem may or may not try to eventually evict the pod from its node.\nWhen there are multiple elements, the lists of nodes corresponding to each\npodAffinityTerm are intersected, i.e. all terms must be satisfied.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityRequiredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "podAffinityTerm" = mkOption {
            description = "Required. A pod affinity term, associated with the corresponding weight.";
            type = (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm"
            );
          };
          "weight" = mkOption {
            description = "weight associated with matching the corresponding podAffinityTerm,\nin the range 1-100.";
            type = types.int;
          };
        };

        config = { };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "A label query over a set of resources, in this case pods.\nIf it's null, this PodAffinityTerm matches with no Pods.";
            type = (
              types.nullOr (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "MatchLabelKeys is a set of pod label keys to select which pods will\nbe taken into consideration. The keys are used to lookup values from the\nincoming pod labels, those key-value labels are merged with `labelSelector` as `key in (value)`\nto select the group of existing pods which pods will be taken into consideration\nfor the incoming pod's pod (anti) affinity. Keys that don't exist in the incoming\npod labels will be ignored. The default value is empty.\nThe same key is forbidden to exist in both matchLabelKeys and labelSelector.\nAlso, matchLabelKeys cannot be set when labelSelector isn't set.";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "MismatchLabelKeys is a set of pod label keys to select which pods will\nbe taken into consideration. The keys are used to lookup values from the\nincoming pod labels, those key-value labels are merged with `labelSelector` as `key notin (value)`\nto select the group of existing pods which pods will be taken into consideration\nfor the incoming pod's pod (anti) affinity. Keys that don't exist in the incoming\npod labels will be ignored. The default value is empty.\nThe same key is forbidden to exist in both mismatchLabelKeys and labelSelector.\nAlso, mismatchLabelKeys cannot be set when labelSelector isn't set.";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "A label query over the set of namespaces that the term applies to.\nThe term is applied to the union of the namespaces selected by this field\nand the ones listed in the namespaces field.\nnull selector and null or empty namespaces list means \"this pod's namespace\".\nAn empty selector ({}) matches all namespaces.";
            type = (
              types.nullOr (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "namespaces specifies a static list of namespace names that the term applies to.\nThe term is applied to the union of the namespaces listed in this field\nand the ones selected by namespaceSelector.\nnull or empty namespaces list and null namespaceSelector means \"this pod's namespace\".";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "This pod should be co-located (affinity) or not co-located (anti-affinity) with the pods matching\nthe labelSelector in the specified namespaces, where co-located is defined as running on a node\nwhose value of the label with key topologyKey matches that of any node on which any of the\nselected pods is running.\nEmpty topologyKey is not allowed.";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels\nmap is equivalent to an element of matchExpressions, whose key field is \"key\", the\noperator is \"In\", and the values array contains only \"value\". The requirements are ANDed.";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "key is the label key that the selector applies to.";
            type = types.str;
          };
          "operator" = mkOption {
            description = "operator represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists and DoesNotExist.";
            type = types.str;
          };
          "values" = mkOption {
            description = "values is an array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. This array is replaced during a strategic\nmerge patch.";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels\nmap is equivalent to an element of matchExpressions, whose key field is \"key\", the\noperator is \"In\", and the values array contains only \"value\". The requirements are ANDed.";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "key is the label key that the selector applies to.";
            type = types.str;
          };
          "operator" = mkOption {
            description = "operator represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists and DoesNotExist.";
            type = types.str;
          };
          "values" = mkOption {
            description = "values is an array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. This array is replaced during a strategic\nmerge patch.";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "A label query over a set of resources, in this case pods.\nIf it's null, this PodAffinityTerm matches with no Pods.";
            type = (
              types.nullOr (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "MatchLabelKeys is a set of pod label keys to select which pods will\nbe taken into consideration. The keys are used to lookup values from the\nincoming pod labels, those key-value labels are merged with `labelSelector` as `key in (value)`\nto select the group of existing pods which pods will be taken into consideration\nfor the incoming pod's pod (anti) affinity. Keys that don't exist in the incoming\npod labels will be ignored. The default value is empty.\nThe same key is forbidden to exist in both matchLabelKeys and labelSelector.\nAlso, matchLabelKeys cannot be set when labelSelector isn't set.";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "MismatchLabelKeys is a set of pod label keys to select which pods will\nbe taken into consideration. The keys are used to lookup values from the\nincoming pod labels, those key-value labels are merged with `labelSelector` as `key notin (value)`\nto select the group of existing pods which pods will be taken into consideration\nfor the incoming pod's pod (anti) affinity. Keys that don't exist in the incoming\npod labels will be ignored. The default value is empty.\nThe same key is forbidden to exist in both mismatchLabelKeys and labelSelector.\nAlso, mismatchLabelKeys cannot be set when labelSelector isn't set.";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "A label query over the set of namespaces that the term applies to.\nThe term is applied to the union of the namespaces selected by this field\nand the ones listed in the namespaces field.\nnull selector and null or empty namespaces list means \"this pod's namespace\".\nAn empty selector ({}) matches all namespaces.";
            type = (
              types.nullOr (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "namespaces specifies a static list of namespace names that the term applies to.\nThe term is applied to the union of the namespaces listed in this field\nand the ones selected by namespaceSelector.\nnull or empty namespaces list and null namespaceSelector means \"this pod's namespace\".";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "This pod should be co-located (affinity) or not co-located (anti-affinity) with the pods matching\nthe labelSelector in the specified namespaces, where co-located is defined as running on a node\nwhose value of the label with key topologyKey matches that of any node on which any of the\nselected pods is running.\nEmpty topologyKey is not allowed.";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels\nmap is equivalent to an element of matchExpressions, whose key field is \"key\", the\noperator is \"In\", and the values array contains only \"value\". The requirements are ANDed.";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "key is the label key that the selector applies to.";
            type = types.str;
          };
          "operator" = mkOption {
            description = "operator represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists and DoesNotExist.";
            type = types.str;
          };
          "values" = mkOption {
            description = "values is an array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. This array is replaced during a strategic\nmerge patch.";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels\nmap is equivalent to an element of matchExpressions, whose key field is \"key\", the\noperator is \"In\", and the values array contains only \"value\". The requirements are ANDed.";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "key is the label key that the selector applies to.";
            type = types.str;
          };
          "operator" = mkOption {
            description = "operator represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists and DoesNotExist.";
            type = types.str;
          };
          "values" = mkOption {
            description = "values is an array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. This array is replaced during a strategic\nmerge patch.";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "The scheduler will prefer to schedule pods to nodes that satisfy\nthe anti-affinity expressions specified by this field, but it may choose\na node that violates one or more of the expressions. The node that is\nmost preferred is the one with the greatest sum of weights, i.e.\nfor each node that meets all of the scheduling requirements (resource\nrequest, requiredDuringScheduling anti-affinity expressions, etc.),\ncompute a sum by iterating through the elements of this field and subtracting\n\"weight\" from the sum if the node has pods which matches the corresponding podAffinityTerm; the\nnode(s) with the highest sum are the most preferred.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "If the anti-affinity requirements specified by this field are not met at\nscheduling time, the pod will not be scheduled onto the node.\nIf the anti-affinity requirements specified by this field cease to be met\nat some point during pod execution (e.g. due to a pod label update), the\nsystem may or may not try to eventually evict the pod from its node.\nWhen there are multiple elements, the lists of nodes corresponding to each\npodAffinityTerm are intersected, i.e. all terms must be satisfied.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "podAffinityTerm" = mkOption {
            description = "Required. A pod affinity term, associated with the corresponding weight.";
            type = (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm"
            );
          };
          "weight" = mkOption {
            description = "weight associated with matching the corresponding podAffinityTerm,\nin the range 1-100.";
            type = types.int;
          };
        };

        config = { };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "A label query over a set of resources, in this case pods.\nIf it's null, this PodAffinityTerm matches with no Pods.";
            type = (
              types.nullOr (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "MatchLabelKeys is a set of pod label keys to select which pods will\nbe taken into consideration. The keys are used to lookup values from the\nincoming pod labels, those key-value labels are merged with `labelSelector` as `key in (value)`\nto select the group of existing pods which pods will be taken into consideration\nfor the incoming pod's pod (anti) affinity. Keys that don't exist in the incoming\npod labels will be ignored. The default value is empty.\nThe same key is forbidden to exist in both matchLabelKeys and labelSelector.\nAlso, matchLabelKeys cannot be set when labelSelector isn't set.";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "MismatchLabelKeys is a set of pod label keys to select which pods will\nbe taken into consideration. The keys are used to lookup values from the\nincoming pod labels, those key-value labels are merged with `labelSelector` as `key notin (value)`\nto select the group of existing pods which pods will be taken into consideration\nfor the incoming pod's pod (anti) affinity. Keys that don't exist in the incoming\npod labels will be ignored. The default value is empty.\nThe same key is forbidden to exist in both mismatchLabelKeys and labelSelector.\nAlso, mismatchLabelKeys cannot be set when labelSelector isn't set.";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "A label query over the set of namespaces that the term applies to.\nThe term is applied to the union of the namespaces selected by this field\nand the ones listed in the namespaces field.\nnull selector and null or empty namespaces list means \"this pod's namespace\".\nAn empty selector ({}) matches all namespaces.";
            type = (
              types.nullOr (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "namespaces specifies a static list of namespace names that the term applies to.\nThe term is applied to the union of the namespaces listed in this field\nand the ones selected by namespaceSelector.\nnull or empty namespaces list and null namespaceSelector means \"this pod's namespace\".";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "This pod should be co-located (affinity) or not co-located (anti-affinity) with the pods matching\nthe labelSelector in the specified namespaces, where co-located is defined as running on a node\nwhose value of the label with key topologyKey matches that of any node on which any of the\nselected pods is running.\nEmpty topologyKey is not allowed.";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels\nmap is equivalent to an element of matchExpressions, whose key field is \"key\", the\noperator is \"In\", and the values array contains only \"value\". The requirements are ANDed.";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "key is the label key that the selector applies to.";
            type = types.str;
          };
          "operator" = mkOption {
            description = "operator represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists and DoesNotExist.";
            type = types.str;
          };
          "values" = mkOption {
            description = "values is an array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. This array is replaced during a strategic\nmerge patch.";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels\nmap is equivalent to an element of matchExpressions, whose key field is \"key\", the\noperator is \"In\", and the values array contains only \"value\". The requirements are ANDed.";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "key is the label key that the selector applies to.";
            type = types.str;
          };
          "operator" = mkOption {
            description = "operator represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists and DoesNotExist.";
            type = types.str;
          };
          "values" = mkOption {
            description = "values is an array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. This array is replaced during a strategic\nmerge patch.";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "A label query over a set of resources, in this case pods.\nIf it's null, this PodAffinityTerm matches with no Pods.";
            type = (
              types.nullOr (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector"
              )
            );
          };
          "matchLabelKeys" = mkOption {
            description = "MatchLabelKeys is a set of pod label keys to select which pods will\nbe taken into consideration. The keys are used to lookup values from the\nincoming pod labels, those key-value labels are merged with `labelSelector` as `key in (value)`\nto select the group of existing pods which pods will be taken into consideration\nfor the incoming pod's pod (anti) affinity. Keys that don't exist in the incoming\npod labels will be ignored. The default value is empty.\nThe same key is forbidden to exist in both matchLabelKeys and labelSelector.\nAlso, matchLabelKeys cannot be set when labelSelector isn't set.";
            type = (types.nullOr (types.listOf types.str));
          };
          "mismatchLabelKeys" = mkOption {
            description = "MismatchLabelKeys is a set of pod label keys to select which pods will\nbe taken into consideration. The keys are used to lookup values from the\nincoming pod labels, those key-value labels are merged with `labelSelector` as `key notin (value)`\nto select the group of existing pods which pods will be taken into consideration\nfor the incoming pod's pod (anti) affinity. Keys that don't exist in the incoming\npod labels will be ignored. The default value is empty.\nThe same key is forbidden to exist in both mismatchLabelKeys and labelSelector.\nAlso, mismatchLabelKeys cannot be set when labelSelector isn't set.";
            type = (types.nullOr (types.listOf types.str));
          };
          "namespaceSelector" = mkOption {
            description = "A label query over the set of namespaces that the term applies to.\nThe term is applied to the union of the namespaces selected by this field\nand the ones listed in the namespaces field.\nnull selector and null or empty namespaces list means \"this pod's namespace\".\nAn empty selector ({}) matches all namespaces.";
            type = (
              types.nullOr (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector"
              )
            );
          };
          "namespaces" = mkOption {
            description = "namespaces specifies a static list of namespace names that the term applies to.\nThe term is applied to the union of the namespaces listed in this field\nand the ones selected by namespaceSelector.\nnull or empty namespaces list and null namespaceSelector means \"this pod's namespace\".";
            type = (types.nullOr (types.listOf types.str));
          };
          "topologyKey" = mkOption {
            description = "This pod should be co-located (affinity) or not co-located (anti-affinity) with the pods matching\nthe labelSelector in the specified namespaces, where co-located is defined as running on a node\nwhose value of the label with key topologyKey matches that of any node on which any of the\nselected pods is running.\nEmpty topologyKey is not allowed.";
            type = types.str;
          };
        };

        config = {
          "labelSelector" = mkOverride 1002 null;
          "matchLabelKeys" = mkOverride 1002 null;
          "mismatchLabelKeys" = mkOverride 1002 null;
          "namespaceSelector" = mkOverride 1002 null;
          "namespaces" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels\nmap is equivalent to an element of matchExpressions, whose key field is \"key\", the\noperator is \"In\", and the values array contains only \"value\". The requirements are ANDed.";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "key is the label key that the selector applies to.";
            type = types.str;
          };
          "operator" = mkOption {
            description = "operator represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists and DoesNotExist.";
            type = types.str;
          };
          "values" = mkOption {
            description = "values is an array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. This array is replaced during a strategic\nmerge patch.";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions"
                )
              )
            );
          };
          "matchLabels" = mkOption {
            description = "matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels\nmap is equivalent to an element of matchExpressions, whose key field is \"key\", the\noperator is \"In\", and the values array contains only \"value\". The requirements are ANDed.";
            type = (types.nullOr (types.attrsOf types.str));
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchLabels" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityAdditionalPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "key is the label key that the selector applies to.";
            type = types.str;
          };
          "operator" = mkOption {
            description = "operator represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists and DoesNotExist.";
            type = types.str;
          };
          "values" = mkOption {
            description = "values is an array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. This array is replaced during a strategic\nmerge patch.";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "The scheduler will prefer to schedule pods to nodes that satisfy\nthe affinity expressions specified by this field, but it may choose\na node that violates one or more of the expressions. The node that is\nmost preferred is the one with the greatest sum of weights, i.e.\nfor each node that meets all of the scheduling requirements (resource\nrequest, requiredDuringScheduling affinity expressions, etc.),\ncompute a sum by iterating through the elements of this field and adding\n\"weight\" to the sum if the node matches the corresponding matchExpressions; the\nnode(s) with the highest sum are the most preferred.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "If the affinity requirements specified by this field are not met at\nscheduling time, the pod will not be scheduled onto the node.\nIf the affinity requirements specified by this field cease to be met\nat some point during pod execution (e.g. due to an update), the system\nmay or may not try to eventually evict the pod from its node.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecution"
            )
          );
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "preference" = mkOption {
            description = "A node selector term, associated with the corresponding weight.";
            type = (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreference"
            );
          };
          "weight" = mkOption {
            description = "Weight associated with matching the corresponding nodeSelectorTerm, in the range 1-100.";
            type = types.int;
          };
        };

        config = { };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreference" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "A list of node selector requirements by node's labels.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchExpressions"
                )
              )
            );
          };
          "matchFields" = mkOption {
            description = "A list of node selector requirements by node's fields.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchFields"
                )
              )
            );
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchFields" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "The label key that the selector applies to.";
            type = types.str;
          };
          "operator" = mkOption {
            description = "Represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists, DoesNotExist. Gt, and Lt.";
            type = types.str;
          };
          "values" = mkOption {
            description = "An array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. If the operator is Gt or Lt, the values\narray must have a single element, which will be interpreted as an integer.\nThis array is replaced during a strategic merge patch.";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchFields" =
      {

        options = {
          "key" = mkOption {
            description = "The label key that the selector applies to.";
            type = types.str;
          };
          "operator" = mkOption {
            description = "Represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists, DoesNotExist. Gt, and Lt.";
            type = types.str;
          };
          "values" = mkOption {
            description = "An array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. If the operator is Gt or Lt, the values\narray must have a single element, which will be interpreted as an integer.\nThis array is replaced during a strategic merge patch.";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "nodeSelectorTerms" = mkOption {
            description = "Required. A list of node selector terms. The terms are ORed.";
            type = (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTerms"
              )
            );
          };
        };

        config = { };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTerms" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "A list of node selector requirements by node's labels.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchExpressions"
                )
              )
            );
          };
          "matchFields" = mkOption {
            description = "A list of node selector requirements by node's fields.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchFields"
                )
              )
            );
          };
        };

        config = {
          "matchExpressions" = mkOverride 1002 null;
          "matchFields" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "The label key that the selector applies to.";
            type = types.str;
          };
          "operator" = mkOption {
            description = "Represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists, DoesNotExist. Gt, and Lt.";
            type = types.str;
          };
          "values" = mkOption {
            description = "An array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. If the operator is Gt or Lt, the values\narray must have a single element, which will be interpreted as an integer.\nThis array is replaced during a strategic merge patch.";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchFields" =
      {

        options = {
          "key" = mkOption {
            description = "The label key that the selector applies to.";
            type = types.str;
          };
          "operator" = mkOption {
            description = "Represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists, DoesNotExist. Gt, and Lt.";
            type = types.str;
          };
          "values" = mkOption {
            description = "An array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. If the operator is Gt or Lt, the values\narray must have a single element, which will be interpreted as an integer.\nThis array is replaced during a strategic merge patch.";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecAffinityTolerations" = {

      options = {
        "effect" = mkOption {
          description = "Effect indicates the taint effect to match. Empty means match all taint effects.\nWhen specified, allowed values are NoSchedule, PreferNoSchedule and NoExecute.";
          type = (types.nullOr types.str);
        };
        "key" = mkOption {
          description = "Key is the taint key that the toleration applies to. Empty means match all taint keys.\nIf the key is empty, operator must be Exists; this combination means to match all values and all keys.";
          type = (types.nullOr types.str);
        };
        "operator" = mkOption {
          description = "Operator represents a key's relationship to the value.\nValid operators are Exists and Equal. Defaults to Equal.\nExists is equivalent to wildcard for value, so that a pod can\ntolerate all taints of a particular category.";
          type = (types.nullOr types.str);
        };
        "tolerationSeconds" = mkOption {
          description = "TolerationSeconds represents the period of time the toleration (which must be\nof effect NoExecute, otherwise this field is ignored) tolerates the taint. By default,\nit is not set, which means tolerate the taint forever (do not evict). Zero and\nnegative values will be treated as 0 (evict immediately) by the system.";
          type = (types.nullOr types.int);
        };
        "value" = mkOption {
          description = "Value is the taint value the toleration matches to.\nIf the operator is Exists, the value should be empty, otherwise just a regular string.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "effect" = mkOverride 1002 null;
        "key" = mkOverride 1002 null;
        "operator" = mkOverride 1002 null;
        "tolerationSeconds" = mkOverride 1002 null;
        "value" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackup" = {

      options = {
        "barmanObjectStore" = mkOption {
          description = "The configuration for the barman-cloud tool suite";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStore"));
        };
        "retentionPolicy" = mkOption {
          description = "RetentionPolicy is the retention policy to be used for backups\nand WALs (i.e. '60d'). The retention policy is expressed in the form\nof `XXu` where `XX` is a positive integer and `u` is in `[dwm]` -\ndays, weeks, months.\nIt's currently only applicable when using the BarmanObjectStore method.";
          type = (types.nullOr types.str);
        };
        "target" = mkOption {
          description = "The policy to decide which instance should perform backups. Available\noptions are empty string, which will default to `prefer-standby` policy,\n`primary` to have backups run always on primary instances, `prefer-standby`\nto have backups run preferably on the most updated standby, if available.";
          type = (types.nullOr types.str);
        };
        "volumeSnapshot" = mkOption {
          description = "VolumeSnapshot provides the configuration for the execution of volume snapshot backups.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupVolumeSnapshot"));
        };
      };

      config = {
        "barmanObjectStore" = mkOverride 1002 null;
        "retentionPolicy" = mkOverride 1002 null;
        "target" = mkOverride 1002 null;
        "volumeSnapshot" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStore" = {

      options = {
        "azureCredentials" = mkOption {
          description = "The credentials to use to upload data to Azure Blob Storage";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreAzureCredentials"
            )
          );
        };
        "data" = mkOption {
          description = "The configuration to be used to backup the data files\nWhen not defined, base backups files will be stored uncompressed and may\nbe unencrypted in the object store, according to the bucket default\npolicy.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreData"));
        };
        "destinationPath" = mkOption {
          description = "The path where to store the backup (i.e. s3://bucket/path/to/folder)\nthis path, with different destination folders, will be used for WALs\nand for data";
          type = types.str;
        };
        "endpointCA" = mkOption {
          description = "EndpointCA store the CA bundle of the barman endpoint.\nUseful when using self-signed certificates to avoid\nerrors with certificate issuer and barman-cloud-wal-archive";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreEndpointCA")
          );
        };
        "endpointURL" = mkOption {
          description = "Endpoint to be used to upload data to the cloud,\noverriding the automatic endpoint discovery";
          type = (types.nullOr types.str);
        };
        "googleCredentials" = mkOption {
          description = "The credentials to use to upload data to Google Cloud Storage";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreGoogleCredentials"
            )
          );
        };
        "historyTags" = mkOption {
          description = "HistoryTags is a list of key value pairs that will be passed to the\nBarman --history-tags option.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "s3Credentials" = mkOption {
          description = "The credentials to use to upload data to S3";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreS3Credentials")
          );
        };
        "serverName" = mkOption {
          description = "The server name on S3, the cluster name is used if this\nparameter is omitted";
          type = (types.nullOr types.str);
        };
        "tags" = mkOption {
          description = "Tags is a list of key value pairs that will be passed to the\nBarman --tags option.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "wal" = mkOption {
          description = "The configuration for the backup of the WAL stream.\nWhen not defined, WAL files will be stored uncompressed and may be\nunencrypted in the object store, according to the bucket default policy.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreWal"));
        };
      };

      config = {
        "azureCredentials" = mkOverride 1002 null;
        "data" = mkOverride 1002 null;
        "endpointCA" = mkOverride 1002 null;
        "endpointURL" = mkOverride 1002 null;
        "googleCredentials" = mkOverride 1002 null;
        "historyTags" = mkOverride 1002 null;
        "s3Credentials" = mkOverride 1002 null;
        "serverName" = mkOverride 1002 null;
        "tags" = mkOverride 1002 null;
        "wal" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreAzureCredentials" = {

      options = {
        "connectionString" = mkOption {
          description = "The connection string to be used";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreAzureCredentialsConnectionString"
            )
          );
        };
        "inheritFromAzureAD" = mkOption {
          description = "Use the Azure AD based authentication without providing explicitly the keys.";
          type = (types.nullOr types.bool);
        };
        "storageAccount" = mkOption {
          description = "The storage account where to upload data";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreAzureCredentialsStorageAccount"
            )
          );
        };
        "storageKey" = mkOption {
          description = "The storage account key to be used in conjunction\nwith the storage account name";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreAzureCredentialsStorageKey"
            )
          );
        };
        "storageSasToken" = mkOption {
          description = "A shared-access-signature to be used in conjunction with\nthe storage account name";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreAzureCredentialsStorageSasToken"
            )
          );
        };
      };

      config = {
        "connectionString" = mkOverride 1002 null;
        "inheritFromAzureAD" = mkOverride 1002 null;
        "storageAccount" = mkOverride 1002 null;
        "storageKey" = mkOverride 1002 null;
        "storageSasToken" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreAzureCredentialsConnectionString" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreAzureCredentialsStorageAccount" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreAzureCredentialsStorageKey" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreAzureCredentialsStorageSasToken" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreData" = {

      options = {
        "additionalCommandArgs" = mkOption {
          description = "AdditionalCommandArgs represents additional arguments that can be appended\nto the 'barman-cloud-backup' command-line invocation. These arguments\nprovide flexibility to customize the backup process further according to\nspecific requirements or configurations.\n\nExample:\nIn a scenario where specialized backup options are required, such as setting\na specific timeout or defining custom behavior, users can use this field\nto specify additional command arguments.\n\nNote:\nIt's essential to ensure that the provided arguments are valid and supported\nby the 'barman-cloud-backup' command, to avoid potential errors or unintended\nbehavior during execution.";
          type = (types.nullOr (types.listOf types.str));
        };
        "compression" = mkOption {
          description = "Compress a backup file (a tar file per tablespace) while streaming it\nto the object store. Available options are empty string (no\ncompression, default), `gzip`, `bzip2`, and `snappy`.";
          type = (types.nullOr types.str);
        };
        "encryption" = mkOption {
          description = "Whenever to force the encryption of files (if the bucket is\nnot already configured for that).\nAllowed options are empty string (use the bucket policy, default),\n`AES256` and `aws:kms`";
          type = (types.nullOr types.str);
        };
        "immediateCheckpoint" = mkOption {
          description = "Control whether the I/O workload for the backup initial checkpoint will\nbe limited, according to the `checkpoint_completion_target` setting on\nthe PostgreSQL server. If set to true, an immediate checkpoint will be\nused, meaning PostgreSQL will complete the checkpoint as soon as\npossible. `false` by default.";
          type = (types.nullOr types.bool);
        };
        "jobs" = mkOption {
          description = "The number of parallel jobs to be used to upload the backup, defaults\nto 2";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "additionalCommandArgs" = mkOverride 1002 null;
        "compression" = mkOverride 1002 null;
        "encryption" = mkOverride 1002 null;
        "immediateCheckpoint" = mkOverride 1002 null;
        "jobs" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreEndpointCA" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreGoogleCredentials" = {

      options = {
        "applicationCredentials" = mkOption {
          description = "The secret containing the Google Cloud Storage JSON file with the credentials";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreGoogleCredentialsApplicationCredentials"
            )
          );
        };
        "gkeEnvironment" = mkOption {
          description = "If set to true, will presume that it's running inside a GKE environment,\ndefault to false.";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "applicationCredentials" = mkOverride 1002 null;
        "gkeEnvironment" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreGoogleCredentialsApplicationCredentials" =
      {

        options = {
          "key" = mkOption {
            description = "The key to select";
            type = types.str;
          };
          "name" = mkOption {
            description = "Name of the referent.";
            type = types.str;
          };
        };

        config = { };

      };
    "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreS3Credentials" = {

      options = {
        "accessKeyId" = mkOption {
          description = "The reference to the access key id";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreS3CredentialsAccessKeyId"
            )
          );
        };
        "inheritFromIAMRole" = mkOption {
          description = "Use the role based authentication without providing explicitly the keys.";
          type = (types.nullOr types.bool);
        };
        "region" = mkOption {
          description = "The reference to the secret containing the region name";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreS3CredentialsRegion"
            )
          );
        };
        "secretAccessKey" = mkOption {
          description = "The reference to the secret access key";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreS3CredentialsSecretAccessKey"
            )
          );
        };
        "sessionToken" = mkOption {
          description = "The references to the session key";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreS3CredentialsSessionToken"
            )
          );
        };
      };

      config = {
        "accessKeyId" = mkOverride 1002 null;
        "inheritFromIAMRole" = mkOverride 1002 null;
        "region" = mkOverride 1002 null;
        "secretAccessKey" = mkOverride 1002 null;
        "sessionToken" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreS3CredentialsAccessKeyId" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreS3CredentialsRegion" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreS3CredentialsSecretAccessKey" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreS3CredentialsSessionToken" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupBarmanObjectStoreWal" = {

      options = {
        "archiveAdditionalCommandArgs" = mkOption {
          description = "Additional arguments that can be appended to the 'barman-cloud-wal-archive'\ncommand-line invocation. These arguments provide flexibility to customize\nthe WAL archive process further, according to specific requirements or configurations.\n\nExample:\nIn a scenario where specialized backup options are required, such as setting\na specific timeout or defining custom behavior, users can use this field\nto specify additional command arguments.\n\nNote:\nIt's essential to ensure that the provided arguments are valid and supported\nby the 'barman-cloud-wal-archive' command, to avoid potential errors or unintended\nbehavior during execution.";
          type = (types.nullOr (types.listOf types.str));
        };
        "compression" = mkOption {
          description = "Compress a WAL file before sending it to the object store. Available\noptions are empty string (no compression, default), `gzip`, `bzip2`,\n`lz4`, `snappy`, `xz`, and `zstd`.";
          type = (types.nullOr types.str);
        };
        "encryption" = mkOption {
          description = "Whenever to force the encryption of files (if the bucket is\nnot already configured for that).\nAllowed options are empty string (use the bucket policy, default),\n`AES256` and `aws:kms`";
          type = (types.nullOr types.str);
        };
        "maxParallel" = mkOption {
          description = "Number of WAL files to be either archived in parallel (when the\nPostgreSQL instance is archiving to a backup object store) or\nrestored in parallel (when a PostgreSQL standby is fetching WAL\nfiles from a recovery object store). If not specified, WAL files\nwill be processed one at a time. It accepts a positive integer as a\nvalue - with 1 being the minimum accepted value.";
          type = (types.nullOr types.int);
        };
        "restoreAdditionalCommandArgs" = mkOption {
          description = "Additional arguments that can be appended to the 'barman-cloud-wal-restore'\ncommand-line invocation. These arguments provide flexibility to customize\nthe WAL restore process further, according to specific requirements or configurations.\n\nExample:\nIn a scenario where specialized backup options are required, such as setting\na specific timeout or defining custom behavior, users can use this field\nto specify additional command arguments.\n\nNote:\nIt's essential to ensure that the provided arguments are valid and supported\nby the 'barman-cloud-wal-restore' command, to avoid potential errors or unintended\nbehavior during execution.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "archiveAdditionalCommandArgs" = mkOverride 1002 null;
        "compression" = mkOverride 1002 null;
        "encryption" = mkOverride 1002 null;
        "maxParallel" = mkOverride 1002 null;
        "restoreAdditionalCommandArgs" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupVolumeSnapshot" = {

      options = {
        "annotations" = mkOption {
          description = "Annotations key-value pairs that will be added to .metadata.annotations snapshot resources.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "className" = mkOption {
          description = "ClassName specifies the Snapshot Class to be used for PG_DATA PersistentVolumeClaim.\nIt is the default class for the other types if no specific class is present";
          type = (types.nullOr types.str);
        };
        "labels" = mkOption {
          description = "Labels are key-value pairs that will be added to .metadata.labels snapshot resources.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "online" = mkOption {
          description = "Whether the default type of backup with volume snapshots is\nonline/hot (`true`, default) or offline/cold (`false`)";
          type = (types.nullOr types.bool);
        };
        "onlineConfiguration" = mkOption {
          description = "Configuration parameters to control the online/hot backup with volume snapshots";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBackupVolumeSnapshotOnlineConfiguration"
            )
          );
        };
        "snapshotOwnerReference" = mkOption {
          description = "SnapshotOwnerReference indicates the type of owner reference the snapshot should have";
          type = (types.nullOr types.str);
        };
        "tablespaceClassName" = mkOption {
          description = "TablespaceClassName specifies the Snapshot Class to be used for the tablespaces.\ndefaults to the PGDATA Snapshot Class, if set";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "walClassName" = mkOption {
          description = "WalClassName specifies the Snapshot Class to be used for the PG_WAL PersistentVolumeClaim.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "className" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
        "online" = mkOverride 1002 null;
        "onlineConfiguration" = mkOverride 1002 null;
        "snapshotOwnerReference" = mkOverride 1002 null;
        "tablespaceClassName" = mkOverride 1002 null;
        "walClassName" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBackupVolumeSnapshotOnlineConfiguration" = {

      options = {
        "immediateCheckpoint" = mkOption {
          description = "Control whether the I/O workload for the backup initial checkpoint will\nbe limited, according to the `checkpoint_completion_target` setting on\nthe PostgreSQL server. If set to true, an immediate checkpoint will be\nused, meaning PostgreSQL will complete the checkpoint as soon as\npossible. `false` by default.";
          type = (types.nullOr types.bool);
        };
        "waitForArchive" = mkOption {
          description = "If false, the function will return immediately after the backup is completed,\nwithout waiting for WAL to be archived.\nThis behavior is only useful with backup software that independently monitors WAL archiving.\nOtherwise, WAL required to make the backup consistent might be missing and make the backup useless.\nBy default, or when this parameter is true, pg_backup_stop will wait for WAL to be archived when archiving is\nenabled.\nOn a standby, this means that it will wait only when archive_mode = always.\nIf write activity on the primary is low, it may be useful to run pg_switch_wal on the primary in order to trigger\nan immediate segment switch.";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "immediateCheckpoint" = mkOverride 1002 null;
        "waitForArchive" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrap" = {

      options = {
        "initdb" = mkOption {
          description = "Bootstrap the cluster via initdb";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdb"));
        };
        "pg_basebackup" = mkOption {
          description = "Bootstrap the cluster taking a physical backup of another compatible\nPostgreSQL instance";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapPg_basebackup"));
        };
        "recovery" = mkOption {
          description = "Bootstrap the cluster from a backup";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapRecovery"));
        };
      };

      config = {
        "initdb" = mkOverride 1002 null;
        "pg_basebackup" = mkOverride 1002 null;
        "recovery" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdb" = {

      options = {
        "builtinLocale" = mkOption {
          description = "Specifies the locale name when the builtin provider is used.\nThis option requires `localeProvider` to be set to `builtin`.\nAvailable from PostgreSQL 17.";
          type = (types.nullOr types.str);
        };
        "dataChecksums" = mkOption {
          description = "Whether the `-k` option should be passed to initdb,\nenabling checksums on data pages (default: `false`)";
          type = (types.nullOr types.bool);
        };
        "database" = mkOption {
          description = "Name of the database used by the application. Default: `app`.";
          type = (types.nullOr types.str);
        };
        "encoding" = mkOption {
          description = "The value to be passed as option `--encoding` for initdb (default:`UTF8`)";
          type = (types.nullOr types.str);
        };
        "icuLocale" = mkOption {
          description = "Specifies the ICU locale when the ICU provider is used.\nThis option requires `localeProvider` to be set to `icu`.\nAvailable from PostgreSQL 15.";
          type = (types.nullOr types.str);
        };
        "icuRules" = mkOption {
          description = "Specifies additional collation rules to customize the behavior of the default collation.\nThis option requires `localeProvider` to be set to `icu`.\nAvailable from PostgreSQL 16.";
          type = (types.nullOr types.str);
        };
        "import" = mkOption {
          description = "Bootstraps the new cluster by importing data from an existing PostgreSQL\ninstance using logical backup (`pg_dump` and `pg_restore`)";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbImport"));
        };
        "locale" = mkOption {
          description = "Sets the default collation order and character classification in the new database.";
          type = (types.nullOr types.str);
        };
        "localeCType" = mkOption {
          description = "The value to be passed as option `--lc-ctype` for initdb (default:`C`)";
          type = (types.nullOr types.str);
        };
        "localeCollate" = mkOption {
          description = "The value to be passed as option `--lc-collate` for initdb (default:`C`)";
          type = (types.nullOr types.str);
        };
        "localeProvider" = mkOption {
          description = "This option sets the locale provider for databases created in the new cluster.\nAvailable from PostgreSQL 16.";
          type = (types.nullOr types.str);
        };
        "options" = mkOption {
          description = "The list of options that must be passed to initdb when creating the cluster.\n\nDeprecated: This could lead to inconsistent configurations,\nplease use the explicit provided parameters instead.\nIf defined, explicit values will be ignored.";
          type = (types.nullOr (types.listOf types.str));
        };
        "owner" = mkOption {
          description = "Name of the owner of the database in the instance to be used\nby applications. Defaults to the value of the `database` key.";
          type = (types.nullOr types.str);
        };
        "postInitApplicationSQL" = mkOption {
          description = "List of SQL queries to be executed as a superuser in the application\ndatabase right after the cluster has been created - to be used with extreme care\n(by default empty)";
          type = (types.nullOr (types.listOf types.str));
        };
        "postInitApplicationSQLRefs" = mkOption {
          description = "List of references to ConfigMaps or Secrets containing SQL files\nto be executed as a superuser in the application database right after\nthe cluster has been created. The references are processed in a specific order:\nfirst, all Secrets are processed, followed by all ConfigMaps.\nWithin each group, the processing order follows the sequence specified\nin their respective arrays.\n(by default empty)";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitApplicationSQLRefs"
            )
          );
        };
        "postInitSQL" = mkOption {
          description = "List of SQL queries to be executed as a superuser in the `postgres`\ndatabase right after the cluster has been created - to be used with extreme care\n(by default empty)";
          type = (types.nullOr (types.listOf types.str));
        };
        "postInitSQLRefs" = mkOption {
          description = "List of references to ConfigMaps or Secrets containing SQL files\nto be executed as a superuser in the `postgres` database right after\nthe cluster has been created. The references are processed in a specific order:\nfirst, all Secrets are processed, followed by all ConfigMaps.\nWithin each group, the processing order follows the sequence specified\nin their respective arrays.\n(by default empty)";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitSQLRefs")
          );
        };
        "postInitTemplateSQL" = mkOption {
          description = "List of SQL queries to be executed as a superuser in the `template1`\ndatabase right after the cluster has been created - to be used with extreme care\n(by default empty)";
          type = (types.nullOr (types.listOf types.str));
        };
        "postInitTemplateSQLRefs" = mkOption {
          description = "List of references to ConfigMaps or Secrets containing SQL files\nto be executed as a superuser in the `template1` database right after\nthe cluster has been created. The references are processed in a specific order:\nfirst, all Secrets are processed, followed by all ConfigMaps.\nWithin each group, the processing order follows the sequence specified\nin their respective arrays.\n(by default empty)";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitTemplateSQLRefs")
          );
        };
        "secret" = mkOption {
          description = "Name of the secret containing the initial credentials for the\nowner of the user database. If empty a new secret will be\ncreated from scratch";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbSecret"));
        };
        "walSegmentSize" = mkOption {
          description = "The value in megabytes (1 to 1024) to be passed to the `--wal-segsize`\noption for initdb (default: empty, resulting in PostgreSQL default: 16MB)";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "builtinLocale" = mkOverride 1002 null;
        "dataChecksums" = mkOverride 1002 null;
        "database" = mkOverride 1002 null;
        "encoding" = mkOverride 1002 null;
        "icuLocale" = mkOverride 1002 null;
        "icuRules" = mkOverride 1002 null;
        "import" = mkOverride 1002 null;
        "locale" = mkOverride 1002 null;
        "localeCType" = mkOverride 1002 null;
        "localeCollate" = mkOverride 1002 null;
        "localeProvider" = mkOverride 1002 null;
        "options" = mkOverride 1002 null;
        "owner" = mkOverride 1002 null;
        "postInitApplicationSQL" = mkOverride 1002 null;
        "postInitApplicationSQLRefs" = mkOverride 1002 null;
        "postInitSQL" = mkOverride 1002 null;
        "postInitSQLRefs" = mkOverride 1002 null;
        "postInitTemplateSQL" = mkOverride 1002 null;
        "postInitTemplateSQLRefs" = mkOverride 1002 null;
        "secret" = mkOverride 1002 null;
        "walSegmentSize" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbImport" = {

      options = {
        "databases" = mkOption {
          description = "The databases to import";
          type = (types.listOf types.str);
        };
        "pgDumpExtraOptions" = mkOption {
          description = "List of custom options to pass to the `pg_dump` command.\n\nIMPORTANT: Use with caution. The operator does not validate these options,\nand certain flags may interfere with its intended functionality or design.\nYou are responsible for ensuring that the provided options are compatible\nwith your environment and desired behavior.";
          type = (types.nullOr (types.listOf types.str));
        };
        "pgRestoreDataOptions" = mkOption {
          description = "Custom options to pass to the `pg_restore` command during the `data`\nsection. This setting overrides the generic `pgRestoreExtraOptions` value.\n\nIMPORTANT: Use with caution. The operator does not validate these options,\nand certain flags may interfere with its intended functionality or design.\nYou are responsible for ensuring that the provided options are compatible\nwith your environment and desired behavior.";
          type = (types.nullOr (types.listOf types.str));
        };
        "pgRestoreExtraOptions" = mkOption {
          description = "List of custom options to pass to the `pg_restore` command.\n\nIMPORTANT: Use with caution. The operator does not validate these options,\nand certain flags may interfere with its intended functionality or design.\nYou are responsible for ensuring that the provided options are compatible\nwith your environment and desired behavior.";
          type = (types.nullOr (types.listOf types.str));
        };
        "pgRestorePostdataOptions" = mkOption {
          description = "Custom options to pass to the `pg_restore` command during the `post-data`\nsection. This setting overrides the generic `pgRestoreExtraOptions` value.\n\nIMPORTANT: Use with caution. The operator does not validate these options,\nand certain flags may interfere with its intended functionality or design.\nYou are responsible for ensuring that the provided options are compatible\nwith your environment and desired behavior.";
          type = (types.nullOr (types.listOf types.str));
        };
        "pgRestorePredataOptions" = mkOption {
          description = "Custom options to pass to the `pg_restore` command during the `pre-data`\nsection. This setting overrides the generic `pgRestoreExtraOptions` value.\n\nIMPORTANT: Use with caution. The operator does not validate these options,\nand certain flags may interfere with its intended functionality or design.\nYou are responsible for ensuring that the provided options are compatible\nwith your environment and desired behavior.";
          type = (types.nullOr (types.listOf types.str));
        };
        "postImportApplicationSQL" = mkOption {
          description = "List of SQL queries to be executed as a superuser in the application\ndatabase right after is imported - to be used with extreme care\n(by default empty). Only available in microservice type.";
          type = (types.nullOr (types.listOf types.str));
        };
        "roles" = mkOption {
          description = "The roles to import";
          type = (types.nullOr (types.listOf types.str));
        };
        "schemaOnly" = mkOption {
          description = "When set to true, only the `pre-data` and `post-data` sections of\n`pg_restore` are invoked, avoiding data import. Default: `false`.";
          type = (types.nullOr types.bool);
        };
        "source" = mkOption {
          description = "The source of the import";
          type = (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbImportSource");
        };
        "type" = mkOption {
          description = "The import type. Can be `microservice` or `monolith`.";
          type = types.str;
        };
      };

      config = {
        "pgDumpExtraOptions" = mkOverride 1002 null;
        "pgRestoreDataOptions" = mkOverride 1002 null;
        "pgRestoreExtraOptions" = mkOverride 1002 null;
        "pgRestorePostdataOptions" = mkOverride 1002 null;
        "pgRestorePredataOptions" = mkOverride 1002 null;
        "postImportApplicationSQL" = mkOverride 1002 null;
        "roles" = mkOverride 1002 null;
        "schemaOnly" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbImportSource" = {

      options = {
        "externalCluster" = mkOption {
          description = "The name of the externalCluster used for import";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitApplicationSQLRefs" = {

      options = {
        "configMapRefs" = mkOption {
          description = "ConfigMapRefs holds a list of references to ConfigMaps";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitApplicationSQLRefsConfigMapRefs"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "secretRefs" = mkOption {
          description = "SecretRefs holds a list of references to Secrets";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitApplicationSQLRefsSecretRefs"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
      };

      config = {
        "configMapRefs" = mkOverride 1002 null;
        "secretRefs" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitApplicationSQLRefsConfigMapRefs" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitApplicationSQLRefsSecretRefs" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitSQLRefs" = {

      options = {
        "configMapRefs" = mkOption {
          description = "ConfigMapRefs holds a list of references to ConfigMaps";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitSQLRefsConfigMapRefs"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "secretRefs" = mkOption {
          description = "SecretRefs holds a list of references to Secrets";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitSQLRefsSecretRefs"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
      };

      config = {
        "configMapRefs" = mkOverride 1002 null;
        "secretRefs" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitSQLRefsConfigMapRefs" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitSQLRefsSecretRefs" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitTemplateSQLRefs" = {

      options = {
        "configMapRefs" = mkOption {
          description = "ConfigMapRefs holds a list of references to ConfigMaps";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitTemplateSQLRefsConfigMapRefs"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "secretRefs" = mkOption {
          description = "SecretRefs holds a list of references to Secrets";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitTemplateSQLRefsSecretRefs"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
      };

      config = {
        "configMapRefs" = mkOverride 1002 null;
        "secretRefs" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitTemplateSQLRefsConfigMapRefs" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbPostInitTemplateSQLRefsSecretRefs" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapInitdbSecret" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapPg_basebackup" = {

      options = {
        "database" = mkOption {
          description = "Name of the database used by the application. Default: `app`.";
          type = (types.nullOr types.str);
        };
        "owner" = mkOption {
          description = "Name of the owner of the database in the instance to be used\nby applications. Defaults to the value of the `database` key.";
          type = (types.nullOr types.str);
        };
        "secret" = mkOption {
          description = "Name of the secret containing the initial credentials for the\nowner of the user database. If empty a new secret will be\ncreated from scratch";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapPg_basebackupSecret"));
        };
        "source" = mkOption {
          description = "The name of the server of which we need to take a physical backup";
          type = types.str;
        };
      };

      config = {
        "database" = mkOverride 1002 null;
        "owner" = mkOverride 1002 null;
        "secret" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapPg_basebackupSecret" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapRecovery" = {

      options = {
        "backup" = mkOption {
          description = "The backup object containing the physical base backup from which to\ninitiate the recovery procedure.\nMutually exclusive with `source` and `volumeSnapshots`.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapRecoveryBackup"));
        };
        "database" = mkOption {
          description = "Name of the database used by the application. Default: `app`.";
          type = (types.nullOr types.str);
        };
        "owner" = mkOption {
          description = "Name of the owner of the database in the instance to be used\nby applications. Defaults to the value of the `database` key.";
          type = (types.nullOr types.str);
        };
        "recoveryTarget" = mkOption {
          description = "By default, the recovery process applies all the available\nWAL files in the archive (full recovery). However, you can also\nend the recovery as soon as a consistent state is reached or\nrecover to a point-in-time (PITR) by specifying a `RecoveryTarget` object,\nas expected by PostgreSQL (i.e., timestamp, transaction Id, LSN, ...).\nMore info: https://www.postgresql.org/docs/current/runtime-config-wal.html#RUNTIME-CONFIG-WAL-RECOVERY-TARGET";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapRecoveryRecoveryTarget")
          );
        };
        "secret" = mkOption {
          description = "Name of the secret containing the initial credentials for the\nowner of the user database. If empty a new secret will be\ncreated from scratch";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapRecoverySecret"));
        };
        "source" = mkOption {
          description = "The external cluster whose backup we will restore. This is also\nused as the name of the folder under which the backup is stored,\nso it must be set to the name of the source cluster\nMutually exclusive with `backup`.";
          type = (types.nullOr types.str);
        };
        "volumeSnapshots" = mkOption {
          description = "The static PVC data source(s) from which to initiate the\nrecovery procedure. Currently supporting `VolumeSnapshot`\nand `PersistentVolumeClaim` resources that map an existing\nPVC group, compatible with CloudNativePG, and taken with\na cold backup copy on a fenced Postgres instance (limitation\nwhich will be removed in the future when online backup\nwill be implemented).\nMutually exclusive with `backup`.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapRecoveryVolumeSnapshots")
          );
        };
      };

      config = {
        "backup" = mkOverride 1002 null;
        "database" = mkOverride 1002 null;
        "owner" = mkOverride 1002 null;
        "recoveryTarget" = mkOverride 1002 null;
        "secret" = mkOverride 1002 null;
        "source" = mkOverride 1002 null;
        "volumeSnapshots" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapRecoveryBackup" = {

      options = {
        "endpointCA" = mkOption {
          description = "EndpointCA store the CA bundle of the barman endpoint.\nUseful when using self-signed certificates to avoid\nerrors with certificate issuer and barman-cloud-wal-archive.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapRecoveryBackupEndpointCA")
          );
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = {
        "endpointCA" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapRecoveryBackupEndpointCA" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapRecoveryRecoveryTarget" = {

      options = {
        "backupID" = mkOption {
          description = "The ID of the backup from which to start the recovery process.\nIf empty (default) the operator will automatically detect the backup\nbased on targetTime or targetLSN if specified. Otherwise use the\nlatest available backup in chronological order.";
          type = (types.nullOr types.str);
        };
        "exclusive" = mkOption {
          description = "Set the target to be exclusive. If omitted, defaults to false, so that\nin Postgres, `recovery_target_inclusive` will be true";
          type = (types.nullOr types.bool);
        };
        "targetImmediate" = mkOption {
          description = "End recovery as soon as a consistent state is reached";
          type = (types.nullOr types.bool);
        };
        "targetLSN" = mkOption {
          description = "The target LSN (Log Sequence Number)";
          type = (types.nullOr types.str);
        };
        "targetName" = mkOption {
          description = "The target name (to be previously created\nwith `pg_create_restore_point`)";
          type = (types.nullOr types.str);
        };
        "targetTLI" = mkOption {
          description = "The target timeline (\"latest\" or a positive integer)";
          type = (types.nullOr types.str);
        };
        "targetTime" = mkOption {
          description = "The target time as a timestamp in the RFC3339 standard";
          type = (types.nullOr types.str);
        };
        "targetXID" = mkOption {
          description = "The target transaction ID";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "backupID" = mkOverride 1002 null;
        "exclusive" = mkOverride 1002 null;
        "targetImmediate" = mkOverride 1002 null;
        "targetLSN" = mkOverride 1002 null;
        "targetName" = mkOverride 1002 null;
        "targetTLI" = mkOverride 1002 null;
        "targetTime" = mkOverride 1002 null;
        "targetXID" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapRecoverySecret" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapRecoveryVolumeSnapshots" = {

      options = {
        "storage" = mkOption {
          description = "Configuration of the storage of the instances";
          type = (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapRecoveryVolumeSnapshotsStorage");
        };
        "tablespaceStorage" = mkOption {
          description = "Configuration of the storage for PostgreSQL tablespaces";
          type = (types.nullOr (types.attrsOf types.attrs));
        };
        "walStorage" = mkOption {
          description = "Configuration of the storage for PostgreSQL WAL (Write-Ahead Log)";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecBootstrapRecoveryVolumeSnapshotsWalStorage"
            )
          );
        };
      };

      config = {
        "tablespaceStorage" = mkOverride 1002 null;
        "walStorage" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapRecoveryVolumeSnapshotsStorage" = {

      options = {
        "apiGroup" = mkOption {
          description = "APIGroup is the group for the resource being referenced.\nIf APIGroup is not specified, the specified Kind must be in the core API group.\nFor any other third-party types, APIGroup is required.";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "Kind is the type of resource being referenced";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name is the name of resource being referenced";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecBootstrapRecoveryVolumeSnapshotsWalStorage" = {

      options = {
        "apiGroup" = mkOption {
          description = "APIGroup is the group for the resource being referenced.\nIf APIGroup is not specified, the specified Kind must be in the core API group.\nFor any other third-party types, APIGroup is required.";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "Kind is the type of resource being referenced";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name is the name of resource being referenced";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecCertificates" = {

      options = {
        "clientCASecret" = mkOption {
          description = "The secret containing the Client CA certificate. If not defined, a new secret will be created\nwith a self-signed CA and will be used to generate all the client certificates.<br />\n<br />\nContains:<br />\n<br />\n- `ca.crt`: CA that should be used to validate the client certificates,\nused as `ssl_ca_file` of all the instances.<br />\n- `ca.key`: key used to generate client certificates, if ReplicationTLSSecret is provided,\nthis can be omitted.<br />";
          type = (types.nullOr types.str);
        };
        "replicationTLSSecret" = mkOption {
          description = "The secret of type kubernetes.io/tls containing the client certificate to authenticate as\nthe `streaming_replica` user.\nIf not defined, ClientCASecret must provide also `ca.key`, and a new secret will be\ncreated using the provided CA.";
          type = (types.nullOr types.str);
        };
        "serverAltDNSNames" = mkOption {
          description = "The list of the server alternative DNS names to be added to the generated server TLS certificates, when required.";
          type = (types.nullOr (types.listOf types.str));
        };
        "serverCASecret" = mkOption {
          description = "The secret containing the Server CA certificate. If not defined, a new secret will be created\nwith a self-signed CA and will be used to generate the TLS certificate ServerTLSSecret.<br />\n<br />\nContains:<br />\n<br />\n- `ca.crt`: CA that should be used to validate the server certificate,\nused as `sslrootcert` in client connection strings.<br />\n- `ca.key`: key used to generate Server SSL certs, if ServerTLSSecret is provided,\nthis can be omitted.<br />";
          type = (types.nullOr types.str);
        };
        "serverTLSSecret" = mkOption {
          description = "The secret of type kubernetes.io/tls containing the server TLS certificate and key that will be set as\n`ssl_cert_file` and `ssl_key_file` so that clients can connect to postgres securely.\nIf not defined, ServerCASecret must provide also `ca.key` and a new secret will be\ncreated using the provided CA.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "clientCASecret" = mkOverride 1002 null;
        "replicationTLSSecret" = mkOverride 1002 null;
        "serverAltDNSNames" = mkOverride 1002 null;
        "serverCASecret" = mkOverride 1002 null;
        "serverTLSSecret" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEnv" = {

      options = {
        "name" = mkOption {
          description = "Name of the environment variable.\nMay consist of any printable ASCII characters except '='.";
          type = types.str;
        };
        "value" = mkOption {
          description = "Variable references $(VAR_NAME) are expanded\nusing the previously defined environment variables in the container and\nany service environment variables. If a variable cannot be resolved,\nthe reference in the input string will be unchanged. Double $$ are reduced\nto a single $, which allows for escaping the $(VAR_NAME) syntax: i.e.\n\"$$(VAR_NAME)\" will produce the string literal \"$(VAR_NAME)\".\nEscaped references will never be expanded, regardless of whether the variable\nexists or not.\nDefaults to \"\".";
          type = (types.nullOr types.str);
        };
        "valueFrom" = mkOption {
          description = "Source for the environment variable's value. Cannot be used if value is not empty.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEnvValueFrom"));
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEnvFrom" = {

      options = {
        "configMapRef" = mkOption {
          description = "The ConfigMap to select from";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEnvFromConfigMapRef"));
        };
        "prefix" = mkOption {
          description = "Optional text to prepend to the name of each environment variable.\nMay consist of any printable ASCII characters except '='.";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description = "The Secret to select from";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEnvFromSecretRef"));
        };
      };

      config = {
        "configMapRef" = mkOverride 1002 null;
        "prefix" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEnvFromConfigMapRef" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "Specify whether the ConfigMap must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEnvFromSecretRef" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "Specify whether the Secret must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "Selects a key of a ConfigMap.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEnvValueFromConfigMapKeyRef"));
        };
        "fieldRef" = mkOption {
          description = "Selects a field of the pod: supports metadata.name, metadata.namespace, `metadata.labels['<KEY>']`, `metadata.annotations['<KEY>']`,\nspec.nodeName, spec.serviceAccountName, status.hostIP, status.podIP, status.podIPs.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEnvValueFromFieldRef"));
        };
        "fileKeyRef" = mkOption {
          description = "FileKeyRef selects a key of the env file.\nRequires the EnvFiles feature gate to be enabled.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEnvValueFromFileKeyRef"));
        };
        "resourceFieldRef" = mkOption {
          description = "Selects a resource of the container: only resources limits and requests\n(limits.cpu, limits.memory, limits.ephemeral-storage, requests.cpu, requests.memory and requests.ephemeral-storage) are currently supported.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEnvValueFromResourceFieldRef"));
        };
        "secretKeyRef" = mkOption {
          description = "Selects a key of a secret in the pod's namespace";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEnvValueFromSecretKeyRef"));
        };
      };

      config = {
        "configMapKeyRef" = mkOverride 1002 null;
        "fieldRef" = mkOverride 1002 null;
        "fileKeyRef" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
        "secretKeyRef" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEnvValueFromConfigMapKeyRef" = {

      options = {
        "key" = mkOption {
          description = "The key to select.";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "Specify whether the ConfigMap or its key must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEnvValueFromFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "Version of the schema the FieldPath is written in terms of, defaults to \"v1\".";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "Path of the field to select in the specified API version.";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEnvValueFromFileKeyRef" = {

      options = {
        "key" = mkOption {
          description = "The key within the env file. An invalid key will prevent the pod from starting.\nThe keys defined within a source may consist of any printable ASCII characters except '='.\nDuring Alpha stage of the EnvFiles feature gate, the key size is limited to 128 characters.";
          type = types.str;
        };
        "optional" = mkOption {
          description = "Specify whether the file or its key must be defined. If the file or key\ndoes not exist, then the env var is not published.\nIf optional is set to true and the specified key does not exist,\nthe environment variable will not be set in the Pod's containers.\n\nIf optional is set to false and the specified key does not exist,\nan error will be returned during Pod creation.";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "The path within the volume from which to select the file.\nMust be relative and may not contain the '..' path or start with '..'.";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "The name of the volume mount containing the env file.";
          type = types.str;
        };
      };

      config = {
        "optional" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEnvValueFromResourceFieldRef" = {

      options = {
        "containerName" = mkOption {
          description = "Container name: required for volumes, optional for env vars";
          type = (types.nullOr types.str);
        };
        "divisor" = mkOption {
          description = "Specifies the output format of the exposed resources, defaults to \"1\"";
          type = (types.nullOr (types.either types.int types.str));
        };
        "resource" = mkOption {
          description = "Required: resource to select";
          type = types.str;
        };
      };

      config = {
        "containerName" = mkOverride 1002 null;
        "divisor" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEnvValueFromSecretKeyRef" = {

      options = {
        "key" = mkOption {
          description = "The key of the secret to select from.  Must be a valid secret key.";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "Specify whether the Secret or its key must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumeSource" = {

      options = {
        "volumeClaimTemplate" = mkOption {
          description = "Will be used to create a stand-alone PVC to provision the volume.\nThe pod in which this EphemeralVolumeSource is embedded will be the\nowner of the PVC, i.e. the PVC will be deleted together with the\npod.  The name of the PVC will be `<pod name>-<volume name>` where\n`<volume name>` is the name from the `PodSpec.Volumes` array\nentry. Pod validation will reject the pod if the concatenated name\nis not valid for a PVC (for example, too long).\n\nAn existing PVC with that name that is not owned by the pod\nwill *not* be used for the pod to avoid using an unrelated\nvolume by mistake. Starting the pod is then blocked until\nthe unrelated PVC is removed. If such a pre-created PVC is\nmeant to be used by the pod, the PVC has to updated with an\nowner reference to the pod once the pod exists. Normally\nthis should not be necessary, but it may be useful when\nmanually reconstructing a broken cluster.\n\nThis field is read-only and no changes will be made by Kubernetes\nto the PVC after it has been created.\n\nRequired, must not be nil.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumeSourceVolumeClaimTemplate"
            )
          );
        };
      };

      config = {
        "volumeClaimTemplate" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumeSourceVolumeClaimTemplate" = {

      options = {
        "metadata" = mkOption {
          description = "May contain labels and annotations that will be copied into the PVC\nwhen creating it. No other fields are allowed and will be rejected during\nvalidation.";
          type = (types.nullOr types.attrs);
        };
        "spec" = mkOption {
          description = "The specification for the PersistentVolumeClaim. The entire content is\ncopied unchanged into the PVC that gets created from this\ntemplate. The same fields as in a PersistentVolumeClaim\nare also valid here.";
          type = (
            submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumeSourceVolumeClaimTemplateSpec"
          );
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumeSourceVolumeClaimTemplateSpec" = {

      options = {
        "accessModes" = mkOption {
          description = "accessModes contains the desired access modes the volume should have.\nMore info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes-1";
          type = (types.nullOr (types.listOf types.str));
        };
        "dataSource" = mkOption {
          description = "dataSource field can be used to specify either:\n* An existing VolumeSnapshot object (snapshot.storage.k8s.io/VolumeSnapshot)\n* An existing PVC (PersistentVolumeClaim)\nIf the provisioner or an external controller can support the specified data source,\nit will create a new volume based on the contents of the specified data source.\nWhen the AnyVolumeDataSource feature gate is enabled, dataSource contents will be copied to dataSourceRef,\nand dataSourceRef contents will be copied to dataSource when dataSourceRef.namespace is not specified.\nIf the namespace is specified, then dataSourceRef will not be copied to dataSource.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumeSourceVolumeClaimTemplateSpecDataSource"
            )
          );
        };
        "dataSourceRef" = mkOption {
          description = "dataSourceRef specifies the object from which to populate the volume with data, if a non-empty\nvolume is desired. This may be any object from a non-empty API group (non\ncore object) or a PersistentVolumeClaim object.\nWhen this field is specified, volume binding will only succeed if the type of\nthe specified object matches some installed volume populator or dynamic\nprovisioner.\nThis field will replace the functionality of the dataSource field and as such\nif both fields are non-empty, they must have the same value. For backwards\ncompatibility, when namespace isn't specified in dataSourceRef,\nboth fields (dataSource and dataSourceRef) will be set to the same\nvalue automatically if one of them is empty and the other is non-empty.\nWhen namespace is specified in dataSourceRef,\ndataSource isn't set to the same value and must be empty.\nThere are three important differences between dataSource and dataSourceRef:\n* While dataSource only allows two specific types of objects, dataSourceRef\n  allows any non-core object, as well as PersistentVolumeClaim objects.\n* While dataSource ignores disallowed values (dropping them), dataSourceRef\n  preserves all values, and generates an error if a disallowed value is\n  specified.\n* While dataSource only allows local objects, dataSourceRef allows objects\n  in any namespaces.\n(Beta) Using this field requires the AnyVolumeDataSource feature gate to be enabled.\n(Alpha) Using the namespace field of dataSourceRef requires the CrossNamespaceVolumeDataSource feature gate to be enabled.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumeSourceVolumeClaimTemplateSpecDataSourceRef"
            )
          );
        };
        "resources" = mkOption {
          description = "resources represents the minimum resources the volume should have.\nIf RecoverVolumeExpansionFailure feature is enabled users are allowed to specify resource requirements\nthat are lower than previous value but must still be higher than capacity recorded in the\nstatus field of the claim.\nMore info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#resources";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumeSourceVolumeClaimTemplateSpecResources"
            )
          );
        };
        "selector" = mkOption {
          description = "selector is a label query over volumes to consider for binding.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumeSourceVolumeClaimTemplateSpecSelector"
            )
          );
        };
        "storageClassName" = mkOption {
          description = "storageClassName is the name of the StorageClass required by the claim.\nMore info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#class-1";
          type = (types.nullOr types.str);
        };
        "volumeAttributesClassName" = mkOption {
          description = "volumeAttributesClassName may be used to set the VolumeAttributesClass used by this claim.\nIf specified, the CSI driver will create or update the volume with the attributes defined\nin the corresponding VolumeAttributesClass. This has a different purpose than storageClassName,\nit can be changed after the claim is created. An empty string or nil value indicates that no\nVolumeAttributesClass will be applied to the claim. If the claim enters an Infeasible error state,\nthis field can be reset to its previous value (including nil) to cancel the modification.\nIf the resource referred to by volumeAttributesClass does not exist, this PersistentVolumeClaim will be\nset to a Pending state, as reflected by the modifyVolumeStatus field, until such as a resource\nexists.\nMore info: https://kubernetes.io/docs/concepts/storage/volume-attributes-classes/";
          type = (types.nullOr types.str);
        };
        "volumeMode" = mkOption {
          description = "volumeMode defines what type of volume is required by the claim.\nValue of Filesystem is implied when not included in claim spec.";
          type = (types.nullOr types.str);
        };
        "volumeName" = mkOption {
          description = "volumeName is the binding reference to the PersistentVolume backing this claim.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "dataSource" = mkOverride 1002 null;
        "dataSourceRef" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "volumeAttributesClassName" = mkOverride 1002 null;
        "volumeMode" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumeSourceVolumeClaimTemplateSpecDataSource" = {

      options = {
        "apiGroup" = mkOption {
          description = "APIGroup is the group for the resource being referenced.\nIf APIGroup is not specified, the specified Kind must be in the core API group.\nFor any other third-party types, APIGroup is required.";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "Kind is the type of resource being referenced";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name is the name of resource being referenced";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumeSourceVolumeClaimTemplateSpecDataSourceRef" = {

      options = {
        "apiGroup" = mkOption {
          description = "APIGroup is the group for the resource being referenced.\nIf APIGroup is not specified, the specified Kind must be in the core API group.\nFor any other third-party types, APIGroup is required.";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "Kind is the type of resource being referenced";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name is the name of resource being referenced";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "Namespace is the namespace of resource being referenced\nNote that when a namespace is specified, a gateway.networking.k8s.io/ReferenceGrant object is required in the referent namespace to allow that namespace's owner to accept the reference. See the ReferenceGrant documentation for details.\n(Alpha) This field requires the CrossNamespaceVolumeDataSource feature gate to be enabled.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumeSourceVolumeClaimTemplateSpecResources" = {

      options = {
        "limits" = mkOption {
          description = "Limits describes the maximum amount of compute resources allowed.\nMore info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "Requests describes the minimum amount of compute resources required.\nIf Requests is omitted for a container, it defaults to Limits if that is explicitly specified,\notherwise to an implementation-defined value. Requests cannot exceed Limits.\nMore info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumeSourceVolumeClaimTemplateSpecSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumeSourceVolumeClaimTemplateSpecSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels\nmap is equivalent to an element of matchExpressions, whose key field is \"key\", the\noperator is \"In\", and the values array contains only \"value\". The requirements are ANDed.";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumeSourceVolumeClaimTemplateSpecSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "key is the label key that the selector applies to.";
            type = types.str;
          };
          "operator" = mkOption {
            description = "operator represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists and DoesNotExist.";
            type = types.str;
          };
          "values" = mkOption {
            description = "values is an array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. This array is replaced during a strategic\nmerge patch.";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecEphemeralVolumesSizeLimit" = {

      options = {
        "shm" = mkOption {
          description = "Shm is the size limit of the shared memory volume";
          type = (types.nullOr (types.either types.int types.str));
        };
        "temporaryData" = mkOption {
          description = "TemporaryData is the size limit of the temporary data volume";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "shm" = mkOverride 1002 null;
        "temporaryData" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClusters" = {

      options = {
        "barmanObjectStore" = mkOption {
          description = "The configuration for the barman-cloud tool suite";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStore")
          );
        };
        "connectionParameters" = mkOption {
          description = "The list of connection parameters, such as dbname, host, username, etc";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "name" = mkOption {
          description = "The server name, required";
          type = types.str;
        };
        "password" = mkOption {
          description = "The reference to the password to be used to connect to the server.\nIf a password is provided, CloudNativePG creates a PostgreSQL\npassfile at `/controller/external/NAME/pass` (where \"NAME\" is the\ncluster's name). This passfile is automatically referenced in the\nconnection string when establishing a connection to the remote\nPostgreSQL server from the current PostgreSQL `Cluster`. This ensures\nsecure and efficient password management for external clusters.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersPassword"));
        };
        "plugin" = mkOption {
          description = "The configuration of the plugin that is taking care\nof WAL archiving and backups for this external cluster";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersPlugin"));
        };
        "sslCert" = mkOption {
          description = "The reference to an SSL certificate to be used to connect to this\ninstance";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersSslCert"));
        };
        "sslKey" = mkOption {
          description = "The reference to an SSL private key to be used to connect to this\ninstance";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersSslKey"));
        };
        "sslRootCert" = mkOption {
          description = "The reference to an SSL CA public key to be used to connect to this\ninstance";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersSslRootCert"));
        };
      };

      config = {
        "barmanObjectStore" = mkOverride 1002 null;
        "connectionParameters" = mkOverride 1002 null;
        "password" = mkOverride 1002 null;
        "plugin" = mkOverride 1002 null;
        "sslCert" = mkOverride 1002 null;
        "sslKey" = mkOverride 1002 null;
        "sslRootCert" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStore" = {

      options = {
        "azureCredentials" = mkOption {
          description = "The credentials to use to upload data to Azure Blob Storage";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreAzureCredentials"
            )
          );
        };
        "data" = mkOption {
          description = "The configuration to be used to backup the data files\nWhen not defined, base backups files will be stored uncompressed and may\nbe unencrypted in the object store, according to the bucket default\npolicy.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreData")
          );
        };
        "destinationPath" = mkOption {
          description = "The path where to store the backup (i.e. s3://bucket/path/to/folder)\nthis path, with different destination folders, will be used for WALs\nand for data";
          type = types.str;
        };
        "endpointCA" = mkOption {
          description = "EndpointCA store the CA bundle of the barman endpoint.\nUseful when using self-signed certificates to avoid\nerrors with certificate issuer and barman-cloud-wal-archive";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreEndpointCA"
            )
          );
        };
        "endpointURL" = mkOption {
          description = "Endpoint to be used to upload data to the cloud,\noverriding the automatic endpoint discovery";
          type = (types.nullOr types.str);
        };
        "googleCredentials" = mkOption {
          description = "The credentials to use to upload data to Google Cloud Storage";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreGoogleCredentials"
            )
          );
        };
        "historyTags" = mkOption {
          description = "HistoryTags is a list of key value pairs that will be passed to the\nBarman --history-tags option.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "s3Credentials" = mkOption {
          description = "The credentials to use to upload data to S3";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreS3Credentials"
            )
          );
        };
        "serverName" = mkOption {
          description = "The server name on S3, the cluster name is used if this\nparameter is omitted";
          type = (types.nullOr types.str);
        };
        "tags" = mkOption {
          description = "Tags is a list of key value pairs that will be passed to the\nBarman --tags option.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "wal" = mkOption {
          description = "The configuration for the backup of the WAL stream.\nWhen not defined, WAL files will be stored uncompressed and may be\nunencrypted in the object store, according to the bucket default policy.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreWal")
          );
        };
      };

      config = {
        "azureCredentials" = mkOverride 1002 null;
        "data" = mkOverride 1002 null;
        "endpointCA" = mkOverride 1002 null;
        "endpointURL" = mkOverride 1002 null;
        "googleCredentials" = mkOverride 1002 null;
        "historyTags" = mkOverride 1002 null;
        "s3Credentials" = mkOverride 1002 null;
        "serverName" = mkOverride 1002 null;
        "tags" = mkOverride 1002 null;
        "wal" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreAzureCredentials" = {

      options = {
        "connectionString" = mkOption {
          description = "The connection string to be used";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreAzureCredentialsConnectionString"
            )
          );
        };
        "inheritFromAzureAD" = mkOption {
          description = "Use the Azure AD based authentication without providing explicitly the keys.";
          type = (types.nullOr types.bool);
        };
        "storageAccount" = mkOption {
          description = "The storage account where to upload data";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreAzureCredentialsStorageAccount"
            )
          );
        };
        "storageKey" = mkOption {
          description = "The storage account key to be used in conjunction\nwith the storage account name";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreAzureCredentialsStorageKey"
            )
          );
        };
        "storageSasToken" = mkOption {
          description = "A shared-access-signature to be used in conjunction with\nthe storage account name";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreAzureCredentialsStorageSasToken"
            )
          );
        };
      };

      config = {
        "connectionString" = mkOverride 1002 null;
        "inheritFromAzureAD" = mkOverride 1002 null;
        "storageAccount" = mkOverride 1002 null;
        "storageKey" = mkOverride 1002 null;
        "storageSasToken" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreAzureCredentialsConnectionString" =
      {

        options = {
          "key" = mkOption {
            description = "The key to select";
            type = types.str;
          };
          "name" = mkOption {
            description = "Name of the referent.";
            type = types.str;
          };
        };

        config = { };

      };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreAzureCredentialsStorageAccount" =
      {

        options = {
          "key" = mkOption {
            description = "The key to select";
            type = types.str;
          };
          "name" = mkOption {
            description = "Name of the referent.";
            type = types.str;
          };
        };

        config = { };

      };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreAzureCredentialsStorageKey" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreAzureCredentialsStorageSasToken" =
      {

        options = {
          "key" = mkOption {
            description = "The key to select";
            type = types.str;
          };
          "name" = mkOption {
            description = "Name of the referent.";
            type = types.str;
          };
        };

        config = { };

      };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreData" = {

      options = {
        "additionalCommandArgs" = mkOption {
          description = "AdditionalCommandArgs represents additional arguments that can be appended\nto the 'barman-cloud-backup' command-line invocation. These arguments\nprovide flexibility to customize the backup process further according to\nspecific requirements or configurations.\n\nExample:\nIn a scenario where specialized backup options are required, such as setting\na specific timeout or defining custom behavior, users can use this field\nto specify additional command arguments.\n\nNote:\nIt's essential to ensure that the provided arguments are valid and supported\nby the 'barman-cloud-backup' command, to avoid potential errors or unintended\nbehavior during execution.";
          type = (types.nullOr (types.listOf types.str));
        };
        "compression" = mkOption {
          description = "Compress a backup file (a tar file per tablespace) while streaming it\nto the object store. Available options are empty string (no\ncompression, default), `gzip`, `bzip2`, and `snappy`.";
          type = (types.nullOr types.str);
        };
        "encryption" = mkOption {
          description = "Whenever to force the encryption of files (if the bucket is\nnot already configured for that).\nAllowed options are empty string (use the bucket policy, default),\n`AES256` and `aws:kms`";
          type = (types.nullOr types.str);
        };
        "immediateCheckpoint" = mkOption {
          description = "Control whether the I/O workload for the backup initial checkpoint will\nbe limited, according to the `checkpoint_completion_target` setting on\nthe PostgreSQL server. If set to true, an immediate checkpoint will be\nused, meaning PostgreSQL will complete the checkpoint as soon as\npossible. `false` by default.";
          type = (types.nullOr types.bool);
        };
        "jobs" = mkOption {
          description = "The number of parallel jobs to be used to upload the backup, defaults\nto 2";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "additionalCommandArgs" = mkOverride 1002 null;
        "compression" = mkOverride 1002 null;
        "encryption" = mkOverride 1002 null;
        "immediateCheckpoint" = mkOverride 1002 null;
        "jobs" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreEndpointCA" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreGoogleCredentials" = {

      options = {
        "applicationCredentials" = mkOption {
          description = "The secret containing the Google Cloud Storage JSON file with the credentials";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreGoogleCredentialsApplicationCredentials"
            )
          );
        };
        "gkeEnvironment" = mkOption {
          description = "If set to true, will presume that it's running inside a GKE environment,\ndefault to false.";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "applicationCredentials" = mkOverride 1002 null;
        "gkeEnvironment" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreGoogleCredentialsApplicationCredentials" =
      {

        options = {
          "key" = mkOption {
            description = "The key to select";
            type = types.str;
          };
          "name" = mkOption {
            description = "Name of the referent.";
            type = types.str;
          };
        };

        config = { };

      };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreS3Credentials" = {

      options = {
        "accessKeyId" = mkOption {
          description = "The reference to the access key id";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreS3CredentialsAccessKeyId"
            )
          );
        };
        "inheritFromIAMRole" = mkOption {
          description = "Use the role based authentication without providing explicitly the keys.";
          type = (types.nullOr types.bool);
        };
        "region" = mkOption {
          description = "The reference to the secret containing the region name";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreS3CredentialsRegion"
            )
          );
        };
        "secretAccessKey" = mkOption {
          description = "The reference to the secret access key";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreS3CredentialsSecretAccessKey"
            )
          );
        };
        "sessionToken" = mkOption {
          description = "The references to the session key";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreS3CredentialsSessionToken"
            )
          );
        };
      };

      config = {
        "accessKeyId" = mkOverride 1002 null;
        "inheritFromIAMRole" = mkOverride 1002 null;
        "region" = mkOverride 1002 null;
        "secretAccessKey" = mkOverride 1002 null;
        "sessionToken" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreS3CredentialsAccessKeyId" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreS3CredentialsRegion" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreS3CredentialsSecretAccessKey" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreS3CredentialsSessionToken" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersBarmanObjectStoreWal" = {

      options = {
        "archiveAdditionalCommandArgs" = mkOption {
          description = "Additional arguments that can be appended to the 'barman-cloud-wal-archive'\ncommand-line invocation. These arguments provide flexibility to customize\nthe WAL archive process further, according to specific requirements or configurations.\n\nExample:\nIn a scenario where specialized backup options are required, such as setting\na specific timeout or defining custom behavior, users can use this field\nto specify additional command arguments.\n\nNote:\nIt's essential to ensure that the provided arguments are valid and supported\nby the 'barman-cloud-wal-archive' command, to avoid potential errors or unintended\nbehavior during execution.";
          type = (types.nullOr (types.listOf types.str));
        };
        "compression" = mkOption {
          description = "Compress a WAL file before sending it to the object store. Available\noptions are empty string (no compression, default), `gzip`, `bzip2`,\n`lz4`, `snappy`, `xz`, and `zstd`.";
          type = (types.nullOr types.str);
        };
        "encryption" = mkOption {
          description = "Whenever to force the encryption of files (if the bucket is\nnot already configured for that).\nAllowed options are empty string (use the bucket policy, default),\n`AES256` and `aws:kms`";
          type = (types.nullOr types.str);
        };
        "maxParallel" = mkOption {
          description = "Number of WAL files to be either archived in parallel (when the\nPostgreSQL instance is archiving to a backup object store) or\nrestored in parallel (when a PostgreSQL standby is fetching WAL\nfiles from a recovery object store). If not specified, WAL files\nwill be processed one at a time. It accepts a positive integer as a\nvalue - with 1 being the minimum accepted value.";
          type = (types.nullOr types.int);
        };
        "restoreAdditionalCommandArgs" = mkOption {
          description = "Additional arguments that can be appended to the 'barman-cloud-wal-restore'\ncommand-line invocation. These arguments provide flexibility to customize\nthe WAL restore process further, according to specific requirements or configurations.\n\nExample:\nIn a scenario where specialized backup options are required, such as setting\na specific timeout or defining custom behavior, users can use this field\nto specify additional command arguments.\n\nNote:\nIt's essential to ensure that the provided arguments are valid and supported\nby the 'barman-cloud-wal-restore' command, to avoid potential errors or unintended\nbehavior during execution.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "archiveAdditionalCommandArgs" = mkOverride 1002 null;
        "compression" = mkOverride 1002 null;
        "encryption" = mkOverride 1002 null;
        "maxParallel" = mkOverride 1002 null;
        "restoreAdditionalCommandArgs" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersPassword" = {

      options = {
        "key" = mkOption {
          description = "The key of the secret to select from.  Must be a valid secret key.";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "Specify whether the Secret or its key must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersPlugin" = {

      options = {
        "enabled" = mkOption {
          description = "Enabled is true if this plugin will be used";
          type = (types.nullOr types.bool);
        };
        "isWALArchiver" = mkOption {
          description = "Marks the plugin as the WAL archiver. At most one plugin can be\ndesignated as a WAL archiver. This cannot be enabled if the\n`.spec.backup.barmanObjectStore` configuration is present.";
          type = (types.nullOr types.bool);
        };
        "name" = mkOption {
          description = "Name is the plugin name";
          type = types.str;
        };
        "parameters" = mkOption {
          description = "Parameters is the configuration of the plugin";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "enabled" = mkOverride 1002 null;
        "isWALArchiver" = mkOverride 1002 null;
        "parameters" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersSslCert" = {

      options = {
        "key" = mkOption {
          description = "The key of the secret to select from.  Must be a valid secret key.";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "Specify whether the Secret or its key must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersSslKey" = {

      options = {
        "key" = mkOption {
          description = "The key of the secret to select from.  Must be a valid secret key.";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "Specify whether the Secret or its key must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecExternalClustersSslRootCert" = {

      options = {
        "key" = mkOption {
          description = "The key of the secret to select from.  Must be a valid secret key.";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "Specify whether the Secret or its key must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecImageCatalogRef" = {

      options = {
        "apiGroup" = mkOption {
          description = "APIGroup is the group for the resource being referenced.\nIf APIGroup is not specified, the specified Kind must be in the core API group.\nFor any other third-party types, APIGroup is required.";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "Kind is the type of resource being referenced";
          type = types.str;
        };
        "major" = mkOption {
          description = "The major version of PostgreSQL we want to use from the ImageCatalog";
          type = types.int;
        };
        "name" = mkOption {
          description = "Name is the name of resource being referenced";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecImagePullSecrets" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecInheritedMetadata" = {

      options = {
        "annotations" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "labels" = mkOption {
          description = "";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecManaged" = {

      options = {
        "roles" = mkOption {
          description = "Database roles managed by the `Cluster`";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.ClusterSpecManagedRoles" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "services" = mkOption {
          description = "Services roles managed by the `Cluster`";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecManagedServices"));
        };
      };

      config = {
        "roles" = mkOverride 1002 null;
        "services" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecManagedRoles" = {

      options = {
        "bypassrls" = mkOption {
          description = "Whether a role bypasses every row-level security (RLS) policy.\nDefault is `false`.";
          type = (types.nullOr types.bool);
        };
        "comment" = mkOption {
          description = "Description of the role";
          type = (types.nullOr types.str);
        };
        "connectionLimit" = mkOption {
          description = "If the role can log in, this specifies how many concurrent\nconnections the role can make. `-1` (the default) means no limit.";
          type = (types.nullOr types.int);
        };
        "createdb" = mkOption {
          description = "When set to `true`, the role being defined will be allowed to create\nnew databases. Specifying `false` (default) will deny a role the\nability to create databases.";
          type = (types.nullOr types.bool);
        };
        "createrole" = mkOption {
          description = "Whether the role will be permitted to create, alter, drop, comment\non, change the security label for, and grant or revoke membership in\nother roles. Default is `false`.";
          type = (types.nullOr types.bool);
        };
        "disablePassword" = mkOption {
          description = "DisablePassword indicates that a role's password should be set to NULL in Postgres";
          type = (types.nullOr types.bool);
        };
        "ensure" = mkOption {
          description = "Ensure the role is `present` or `absent` - defaults to \"present\"";
          type = (types.nullOr types.str);
        };
        "inRoles" = mkOption {
          description = "List of one or more existing roles to which this role will be\nimmediately added as a new member. Default empty.";
          type = (types.nullOr (types.listOf types.str));
        };
        "inherit" = mkOption {
          description = "Whether a role \"inherits\" the privileges of roles it is a member of.\nDefaults is `true`.";
          type = (types.nullOr types.bool);
        };
        "login" = mkOption {
          description = "Whether the role is allowed to log in. A role having the `login`\nattribute can be thought of as a user. Roles without this attribute\nare useful for managing database privileges, but are not users in\nthe usual sense of the word. Default is `false`.";
          type = (types.nullOr types.bool);
        };
        "name" = mkOption {
          description = "Name of the role";
          type = types.str;
        };
        "passwordSecret" = mkOption {
          description = "Secret containing the password of the role (if present)\nIf null, the password will be ignored unless DisablePassword is set";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecManagedRolesPasswordSecret"));
        };
        "replication" = mkOption {
          description = "Whether a role is a replication role. A role must have this\nattribute (or be a superuser) in order to be able to connect to the\nserver in replication mode (physical or logical replication) and in\norder to be able to create or drop replication slots. A role having\nthe `replication` attribute is a very highly privileged role, and\nshould only be used on roles actually used for replication. Default\nis `false`.";
          type = (types.nullOr types.bool);
        };
        "superuser" = mkOption {
          description = "Whether the role is a `superuser` who can override all access\nrestrictions within the database - superuser status is dangerous and\nshould be used only when really needed. You must yourself be a\nsuperuser to create a new superuser. Defaults is `false`.";
          type = (types.nullOr types.bool);
        };
        "validUntil" = mkOption {
          description = "Date and time after which the role's password is no longer valid.\nWhen omitted, the password will never expire (default).";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "bypassrls" = mkOverride 1002 null;
        "comment" = mkOverride 1002 null;
        "connectionLimit" = mkOverride 1002 null;
        "createdb" = mkOverride 1002 null;
        "createrole" = mkOverride 1002 null;
        "disablePassword" = mkOverride 1002 null;
        "ensure" = mkOverride 1002 null;
        "inRoles" = mkOverride 1002 null;
        "inherit" = mkOverride 1002 null;
        "login" = mkOverride 1002 null;
        "passwordSecret" = mkOverride 1002 null;
        "replication" = mkOverride 1002 null;
        "superuser" = mkOverride 1002 null;
        "validUntil" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecManagedRolesPasswordSecret" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecManagedServices" = {

      options = {
        "additional" = mkOption {
          description = "Additional is a list of additional managed services specified by the user.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecManagedServicesAdditional")
            )
          );
        };
        "disabledDefaultServices" = mkOption {
          description = "DisabledDefaultServices is a list of service types that are disabled by default.\nValid values are \"r\", and \"ro\", representing read, and read-only services.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "additional" = mkOverride 1002 null;
        "disabledDefaultServices" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecManagedServicesAdditional" = {

      options = {
        "selectorType" = mkOption {
          description = "SelectorType specifies the type of selectors that the service will have.\nValid values are \"rw\", \"r\", and \"ro\", representing read-write, read, and read-only services.";
          type = types.str;
        };
        "serviceTemplate" = mkOption {
          description = "ServiceTemplate is the template specification for the service.";
          type = (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecManagedServicesAdditionalServiceTemplate");
        };
        "updateStrategy" = mkOption {
          description = "UpdateStrategy describes how the service differences should be reconciled";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "updateStrategy" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecManagedServicesAdditionalServiceTemplate" = {

      options = {
        "metadata" = mkOption {
          description = "Standard object's metadata.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecManagedServicesAdditionalServiceTemplateMetadata"
            )
          );
        };
        "spec" = mkOption {
          description = "Specification of the desired behavior of the service.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecManagedServicesAdditionalServiceTemplateSpec"
            )
          );
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecManagedServicesAdditionalServiceTemplateMetadata" = {

      options = {
        "annotations" = mkOption {
          description = "Annotations is an unstructured key value map stored with a resource that may be\nset by external tools to store and retrieve arbitrary metadata. They are not\nqueryable and should be preserved when modifying objects.\nMore info: http://kubernetes.io/docs/user-guide/annotations";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "labels" = mkOption {
          description = "Map of string keys and values that can be used to organize and categorize\n(scope and select) objects. May match selectors of replication controllers\nand services.\nMore info: http://kubernetes.io/docs/user-guide/labels";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "name" = mkOption {
          description = "The name of the resource. Only supported for certain types";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecManagedServicesAdditionalServiceTemplateSpec" = {

      options = {
        "allocateLoadBalancerNodePorts" = mkOption {
          description = "allocateLoadBalancerNodePorts defines if NodePorts will be automatically\nallocated for services with type LoadBalancer.  Default is \"true\". It\nmay be set to \"false\" if the cluster load-balancer does not rely on\nNodePorts.  If the caller requests specific NodePorts (by specifying a\nvalue), those requests will be respected, regardless of this field.\nThis field may only be set for services with type LoadBalancer and will\nbe cleared if the type is changed to any other type.";
          type = (types.nullOr types.bool);
        };
        "clusterIP" = mkOption {
          description = "clusterIP is the IP address of the service and is usually assigned\nrandomly. If an address is specified manually, is in-range (as per\nsystem configuration), and is not in use, it will be allocated to the\nservice; otherwise creation of the service will fail. This field may not\nbe changed through updates unless the type field is also being changed\nto ExternalName (which requires this field to be blank) or the type\nfield is being changed from ExternalName (in which case this field may\noptionally be specified, as describe above).  Valid values are \"None\",\nempty string (\"\"), or a valid IP address. Setting this to \"None\" makes a\n\"headless service\" (no virtual IP), which is useful when direct endpoint\nconnections are preferred and proxying is not required.  Only applies to\ntypes ClusterIP, NodePort, and LoadBalancer. If this field is specified\nwhen creating a Service of type ExternalName, creation will fail. This\nfield will be wiped when updating a Service to type ExternalName.\nMore info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies";
          type = (types.nullOr types.str);
        };
        "clusterIPs" = mkOption {
          description = "ClusterIPs is a list of IP addresses assigned to this service, and are\nusually assigned randomly.  If an address is specified manually, is\nin-range (as per system configuration), and is not in use, it will be\nallocated to the service; otherwise creation of the service will fail.\nThis field may not be changed through updates unless the type field is\nalso being changed to ExternalName (which requires this field to be\nempty) or the type field is being changed from ExternalName (in which\ncase this field may optionally be specified, as describe above).  Valid\nvalues are \"None\", empty string (\"\"), or a valid IP address.  Setting\nthis to \"None\" makes a \"headless service\" (no virtual IP), which is\nuseful when direct endpoint connections are preferred and proxying is\nnot required.  Only applies to types ClusterIP, NodePort, and\nLoadBalancer. If this field is specified when creating a Service of type\nExternalName, creation will fail. This field will be wiped when updating\na Service to type ExternalName.  If this field is not specified, it will\nbe initialized from the clusterIP field.  If this field is specified,\nclients must ensure that clusterIPs[0] and clusterIP have the same\nvalue.\n\nThis field may hold a maximum of two entries (dual-stack IPs, in either order).\nThese IPs must correspond to the values of the ipFamilies field. Both\nclusterIPs and ipFamilies are governed by the ipFamilyPolicy field.\nMore info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies";
          type = (types.nullOr (types.listOf types.str));
        };
        "externalIPs" = mkOption {
          description = "externalIPs is a list of IP addresses for which nodes in the cluster\nwill also accept traffic for this service.  These IPs are not managed by\nKubernetes.  The user is responsible for ensuring that traffic arrives\nat a node with this IP.  A common example is external load-balancers\nthat are not part of the Kubernetes system.";
          type = (types.nullOr (types.listOf types.str));
        };
        "externalName" = mkOption {
          description = "externalName is the external reference that discovery mechanisms will\nreturn as an alias for this service (e.g. a DNS CNAME record). No\nproxying will be involved.  Must be a lowercase RFC-1123 hostname\n(https://tools.ietf.org/html/rfc1123) and requires `type` to be \"ExternalName\".";
          type = (types.nullOr types.str);
        };
        "externalTrafficPolicy" = mkOption {
          description = "externalTrafficPolicy describes how nodes distribute service traffic they\nreceive on one of the Service's \"externally-facing\" addresses (NodePorts,\nExternalIPs, and LoadBalancer IPs). If set to \"Local\", the proxy will configure\nthe service in a way that assumes that external load balancers will take care\nof balancing the service traffic between nodes, and so each node will deliver\ntraffic only to the node-local endpoints of the service, without masquerading\nthe client source IP. (Traffic mistakenly sent to a node with no endpoints will\nbe dropped.) The default value, \"Cluster\", uses the standard behavior of\nrouting to all endpoints evenly (possibly modified by topology and other\nfeatures). Note that traffic sent to an External IP or LoadBalancer IP from\nwithin the cluster will always get \"Cluster\" semantics, but clients sending to\na NodePort from within the cluster may need to take traffic policy into account\nwhen picking a node.";
          type = (types.nullOr types.str);
        };
        "healthCheckNodePort" = mkOption {
          description = "healthCheckNodePort specifies the healthcheck nodePort for the service.\nThis only applies when type is set to LoadBalancer and\nexternalTrafficPolicy is set to Local. If a value is specified, is\nin-range, and is not in use, it will be used.  If not specified, a value\nwill be automatically allocated.  External systems (e.g. load-balancers)\ncan use this port to determine if a given node holds endpoints for this\nservice or not.  If this field is specified when creating a Service\nwhich does not need it, creation will fail. This field will be wiped\nwhen updating a Service to no longer need it (e.g. changing type).\nThis field cannot be updated once set.";
          type = (types.nullOr types.int);
        };
        "internalTrafficPolicy" = mkOption {
          description = "InternalTrafficPolicy describes how nodes distribute service traffic they\nreceive on the ClusterIP. If set to \"Local\", the proxy will assume that pods\nonly want to talk to endpoints of the service on the same node as the pod,\ndropping the traffic if there are no local endpoints. The default value,\n\"Cluster\", uses the standard behavior of routing to all endpoints evenly\n(possibly modified by topology and other features).";
          type = (types.nullOr types.str);
        };
        "ipFamilies" = mkOption {
          description = "IPFamilies is a list of IP families (e.g. IPv4, IPv6) assigned to this\nservice. This field is usually assigned automatically based on cluster\nconfiguration and the ipFamilyPolicy field. If this field is specified\nmanually, the requested family is available in the cluster,\nand ipFamilyPolicy allows it, it will be used; otherwise creation of\nthe service will fail. This field is conditionally mutable: it allows\nfor adding or removing a secondary IP family, but it does not allow\nchanging the primary IP family of the Service. Valid values are \"IPv4\"\nand \"IPv6\".  This field only applies to Services of types ClusterIP,\nNodePort, and LoadBalancer, and does apply to \"headless\" services.\nThis field will be wiped when updating a Service to type ExternalName.\n\nThis field may hold a maximum of two entries (dual-stack families, in\neither order).  These families must correspond to the values of the\nclusterIPs field, if specified. Both clusterIPs and ipFamilies are\ngoverned by the ipFamilyPolicy field.";
          type = (types.nullOr (types.listOf types.str));
        };
        "ipFamilyPolicy" = mkOption {
          description = "IPFamilyPolicy represents the dual-stack-ness requested or required by\nthis Service. If there is no value provided, then this field will be set\nto SingleStack. Services can be \"SingleStack\" (a single IP family),\n\"PreferDualStack\" (two IP families on dual-stack configured clusters or\na single IP family on single-stack clusters), or \"RequireDualStack\"\n(two IP families on dual-stack configured clusters, otherwise fail). The\nipFamilies and clusterIPs fields depend on the value of this field. This\nfield will be wiped when updating a service to type ExternalName.";
          type = (types.nullOr types.str);
        };
        "loadBalancerClass" = mkOption {
          description = "loadBalancerClass is the class of the load balancer implementation this Service belongs to.\nIf specified, the value of this field must be a label-style identifier, with an optional prefix,\ne.g. \"internal-vip\" or \"example.com/internal-vip\". Unprefixed names are reserved for end-users.\nThis field can only be set when the Service type is 'LoadBalancer'. If not set, the default load\nbalancer implementation is used, today this is typically done through the cloud provider integration,\nbut should apply for any default implementation. If set, it is assumed that a load balancer\nimplementation is watching for Services with a matching class. Any default load balancer\nimplementation (e.g. cloud providers) should ignore Services that set this field.\nThis field can only be set when creating or updating a Service to type 'LoadBalancer'.\nOnce set, it can not be changed. This field will be wiped when a service is updated to a non 'LoadBalancer' type.";
          type = (types.nullOr types.str);
        };
        "loadBalancerIP" = mkOption {
          description = "Only applies to Service Type: LoadBalancer.\nThis feature depends on whether the underlying cloud-provider supports specifying\nthe loadBalancerIP when a load balancer is created.\nThis field will be ignored if the cloud-provider does not support the feature.\nDeprecated: This field was under-specified and its meaning varies across implementations.\nUsing it is non-portable and it may not support dual-stack.\nUsers are encouraged to use implementation-specific annotations when available.";
          type = (types.nullOr types.str);
        };
        "loadBalancerSourceRanges" = mkOption {
          description = "If specified and supported by the platform, this will restrict traffic through the cloud-provider\nload-balancer will be restricted to the specified client IPs. This field will be ignored if the\ncloud-provider does not support the feature.\"\nMore info: https://kubernetes.io/docs/tasks/access-application-cluster/create-external-load-balancer/";
          type = (types.nullOr (types.listOf types.str));
        };
        "ports" = mkOption {
          description = "The list of ports that are exposed by this service.\nMore info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.ClusterSpecManagedServicesAdditionalServiceTemplateSpecPorts"
                "name"
                [
                  "port"
                  "protocol"
                ]
            )
          );
          apply = attrsToList;
        };
        "publishNotReadyAddresses" = mkOption {
          description = "publishNotReadyAddresses indicates that any agent which deals with endpoints for this\nService should disregard any indications of ready/not-ready.\nThe primary use case for setting this field is for a StatefulSet's Headless Service to\npropagate SRV DNS records for its Pods for the purpose of peer discovery.\nThe Kubernetes controllers that generate Endpoints and EndpointSlice resources for\nServices interpret this to mean that all endpoints are considered \"ready\" even if the\nPods themselves are not. Agents which consume only Kubernetes generated endpoints\nthrough the Endpoints or EndpointSlice resources can safely assume this behavior.";
          type = (types.nullOr types.bool);
        };
        "selector" = mkOption {
          description = "Route service traffic to pods with label keys and values matching this\nselector. If empty or not present, the service is assumed to have an\nexternal process managing its endpoints, which Kubernetes will not\nmodify. Only applies to types ClusterIP, NodePort, and LoadBalancer.\nIgnored if type is ExternalName.\nMore info: https://kubernetes.io/docs/concepts/services-networking/service/";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "sessionAffinity" = mkOption {
          description = "Supports \"ClientIP\" and \"None\". Used to maintain session affinity.\nEnable client IP based session affinity.\nMust be ClientIP or None.\nDefaults to None.\nMore info: https://kubernetes.io/docs/concepts/services-networking/service/#virtual-ips-and-service-proxies";
          type = (types.nullOr types.str);
        };
        "sessionAffinityConfig" = mkOption {
          description = "sessionAffinityConfig contains the configurations of session affinity.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecManagedServicesAdditionalServiceTemplateSpecSessionAffinityConfig"
            )
          );
        };
        "trafficDistribution" = mkOption {
          description = "TrafficDistribution offers a way to express preferences for how traffic\nis distributed to Service endpoints. Implementations can use this field\nas a hint, but are not required to guarantee strict adherence. If the\nfield is not set, the implementation will apply its default routing\nstrategy. If set to \"PreferClose\", implementations should prioritize\nendpoints that are in the same zone.";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "type determines how the Service is exposed. Defaults to ClusterIP. Valid\noptions are ExternalName, ClusterIP, NodePort, and LoadBalancer.\n\"ClusterIP\" allocates a cluster-internal IP address for load-balancing\nto endpoints. Endpoints are determined by the selector or if that is not\nspecified, by manual construction of an Endpoints object or\nEndpointSlice objects. If clusterIP is \"None\", no virtual IP is\nallocated and the endpoints are published as a set of endpoints rather\nthan a virtual IP.\n\"NodePort\" builds on ClusterIP and allocates a port on every node which\nroutes to the same endpoints as the clusterIP.\n\"LoadBalancer\" builds on NodePort and creates an external load-balancer\n(if supported in the current cloud) which routes to the same endpoints\nas the clusterIP.\n\"ExternalName\" aliases this service to the specified externalName.\nSeveral other fields do not apply to ExternalName services.\nMore info: https://kubernetes.io/docs/concepts/services-networking/service/#publishing-services-service-types";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "allocateLoadBalancerNodePorts" = mkOverride 1002 null;
        "clusterIP" = mkOverride 1002 null;
        "clusterIPs" = mkOverride 1002 null;
        "externalIPs" = mkOverride 1002 null;
        "externalName" = mkOverride 1002 null;
        "externalTrafficPolicy" = mkOverride 1002 null;
        "healthCheckNodePort" = mkOverride 1002 null;
        "internalTrafficPolicy" = mkOverride 1002 null;
        "ipFamilies" = mkOverride 1002 null;
        "ipFamilyPolicy" = mkOverride 1002 null;
        "loadBalancerClass" = mkOverride 1002 null;
        "loadBalancerIP" = mkOverride 1002 null;
        "loadBalancerSourceRanges" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
        "publishNotReadyAddresses" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "sessionAffinity" = mkOverride 1002 null;
        "sessionAffinityConfig" = mkOverride 1002 null;
        "trafficDistribution" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecManagedServicesAdditionalServiceTemplateSpecPorts" = {

      options = {
        "appProtocol" = mkOption {
          description = "The application protocol for this port.\nThis is used as a hint for implementations to offer richer behavior for protocols that they understand.\nThis field follows standard Kubernetes label syntax.\nValid values are either:\n\n* Un-prefixed protocol names - reserved for IANA standard service names (as per\nRFC-6335 and https://www.iana.org/assignments/service-names).\n\n* Kubernetes-defined prefixed names:\n  * 'kubernetes.io/h2c' - HTTP/2 prior knowledge over cleartext as described in https://www.rfc-editor.org/rfc/rfc9113.html#name-starting-http-2-with-prior-\n  * 'kubernetes.io/ws'  - WebSocket over cleartext as described in https://www.rfc-editor.org/rfc/rfc6455\n  * 'kubernetes.io/wss' - WebSocket over TLS as described in https://www.rfc-editor.org/rfc/rfc6455\n\n* Other protocols should use implementation-defined prefixed names such as\nmycompany.com/my-custom-protocol.";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "The name of this port within the service. This must be a DNS_LABEL.\nAll ports within a ServiceSpec must have unique names. When considering\nthe endpoints for a Service, this must match the 'name' field in the\nEndpointPort.\nOptional if only one ServicePort is defined on this service.";
          type = (types.nullOr types.str);
        };
        "nodePort" = mkOption {
          description = "The port on each node on which this service is exposed when type is\nNodePort or LoadBalancer.  Usually assigned by the system. If a value is\nspecified, in-range, and not in use it will be used, otherwise the\noperation will fail.  If not specified, a port will be allocated if this\nService requires one.  If this field is specified when creating a\nService which does not need it, creation will fail. This field will be\nwiped when updating a Service to no longer need it (e.g. changing type\nfrom NodePort to ClusterIP).\nMore info: https://kubernetes.io/docs/concepts/services-networking/service/#type-nodeport";
          type = (types.nullOr types.int);
        };
        "port" = mkOption {
          description = "The port that will be exposed by this service.";
          type = types.int;
        };
        "protocol" = mkOption {
          description = "The IP protocol for this port. Supports \"TCP\", \"UDP\", and \"SCTP\".\nDefault is TCP.";
          type = (types.nullOr types.str);
        };
        "targetPort" = mkOption {
          description = "Number or name of the port to access on the pods targeted by the service.\nNumber must be in the range 1 to 65535. Name must be an IANA_SVC_NAME.\nIf this is a string, it will be looked up as a named port in the\ntarget Pod's container ports. If this is not specified, the value\nof the 'port' field is used (an identity map).\nThis field is ignored for services with clusterIP=None, and should be\nomitted or set equal to the 'port' field.\nMore info: https://kubernetes.io/docs/concepts/services-networking/service/#defining-a-service";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "appProtocol" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "nodePort" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
        "targetPort" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecManagedServicesAdditionalServiceTemplateSpecSessionAffinityConfig" =
      {

        options = {
          "clientIP" = mkOption {
            description = "clientIP contains the configurations of Client IP based session affinity.";
            type = (
              types.nullOr (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecManagedServicesAdditionalServiceTemplateSpecSessionAffinityConfigClientIP"
              )
            );
          };
        };

        config = {
          "clientIP" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecManagedServicesAdditionalServiceTemplateSpecSessionAffinityConfigClientIP" =
      {

        options = {
          "timeoutSeconds" = mkOption {
            description = "timeoutSeconds specifies the seconds of ClientIP type session sticky time.\nThe value must be >0 && <=86400(for 1 day) if ServiceAffinity == \"ClientIP\".\nDefault value is 10800(for 3 hours).";
            type = (types.nullOr types.int);
          };
        };

        config = {
          "timeoutSeconds" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecMonitoring" = {

      options = {
        "customQueriesConfigMap" = mkOption {
          description = "The list of config maps containing the custom queries";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.ClusterSpecMonitoringCustomQueriesConfigMap"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "customQueriesSecret" = mkOption {
          description = "The list of secrets containing the custom queries";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.ClusterSpecMonitoringCustomQueriesSecret"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "disableDefaultQueries" = mkOption {
          description = "Whether the default queries should be injected.\nSet it to `true` if you don't want to inject default queries into the cluster.\nDefault: false.";
          type = (types.nullOr types.bool);
        };
        "enablePodMonitor" = mkOption {
          description = "Enable or disable the `PodMonitor`\n\nDeprecated: This feature will be removed in an upcoming release. If\nyou need this functionality, you can create a PodMonitor manually.";
          type = (types.nullOr types.bool);
        };
        "metricsQueriesTTL" = mkOption {
          description = "The interval during which metrics computed from queries are considered current.\nOnce it is exceeded, a new scrape will trigger a rerun\nof the queries.\nIf not set, defaults to 30 seconds, in line with Prometheus scraping defaults.\nSetting this to zero disables the caching mechanism and can cause heavy load on the PostgreSQL server.";
          type = (types.nullOr types.str);
        };
        "podMonitorMetricRelabelings" = mkOption {
          description = "The list of metric relabelings for the `PodMonitor`. Applied to samples before ingestion.\n\nDeprecated: This feature will be removed in an upcoming release. If\nyou need this functionality, you can create a PodMonitor manually.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecMonitoringPodMonitorMetricRelabelings")
            )
          );
        };
        "podMonitorRelabelings" = mkOption {
          description = "The list of relabelings for the `PodMonitor`. Applied to samples before scraping.\n\nDeprecated: This feature will be removed in an upcoming release. If\nyou need this functionality, you can create a PodMonitor manually.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecMonitoringPodMonitorRelabelings")
            )
          );
        };
        "tls" = mkOption {
          description = "Configure TLS communication for the metrics endpoint.\nChanging tls.enabled option will force a rollout of all instances.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecMonitoringTls"));
        };
      };

      config = {
        "customQueriesConfigMap" = mkOverride 1002 null;
        "customQueriesSecret" = mkOverride 1002 null;
        "disableDefaultQueries" = mkOverride 1002 null;
        "enablePodMonitor" = mkOverride 1002 null;
        "metricsQueriesTTL" = mkOverride 1002 null;
        "podMonitorMetricRelabelings" = mkOverride 1002 null;
        "podMonitorRelabelings" = mkOverride 1002 null;
        "tls" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecMonitoringCustomQueriesConfigMap" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecMonitoringCustomQueriesSecret" = {

      options = {
        "key" = mkOption {
          description = "The key to select";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecMonitoringPodMonitorMetricRelabelings" = {

      options = {
        "action" = mkOption {
          description = "action to perform based on the regex matching.\n\n`Uppercase` and `Lowercase` actions require Prometheus >= v2.36.0.\n`DropEqual` and `KeepEqual` actions require Prometheus >= v2.41.0.\n\nDefault: \"Replace\"";
          type = (types.nullOr types.str);
        };
        "modulus" = mkOption {
          description = "modulus to take of the hash of the source label values.\n\nOnly applicable when the action is `HashMod`.";
          type = (types.nullOr types.int);
        };
        "regex" = mkOption {
          description = "regex defines the regular expression against which the extracted value is matched.";
          type = (types.nullOr types.str);
        };
        "replacement" = mkOption {
          description = "replacement value against which a Replace action is performed if the\nregular expression matches.\n\nRegex capture groups are available.";
          type = (types.nullOr types.str);
        };
        "separator" = mkOption {
          description = "separator defines the string between concatenated SourceLabels.";
          type = (types.nullOr types.str);
        };
        "sourceLabels" = mkOption {
          description = "sourceLabels defines the source labels select values from existing labels. Their content is\nconcatenated using the configured Separator and matched against the\nconfigured regular expression.";
          type = (types.nullOr (types.listOf types.str));
        };
        "targetLabel" = mkOption {
          description = "targetLabel defines the label to which the resulting string is written in a replacement.\n\nIt is mandatory for `Replace`, `HashMod`, `Lowercase`, `Uppercase`,\n`KeepEqual` and `DropEqual` actions.\n\nRegex capture groups are available.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "action" = mkOverride 1002 null;
        "modulus" = mkOverride 1002 null;
        "regex" = mkOverride 1002 null;
        "replacement" = mkOverride 1002 null;
        "separator" = mkOverride 1002 null;
        "sourceLabels" = mkOverride 1002 null;
        "targetLabel" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecMonitoringPodMonitorRelabelings" = {

      options = {
        "action" = mkOption {
          description = "action to perform based on the regex matching.\n\n`Uppercase` and `Lowercase` actions require Prometheus >= v2.36.0.\n`DropEqual` and `KeepEqual` actions require Prometheus >= v2.41.0.\n\nDefault: \"Replace\"";
          type = (types.nullOr types.str);
        };
        "modulus" = mkOption {
          description = "modulus to take of the hash of the source label values.\n\nOnly applicable when the action is `HashMod`.";
          type = (types.nullOr types.int);
        };
        "regex" = mkOption {
          description = "regex defines the regular expression against which the extracted value is matched.";
          type = (types.nullOr types.str);
        };
        "replacement" = mkOption {
          description = "replacement value against which a Replace action is performed if the\nregular expression matches.\n\nRegex capture groups are available.";
          type = (types.nullOr types.str);
        };
        "separator" = mkOption {
          description = "separator defines the string between concatenated SourceLabels.";
          type = (types.nullOr types.str);
        };
        "sourceLabels" = mkOption {
          description = "sourceLabels defines the source labels select values from existing labels. Their content is\nconcatenated using the configured Separator and matched against the\nconfigured regular expression.";
          type = (types.nullOr (types.listOf types.str));
        };
        "targetLabel" = mkOption {
          description = "targetLabel defines the label to which the resulting string is written in a replacement.\n\nIt is mandatory for `Replace`, `HashMod`, `Lowercase`, `Uppercase`,\n`KeepEqual` and `DropEqual` actions.\n\nRegex capture groups are available.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "action" = mkOverride 1002 null;
        "modulus" = mkOverride 1002 null;
        "regex" = mkOverride 1002 null;
        "replacement" = mkOverride 1002 null;
        "separator" = mkOverride 1002 null;
        "sourceLabels" = mkOverride 1002 null;
        "targetLabel" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecMonitoringTls" = {

      options = {
        "enabled" = mkOption {
          description = "Enable TLS for the monitoring endpoint.\nChanging this option will force a rollout of all instances.";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "enabled" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecNodeMaintenanceWindow" = {

      options = {
        "inProgress" = mkOption {
          description = "Is there a node maintenance activity in progress?";
          type = (types.nullOr types.bool);
        };
        "reusePVC" = mkOption {
          description = "Reuse the existing PVC (wait for the node to come\nup again) or not (recreate it elsewhere - when `instances` >1)";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "inProgress" = mkOverride 1002 null;
        "reusePVC" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecPlugins" = {

      options = {
        "enabled" = mkOption {
          description = "Enabled is true if this plugin will be used";
          type = (types.nullOr types.bool);
        };
        "isWALArchiver" = mkOption {
          description = "Marks the plugin as the WAL archiver. At most one plugin can be\ndesignated as a WAL archiver. This cannot be enabled if the\n`.spec.backup.barmanObjectStore` configuration is present.";
          type = (types.nullOr types.bool);
        };
        "name" = mkOption {
          description = "Name is the plugin name";
          type = types.str;
        };
        "parameters" = mkOption {
          description = "Parameters is the configuration of the plugin";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "enabled" = mkOverride 1002 null;
        "isWALArchiver" = mkOverride 1002 null;
        "parameters" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecPodSecurityContext" = {

      options = {
        "appArmorProfile" = mkOption {
          description = "appArmorProfile is the AppArmor options to use by the containers in this pod.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecPodSecurityContextAppArmorProfile")
          );
        };
        "fsGroup" = mkOption {
          description = "A special supplemental group that applies to all containers in a pod.\nSome volume types allow the Kubelet to change the ownership of that volume\nto be owned by the pod:\n\n1. The owning GID will be the FSGroup\n2. The setgid bit is set (new files created in the volume will be owned by FSGroup)\n3. The permission bits are OR'd with rw-rw----\n\nIf unset, the Kubelet will not modify the ownership and permissions of any volume.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr types.int);
        };
        "fsGroupChangePolicy" = mkOption {
          description = "fsGroupChangePolicy defines behavior of changing ownership and permission of the volume\nbefore being exposed inside Pod. This field will only apply to\nvolume types which support fsGroup based ownership(and permissions).\nIt will have no effect on ephemeral volume types such as: secret, configmaps\nand emptydir.\nValid values are \"OnRootMismatch\" and \"Always\". If not specified, \"Always\" is used.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr types.str);
        };
        "runAsGroup" = mkOption {
          description = "The GID to run the entrypoint of the container process.\nUses runtime default if unset.\nMay also be set in SecurityContext.  If set in both SecurityContext and\nPodSecurityContext, the value specified in SecurityContext takes precedence\nfor that container.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr types.int);
        };
        "runAsNonRoot" = mkOption {
          description = "Indicates that the container must run as a non-root user.\nIf true, the Kubelet will validate the image at runtime to ensure that it\ndoes not run as UID 0 (root) and fail to start the container if it does.\nIf unset or false, no such validation will be performed.\nMay also be set in SecurityContext.  If set in both SecurityContext and\nPodSecurityContext, the value specified in SecurityContext takes precedence.";
          type = (types.nullOr types.bool);
        };
        "runAsUser" = mkOption {
          description = "The UID to run the entrypoint of the container process.\nDefaults to user specified in image metadata if unspecified.\nMay also be set in SecurityContext.  If set in both SecurityContext and\nPodSecurityContext, the value specified in SecurityContext takes precedence\nfor that container.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr types.int);
        };
        "seLinuxChangePolicy" = mkOption {
          description = "seLinuxChangePolicy defines how the container's SELinux label is applied to all volumes used by the Pod.\nIt has no effect on nodes that do not support SELinux or to volumes does not support SELinux.\nValid values are \"MountOption\" and \"Recursive\".\n\n\"Recursive\" means relabeling of all files on all Pod volumes by the container runtime.\nThis may be slow for large volumes, but allows mixing privileged and unprivileged Pods sharing the same volume on the same node.\n\n\"MountOption\" mounts all eligible Pod volumes with `-o context` mount option.\nThis requires all Pods that share the same volume to use the same SELinux label.\nIt is not possible to share the same volume among privileged and unprivileged Pods.\nEligible volumes are in-tree FibreChannel and iSCSI volumes, and all CSI volumes\nwhose CSI driver announces SELinux support by setting spec.seLinuxMount: true in their\nCSIDriver instance. Other volumes are always re-labelled recursively.\n\"MountOption\" value is allowed only when SELinuxMount feature gate is enabled.\n\nIf not specified and SELinuxMount feature gate is enabled, \"MountOption\" is used.\nIf not specified and SELinuxMount feature gate is disabled, \"MountOption\" is used for ReadWriteOncePod volumes\nand \"Recursive\" for all other volumes.\n\nThis field affects only Pods that have SELinux label set, either in PodSecurityContext or in SecurityContext of all containers.\n\nAll Pods that use the same volume should use the same seLinuxChangePolicy, otherwise some pods can get stuck in ContainerCreating state.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr types.str);
        };
        "seLinuxOptions" = mkOption {
          description = "The SELinux context to be applied to all containers.\nIf unspecified, the container runtime will allocate a random SELinux context for each\ncontainer.  May also be set in SecurityContext.  If set in\nboth SecurityContext and PodSecurityContext, the value specified in SecurityContext\ntakes precedence for that container.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecPodSecurityContextSeLinuxOptions")
          );
        };
        "seccompProfile" = mkOption {
          description = "The seccomp options to use by the containers in this pod.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecPodSecurityContextSeccompProfile")
          );
        };
        "supplementalGroups" = mkOption {
          description = "A list of groups applied to the first process run in each container, in\naddition to the container's primary GID and fsGroup (if specified).  If\nthe SupplementalGroupsPolicy feature is enabled, the\nsupplementalGroupsPolicy field determines whether these are in addition\nto or instead of any group memberships defined in the container image.\nIf unspecified, no additional groups are added, though group memberships\ndefined in the container image may still be used, depending on the\nsupplementalGroupsPolicy field.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr (types.listOf types.int));
        };
        "supplementalGroupsPolicy" = mkOption {
          description = "Defines how supplemental groups of the first container processes are calculated.\nValid values are \"Merge\" and \"Strict\". If not specified, \"Merge\" is used.\n(Alpha) Using the field requires the SupplementalGroupsPolicy feature gate to be enabled\nand the container runtime must implement support for this feature.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr types.str);
        };
        "sysctls" = mkOption {
          description = "Sysctls hold a list of namespaced sysctls used for the pod. Pods with unsupported\nsysctls (by the container runtime) might fail to launch.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.ClusterSpecPodSecurityContextSysctls"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "windowsOptions" = mkOption {
          description = "The Windows specific settings applied to all containers.\nIf unspecified, the options within a container's SecurityContext will be used.\nIf set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.\nNote that this field cannot be set when spec.os.name is linux.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecPodSecurityContextWindowsOptions")
          );
        };
      };

      config = {
        "appArmorProfile" = mkOverride 1002 null;
        "fsGroup" = mkOverride 1002 null;
        "fsGroupChangePolicy" = mkOverride 1002 null;
        "runAsGroup" = mkOverride 1002 null;
        "runAsNonRoot" = mkOverride 1002 null;
        "runAsUser" = mkOverride 1002 null;
        "seLinuxChangePolicy" = mkOverride 1002 null;
        "seLinuxOptions" = mkOverride 1002 null;
        "seccompProfile" = mkOverride 1002 null;
        "supplementalGroups" = mkOverride 1002 null;
        "supplementalGroupsPolicy" = mkOverride 1002 null;
        "sysctls" = mkOverride 1002 null;
        "windowsOptions" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecPodSecurityContextAppArmorProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "localhostProfile indicates a profile loaded on the node that should be used.\nThe profile must be preconfigured on the node to work.\nMust match the loaded name of the profile.\nMust be set if and only if type is \"Localhost\".";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "type indicates which kind of AppArmor profile will be applied.\nValid options are:\n  Localhost - a profile pre-loaded on the node.\n  RuntimeDefault - the container runtime's default profile.\n  Unconfined - no AppArmor enforcement.";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecPodSecurityContextSeLinuxOptions" = {

      options = {
        "level" = mkOption {
          description = "Level is SELinux level label that applies to the container.";
          type = (types.nullOr types.str);
        };
        "role" = mkOption {
          description = "Role is a SELinux role label that applies to the container.";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "Type is a SELinux type label that applies to the container.";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "User is a SELinux user label that applies to the container.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "level" = mkOverride 1002 null;
        "role" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecPodSecurityContextSeccompProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "localhostProfile indicates a profile defined in a file on the node should be used.\nThe profile must be preconfigured on the node to work.\nMust be a descending path, relative to the kubelet's configured seccomp profile location.\nMust be set if type is \"Localhost\". Must NOT be set for any other type.";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "type indicates which kind of seccomp profile will be applied.\nValid options are:\n\nLocalhost - a profile defined in a file on the node should be used.\nRuntimeDefault - the container runtime default profile should be used.\nUnconfined - no profile should be applied.";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecPodSecurityContextSysctls" = {

      options = {
        "name" = mkOption {
          description = "Name of a property to set";
          type = types.str;
        };
        "value" = mkOption {
          description = "Value of a property to set";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecPodSecurityContextWindowsOptions" = {

      options = {
        "gmsaCredentialSpec" = mkOption {
          description = "GMSACredentialSpec is where the GMSA admission webhook\n(https://github.com/kubernetes-sigs/windows-gmsa) inlines the contents of the\nGMSA credential spec named by the GMSACredentialSpecName field.";
          type = (types.nullOr types.str);
        };
        "gmsaCredentialSpecName" = mkOption {
          description = "GMSACredentialSpecName is the name of the GMSA credential spec to use.";
          type = (types.nullOr types.str);
        };
        "hostProcess" = mkOption {
          description = "HostProcess determines if a container should be run as a 'Host Process' container.\nAll of a Pod's containers must have the same effective HostProcess value\n(it is not allowed to have a mix of HostProcess containers and non-HostProcess containers).\nIn addition, if HostProcess is true then HostNetwork must also be set to true.";
          type = (types.nullOr types.bool);
        };
        "runAsUserName" = mkOption {
          description = "The UserName in Windows to run the entrypoint of the container process.\nDefaults to the user specified in image metadata if unspecified.\nMay also be set in PodSecurityContext. If set in both SecurityContext and\nPodSecurityContext, the value specified in SecurityContext takes precedence.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "gmsaCredentialSpec" = mkOverride 1002 null;
        "gmsaCredentialSpecName" = mkOverride 1002 null;
        "hostProcess" = mkOverride 1002 null;
        "runAsUserName" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecPostgresql" = {

      options = {
        "enableAlterSystem" = mkOption {
          description = "If this parameter is true, the user will be able to invoke `ALTER SYSTEM`\non this CloudNativePG Cluster.\nThis should only be used for debugging and troubleshooting.\nDefaults to false.";
          type = (types.nullOr types.bool);
        };
        "extensions" = mkOption {
          description = "The configuration of the extensions to be added";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.ClusterSpecPostgresqlExtensions" "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "ldap" = mkOption {
          description = "Options to specify LDAP configuration";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecPostgresqlLdap"));
        };
        "parameters" = mkOption {
          description = "PostgreSQL configuration options (postgresql.conf)";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "pg_hba" = mkOption {
          description = "PostgreSQL Host Based Authentication rules (lines to be appended\nto the pg_hba.conf file)";
          type = (types.nullOr (types.listOf types.str));
        };
        "pg_ident" = mkOption {
          description = "PostgreSQL User Name Maps rules (lines to be appended\nto the pg_ident.conf file)";
          type = (types.nullOr (types.listOf types.str));
        };
        "promotionTimeout" = mkOption {
          description = "Specifies the maximum number of seconds to wait when promoting an instance to primary.\nDefault value is 40000000, greater than one year in seconds,\nbig enough to simulate an infinite timeout";
          type = (types.nullOr types.int);
        };
        "shared_preload_libraries" = mkOption {
          description = "Lists of shared preload libraries to add to the default ones";
          type = (types.nullOr (types.listOf types.str));
        };
        "syncReplicaElectionConstraint" = mkOption {
          description = "Requirements to be met by sync replicas. This will affect how the \"synchronous_standby_names\" parameter will be\nset up.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecPostgresqlSyncReplicaElectionConstraint"
            )
          );
        };
        "synchronous" = mkOption {
          description = "Configuration of the PostgreSQL synchronous replication feature";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecPostgresqlSynchronous"));
        };
      };

      config = {
        "enableAlterSystem" = mkOverride 1002 null;
        "extensions" = mkOverride 1002 null;
        "ldap" = mkOverride 1002 null;
        "parameters" = mkOverride 1002 null;
        "pg_hba" = mkOverride 1002 null;
        "pg_ident" = mkOverride 1002 null;
        "promotionTimeout" = mkOverride 1002 null;
        "shared_preload_libraries" = mkOverride 1002 null;
        "syncReplicaElectionConstraint" = mkOverride 1002 null;
        "synchronous" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecPostgresqlExtensions" = {

      options = {
        "dynamic_library_path" = mkOption {
          description = "The list of directories inside the image which should be added to dynamic_library_path.\nIf not defined, defaults to \"/lib\".";
          type = (types.nullOr (types.listOf types.str));
        };
        "extension_control_path" = mkOption {
          description = "The list of directories inside the image which should be added to extension_control_path.\nIf not defined, defaults to \"/share\".";
          type = (types.nullOr (types.listOf types.str));
        };
        "image" = mkOption {
          description = "The image containing the extension, required";
          type = (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecPostgresqlExtensionsImage");
        };
        "ld_library_path" = mkOption {
          description = "The list of directories inside the image which should be added to ld_library_path.";
          type = (types.nullOr (types.listOf types.str));
        };
        "name" = mkOption {
          description = "The name of the extension, required";
          type = types.str;
        };
      };

      config = {
        "dynamic_library_path" = mkOverride 1002 null;
        "extension_control_path" = mkOverride 1002 null;
        "ld_library_path" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecPostgresqlExtensionsImage" = {

      options = {
        "pullPolicy" = mkOption {
          description = "Policy for pulling OCI objects. Possible values are:\nAlways: the kubelet always attempts to pull the reference. Container creation will fail If the pull fails.\nNever: the kubelet never pulls the reference and only uses a local image or artifact. Container creation will fail if the reference isn't present.\nIfNotPresent: the kubelet pulls if the reference isn't already present on disk. Container creation will fail if the reference isn't present and the pull fails.\nDefaults to Always if :latest tag is specified, or IfNotPresent otherwise.";
          type = (types.nullOr types.str);
        };
        "reference" = mkOption {
          description = "Required: Image or artifact reference to be used.\nBehaves in the same way as pod.spec.containers[*].image.\nPull secrets will be assembled in the same way as for the container image by looking up node credentials, SA image pull secrets, and pod spec image pull secrets.\nMore info: https://kubernetes.io/docs/concepts/containers/images\nThis field is optional to allow higher level config management to default or override\ncontainer images in workload controllers like Deployments and StatefulSets.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "pullPolicy" = mkOverride 1002 null;
        "reference" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecPostgresqlLdap" = {

      options = {
        "bindAsAuth" = mkOption {
          description = "Bind as authentication configuration";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecPostgresqlLdapBindAsAuth"));
        };
        "bindSearchAuth" = mkOption {
          description = "Bind+Search authentication configuration";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecPostgresqlLdapBindSearchAuth"));
        };
        "port" = mkOption {
          description = "LDAP server port";
          type = (types.nullOr types.int);
        };
        "scheme" = mkOption {
          description = "LDAP schema to be used, possible options are `ldap` and `ldaps`";
          type = (types.nullOr types.str);
        };
        "server" = mkOption {
          description = "LDAP hostname or IP address";
          type = (types.nullOr types.str);
        };
        "tls" = mkOption {
          description = "Set to 'true' to enable LDAP over TLS. 'false' is default";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "bindAsAuth" = mkOverride 1002 null;
        "bindSearchAuth" = mkOverride 1002 null;
        "port" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
        "server" = mkOverride 1002 null;
        "tls" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecPostgresqlLdapBindAsAuth" = {

      options = {
        "prefix" = mkOption {
          description = "Prefix for the bind authentication option";
          type = (types.nullOr types.str);
        };
        "suffix" = mkOption {
          description = "Suffix for the bind authentication option";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "prefix" = mkOverride 1002 null;
        "suffix" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecPostgresqlLdapBindSearchAuth" = {

      options = {
        "baseDN" = mkOption {
          description = "Root DN to begin the user search";
          type = (types.nullOr types.str);
        };
        "bindDN" = mkOption {
          description = "DN of the user to bind to the directory";
          type = (types.nullOr types.str);
        };
        "bindPassword" = mkOption {
          description = "Secret with the password for the user to bind to the directory";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecPostgresqlLdapBindSearchAuthBindPassword"
            )
          );
        };
        "searchAttribute" = mkOption {
          description = "Attribute to match against the username";
          type = (types.nullOr types.str);
        };
        "searchFilter" = mkOption {
          description = "Search filter to use when doing the search+bind authentication";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "baseDN" = mkOverride 1002 null;
        "bindDN" = mkOverride 1002 null;
        "bindPassword" = mkOverride 1002 null;
        "searchAttribute" = mkOverride 1002 null;
        "searchFilter" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecPostgresqlLdapBindSearchAuthBindPassword" = {

      options = {
        "key" = mkOption {
          description = "The key of the secret to select from.  Must be a valid secret key.";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "Specify whether the Secret or its key must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecPostgresqlSyncReplicaElectionConstraint" = {

      options = {
        "enabled" = mkOption {
          description = "This flag enables the constraints for sync replicas";
          type = types.bool;
        };
        "nodeLabelsAntiAffinity" = mkOption {
          description = "A list of node labels values to extract and compare to evaluate if the pods reside in the same topology or not";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "nodeLabelsAntiAffinity" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecPostgresqlSynchronous" = {

      options = {
        "dataDurability" = mkOption {
          description = "If set to \"required\", data durability is strictly enforced. Write operations\nwith synchronous commit settings (`on`, `remote_write`, or `remote_apply`) will\nblock if there are insufficient healthy replicas, ensuring data persistence.\nIf set to \"preferred\", data durability is maintained when healthy replicas\nare available, but the required number of instances will adjust dynamically\nif replicas become unavailable. This setting relaxes strict durability enforcement\nto allow for operational continuity. This setting is only applicable if both\n`standbyNamesPre` and `standbyNamesPost` are unset (empty).";
          type = (types.nullOr types.str);
        };
        "failoverQuorum" = mkOption {
          description = "FailoverQuorum enables a quorum-based check before failover, improving\ndata durability and safety during failover events in CloudNativePG-managed\nPostgreSQL clusters.";
          type = (types.nullOr types.bool);
        };
        "maxStandbyNamesFromCluster" = mkOption {
          description = "Specifies the maximum number of local cluster pods that can be\nautomatically included in the `synchronous_standby_names` option in\nPostgreSQL.";
          type = (types.nullOr types.int);
        };
        "method" = mkOption {
          description = "Method to select synchronous replication standbys from the listed\nservers, accepting 'any' (quorum-based synchronous replication) or\n'first' (priority-based synchronous replication) as values.";
          type = types.str;
        };
        "number" = mkOption {
          description = "Specifies the number of synchronous standby servers that\ntransactions must wait for responses from.";
          type = types.int;
        };
        "standbyNamesPost" = mkOption {
          description = "A user-defined list of application names to be added to\n`synchronous_standby_names` after local cluster pods (the order is\nonly useful for priority-based synchronous replication).";
          type = (types.nullOr (types.listOf types.str));
        };
        "standbyNamesPre" = mkOption {
          description = "A user-defined list of application names to be added to\n`synchronous_standby_names` before local cluster pods (the order is\nonly useful for priority-based synchronous replication).";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "dataDurability" = mkOverride 1002 null;
        "failoverQuorum" = mkOverride 1002 null;
        "maxStandbyNamesFromCluster" = mkOverride 1002 null;
        "standbyNamesPost" = mkOverride 1002 null;
        "standbyNamesPre" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProbes" = {

      options = {
        "liveness" = mkOption {
          description = "The liveness probe configuration";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProbesLiveness"));
        };
        "readiness" = mkOption {
          description = "The readiness probe configuration";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProbesReadiness"));
        };
        "startup" = mkOption {
          description = "The startup probe configuration";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProbesStartup"));
        };
      };

      config = {
        "liveness" = mkOverride 1002 null;
        "readiness" = mkOverride 1002 null;
        "startup" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProbesLiveness" = {

      options = {
        "failureThreshold" = mkOption {
          description = "Minimum consecutive failures for the probe to be considered failed after having succeeded.\nDefaults to 3. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "initialDelaySeconds" = mkOption {
          description = "Number of seconds after the container has started before liveness probes are initiated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
        "isolationCheck" = mkOption {
          description = "Configure the feature that extends the liveness probe for a primary\ninstance. In addition to the basic checks, this verifies whether the\nprimary is isolated from the Kubernetes API server and from its\nreplicas, ensuring that it can be safely shut down if network\npartition or API unavailability is detected. Enabled by default.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProbesLivenessIsolationCheck"));
        };
        "periodSeconds" = mkOption {
          description = "How often (in seconds) to perform the probe.\nDefault to 10 seconds. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "Minimum consecutive successes for the probe to be considered successful after having failed.\nDefaults to 1. Must be 1 for liveness and startup. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "Optional duration in seconds the pod needs to terminate gracefully upon probe failure.\nThe grace period is the duration in seconds after the processes running in the pod are sent\na termination signal and the time when the processes are forcibly halted with a kill signal.\nSet this value longer than the expected cleanup time for your process.\nIf this value is nil, the pod's terminationGracePeriodSeconds will be used. Otherwise, this\nvalue overrides the value provided by the pod spec.\nValue must be non-negative integer. The value zero indicates stop immediately via\nthe kill signal (no opportunity to shut down).\nThis is a beta field and requires enabling ProbeTerminationGracePeriod feature gate.\nMinimum value is 1. spec.terminationGracePeriodSeconds is used if unset.";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "Number of seconds after which the probe times out.\nDefaults to 1 second. Minimum value is 1.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "failureThreshold" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "isolationCheck" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProbesLivenessIsolationCheck" = {

      options = {
        "connectionTimeout" = mkOption {
          description = "Timeout in milliseconds for connections during the primary isolation check";
          type = (types.nullOr types.int);
        };
        "enabled" = mkOption {
          description = "Whether primary isolation checking is enabled for the liveness probe";
          type = (types.nullOr types.bool);
        };
        "requestTimeout" = mkOption {
          description = "Timeout in milliseconds for requests during the primary isolation check";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "connectionTimeout" = mkOverride 1002 null;
        "enabled" = mkOverride 1002 null;
        "requestTimeout" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProbesReadiness" = {

      options = {
        "failureThreshold" = mkOption {
          description = "Minimum consecutive failures for the probe to be considered failed after having succeeded.\nDefaults to 3. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "initialDelaySeconds" = mkOption {
          description = "Number of seconds after the container has started before liveness probes are initiated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
        "maximumLag" = mkOption {
          description = "Lag limit. Used only for `streaming` strategy";
          type = (types.nullOr (types.either types.int types.str));
        };
        "periodSeconds" = mkOption {
          description = "How often (in seconds) to perform the probe.\nDefault to 10 seconds. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "Minimum consecutive successes for the probe to be considered successful after having failed.\nDefaults to 1. Must be 1 for liveness and startup. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "Optional duration in seconds the pod needs to terminate gracefully upon probe failure.\nThe grace period is the duration in seconds after the processes running in the pod are sent\na termination signal and the time when the processes are forcibly halted with a kill signal.\nSet this value longer than the expected cleanup time for your process.\nIf this value is nil, the pod's terminationGracePeriodSeconds will be used. Otherwise, this\nvalue overrides the value provided by the pod spec.\nValue must be non-negative integer. The value zero indicates stop immediately via\nthe kill signal (no opportunity to shut down).\nThis is a beta field and requires enabling ProbeTerminationGracePeriod feature gate.\nMinimum value is 1. spec.terminationGracePeriodSeconds is used if unset.";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "Number of seconds after which the probe times out.\nDefaults to 1 second. Minimum value is 1.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
        "type" = mkOption {
          description = "The probe strategy";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "failureThreshold" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "maximumLag" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProbesStartup" = {

      options = {
        "failureThreshold" = mkOption {
          description = "Minimum consecutive failures for the probe to be considered failed after having succeeded.\nDefaults to 3. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "initialDelaySeconds" = mkOption {
          description = "Number of seconds after the container has started before liveness probes are initiated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
        "maximumLag" = mkOption {
          description = "Lag limit. Used only for `streaming` strategy";
          type = (types.nullOr (types.either types.int types.str));
        };
        "periodSeconds" = mkOption {
          description = "How often (in seconds) to perform the probe.\nDefault to 10 seconds. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "Minimum consecutive successes for the probe to be considered successful after having failed.\nDefaults to 1. Must be 1 for liveness and startup. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "Optional duration in seconds the pod needs to terminate gracefully upon probe failure.\nThe grace period is the duration in seconds after the processes running in the pod are sent\na termination signal and the time when the processes are forcibly halted with a kill signal.\nSet this value longer than the expected cleanup time for your process.\nIf this value is nil, the pod's terminationGracePeriodSeconds will be used. Otherwise, this\nvalue overrides the value provided by the pod spec.\nValue must be non-negative integer. The value zero indicates stop immediately via\nthe kill signal (no opportunity to shut down).\nThis is a beta field and requires enabling ProbeTerminationGracePeriod feature gate.\nMinimum value is 1. spec.terminationGracePeriodSeconds is used if unset.";
          type = (types.nullOr types.int);
        };
        "timeoutSeconds" = mkOption {
          description = "Number of seconds after which the probe times out.\nDefaults to 1 second. Minimum value is 1.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
        "type" = mkOption {
          description = "The probe strategy";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "failureThreshold" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "maximumLag" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplate" = {

      options = {
        "defaultMode" = mkOption {
          description = "defaultMode are the mode bits used to set permissions on created files by default.\nMust be an octal value between 0000 and 0777 or a decimal value between 0 and 511.\nYAML accepts both octal and decimal values, JSON requires decimal values for mode bits.\nDirectories within the path are not affected by this setting.\nThis might be in conflict with other options that affect the file\nmode, like fsGroup, and the result can be other mode bits set.";
          type = (types.nullOr types.int);
        };
        "sources" = mkOption {
          description = "sources is the list of volume projections. Each entry in this list\nhandles one source.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSources")
            )
          );
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "sources" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSources" = {

      options = {
        "clusterTrustBundle" = mkOption {
          description = "ClusterTrustBundle allows a pod to access the `.spec.trustBundle` field\nof ClusterTrustBundle objects in an auto-updating file.\n\nAlpha, gated by the ClusterTrustBundleProjection feature gate.\n\nClusterTrustBundle objects can either be selected by name, or by the\ncombination of signer name and a label selector.\n\nKubelet performs aggressive normalization of the PEM contents written\ninto the pod filesystem.  Esoteric PEM features such as inter-block\ncomments and block headers are stripped.  Certificates are deduplicated.\nThe ordering of certificates within the file is arbitrary, and Kubelet\nmay change the order over time.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesClusterTrustBundle"
            )
          );
        };
        "configMap" = mkOption {
          description = "configMap information about the configMap data to project";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesConfigMap"
            )
          );
        };
        "downwardAPI" = mkOption {
          description = "downwardAPI information about the downwardAPI data to project";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesDownwardAPI"
            )
          );
        };
        "podCertificate" = mkOption {
          description = "Projects an auto-rotating credential bundle (private key and certificate\nchain) that the pod can use either as a TLS client or server.\n\nKubelet generates a private key and uses it to send a\nPodCertificateRequest to the named signer.  Once the signer approves the\nrequest and issues a certificate chain, Kubelet writes the key and\ncertificate chain to the pod filesystem.  The pod does not start until\ncertificates have been issued for each podCertificate projected volume\nsource in its spec.\n\nKubelet will begin trying to rotate the certificate at the time indicated\nby the signer using the PodCertificateRequest.Status.BeginRefreshAt\ntimestamp.\n\nKubelet can write a single file, indicated by the credentialBundlePath\nfield, or separate files, indicated by the keyPath and\ncertificateChainPath fields.\n\nThe credential bundle is a single file in PEM format.  The first PEM\nentry is the private key (in PKCS#8 format), and the remaining PEM\nentries are the certificate chain issued by the signer (typically,\nsigners will return their certificate chain in leaf-to-root order).\n\nPrefer using the credential bundle format, since your application code\ncan read it atomically.  If you use keyPath and certificateChainPath,\nyour application must make two separate file reads. If these coincide\nwith a certificate rotation, it is possible that the private key and leaf\ncertificate you read may not correspond to each other.  Your application\nwill need to check for this condition, and re-read until they are\nconsistent.\n\nThe named signer controls chooses the format of the certificate it\nissues; consult the signer implementation's documentation to learn how to\nuse the certificates it issues.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesPodCertificate"
            )
          );
        };
        "secret" = mkOption {
          description = "secret information about the secret data to project";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesSecret")
          );
        };
        "serviceAccountToken" = mkOption {
          description = "serviceAccountToken is information about the serviceAccountToken data to project";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesServiceAccountToken"
            )
          );
        };
      };

      config = {
        "clusterTrustBundle" = mkOverride 1002 null;
        "configMap" = mkOverride 1002 null;
        "downwardAPI" = mkOverride 1002 null;
        "podCertificate" = mkOverride 1002 null;
        "secret" = mkOverride 1002 null;
        "serviceAccountToken" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesClusterTrustBundle" = {

      options = {
        "labelSelector" = mkOption {
          description = "Select all ClusterTrustBundles that match this label selector.  Only has\neffect if signerName is set.  Mutually-exclusive with name.  If unset,\ninterpreted as \"match nothing\".  If set but empty, interpreted as \"match\neverything\".";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesClusterTrustBundleLabelSelector"
            )
          );
        };
        "name" = mkOption {
          description = "Select a single ClusterTrustBundle by object name.  Mutually-exclusive\nwith signerName and labelSelector.";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "If true, don't block pod startup if the referenced ClusterTrustBundle(s)\naren't available.  If using name, then the named ClusterTrustBundle is\nallowed not to exist.  If using signerName, then the combination of\nsignerName and labelSelector is allowed to match zero\nClusterTrustBundles.";
          type = (types.nullOr types.bool);
        };
        "path" = mkOption {
          description = "Relative path from the volume root to write the bundle.";
          type = types.str;
        };
        "signerName" = mkOption {
          description = "Select all ClusterTrustBundles that match this signer name.\nMutually-exclusive with name.  The contents of all selected\nClusterTrustBundles will be unified and deduplicated.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "labelSelector" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
        "signerName" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesClusterTrustBundleLabelSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesClusterTrustBundleLabelSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels\nmap is equivalent to an element of matchExpressions, whose key field is \"key\", the\noperator is \"In\", and the values array contains only \"value\". The requirements are ANDed.";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesClusterTrustBundleLabelSelectorMatchExpressions" =
      {

        options = {
          "key" = mkOption {
            description = "key is the label key that the selector applies to.";
            type = types.str;
          };
          "operator" = mkOption {
            description = "operator represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists and DoesNotExist.";
            type = types.str;
          };
          "values" = mkOption {
            description = "values is an array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. This array is replaced during a strategic\nmerge patch.";
            type = (types.nullOr (types.listOf types.str));
          };
        };

        config = {
          "values" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesConfigMap" = {

      options = {
        "items" = mkOption {
          description = "items if unspecified, each key-value pair in the Data field of the referenced\nConfigMap will be projected into the volume as a file whose name is the\nkey and content is the value. If specified, the listed keys will be\nprojected into the specified paths, and unlisted keys will not be\npresent. If a key is specified which is not present in the ConfigMap,\nthe volume setup will error unless it is marked optional. Paths must be\nrelative and may not contain the '..' path or start with '..'.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesConfigMapItems"
              )
            )
          );
        };
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "optional specify whether the ConfigMap or its keys must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "items" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesConfigMapItems" = {

      options = {
        "key" = mkOption {
          description = "key is the key to project.";
          type = types.str;
        };
        "mode" = mkOption {
          description = "mode is Optional: mode bits used to set permissions on this file.\nMust be an octal value between 0000 and 0777 or a decimal value between 0 and 511.\nYAML accepts both octal and decimal values, JSON requires decimal values for mode bits.\nIf not specified, the volume defaultMode will be used.\nThis might be in conflict with other options that affect the file\nmode, like fsGroup, and the result can be other mode bits set.";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "path is the relative path of the file to map the key to.\nMay not be an absolute path.\nMay not contain the path element '..'.\nMay not start with the string '..'.";
          type = types.str;
        };
      };

      config = {
        "mode" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesDownwardAPI" = {

      options = {
        "items" = mkOption {
          description = "Items is a list of DownwardAPIVolume file";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesDownwardAPIItems"
              )
            )
          );
        };
      };

      config = {
        "items" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesDownwardAPIItems" = {

      options = {
        "fieldRef" = mkOption {
          description = "Required: Selects a field of the pod: only annotations, labels, name, namespace and uid are supported.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesDownwardAPIItemsFieldRef"
            )
          );
        };
        "mode" = mkOption {
          description = "Optional: mode bits used to set permissions on this file, must be an octal value\nbetween 0000 and 0777 or a decimal value between 0 and 511.\nYAML accepts both octal and decimal values, JSON requires decimal values for mode bits.\nIf not specified, the volume defaultMode will be used.\nThis might be in conflict with other options that affect the file\nmode, like fsGroup, and the result can be other mode bits set.";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "Required: Path is  the relative path name of the file to be created. Must not be absolute or contain the '..' path. Must be utf-8 encoded. The first item of the relative path must not start with '..'";
          type = types.str;
        };
        "resourceFieldRef" = mkOption {
          description = "Selects a resource of the container: only resources limits and requests\n(limits.cpu, limits.memory, requests.cpu and requests.memory) are currently supported.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesDownwardAPIItemsResourceFieldRef"
            )
          );
        };
      };

      config = {
        "fieldRef" = mkOverride 1002 null;
        "mode" = mkOverride 1002 null;
        "resourceFieldRef" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesDownwardAPIItemsFieldRef" = {

      options = {
        "apiVersion" = mkOption {
          description = "Version of the schema the FieldPath is written in terms of, defaults to \"v1\".";
          type = (types.nullOr types.str);
        };
        "fieldPath" = mkOption {
          description = "Path of the field to select in the specified API version.";
          type = types.str;
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesDownwardAPIItemsResourceFieldRef" =
      {

        options = {
          "containerName" = mkOption {
            description = "Container name: required for volumes, optional for env vars";
            type = (types.nullOr types.str);
          };
          "divisor" = mkOption {
            description = "Specifies the output format of the exposed resources, defaults to \"1\"";
            type = (types.nullOr (types.either types.int types.str));
          };
          "resource" = mkOption {
            description = "Required: resource to select";
            type = types.str;
          };
        };

        config = {
          "containerName" = mkOverride 1002 null;
          "divisor" = mkOverride 1002 null;
        };

      };
    "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesPodCertificate" = {

      options = {
        "certificateChainPath" = mkOption {
          description = "Write the certificate chain at this path in the projected volume.\n\nMost applications should use credentialBundlePath.  When using keyPath\nand certificateChainPath, your application needs to check that the key\nand leaf certificate are consistent, because it is possible to read the\nfiles mid-rotation.";
          type = (types.nullOr types.str);
        };
        "credentialBundlePath" = mkOption {
          description = "Write the credential bundle at this path in the projected volume.\n\nThe credential bundle is a single file that contains multiple PEM blocks.\nThe first PEM block is a PRIVATE KEY block, containing a PKCS#8 private\nkey.\n\nThe remaining blocks are CERTIFICATE blocks, containing the issued\ncertificate chain from the signer (leaf and any intermediates).\n\nUsing credentialBundlePath lets your Pod's application code make a single\natomic read that retrieves a consistent key and certificate chain.  If you\nproject them to separate files, your application code will need to\nadditionally check that the leaf certificate was issued to the key.";
          type = (types.nullOr types.str);
        };
        "keyPath" = mkOption {
          description = "Write the key at this path in the projected volume.\n\nMost applications should use credentialBundlePath.  When using keyPath\nand certificateChainPath, your application needs to check that the key\nand leaf certificate are consistent, because it is possible to read the\nfiles mid-rotation.";
          type = (types.nullOr types.str);
        };
        "keyType" = mkOption {
          description = "The type of keypair Kubelet will generate for the pod.\n\nValid values are \"RSA3072\", \"RSA4096\", \"ECDSAP256\", \"ECDSAP384\",\n\"ECDSAP521\", and \"ED25519\".";
          type = types.str;
        };
        "maxExpirationSeconds" = mkOption {
          description = "maxExpirationSeconds is the maximum lifetime permitted for the\ncertificate.\n\nKubelet copies this value verbatim into the PodCertificateRequests it\ngenerates for this projection.\n\nIf omitted, kube-apiserver will set it to 86400(24 hours). kube-apiserver\nwill reject values shorter than 3600 (1 hour).  The maximum allowable\nvalue is 7862400 (91 days).\n\nThe signer implementation is then free to issue a certificate with any\nlifetime *shorter* than MaxExpirationSeconds, but no shorter than 3600\nseconds (1 hour).  This constraint is enforced by kube-apiserver.\n`kubernetes.io` signers will never issue certificates with a lifetime\nlonger than 24 hours.";
          type = (types.nullOr types.int);
        };
        "signerName" = mkOption {
          description = "Kubelet's generated CSRs will be addressed to this signer.";
          type = types.str;
        };
      };

      config = {
        "certificateChainPath" = mkOverride 1002 null;
        "credentialBundlePath" = mkOverride 1002 null;
        "keyPath" = mkOverride 1002 null;
        "maxExpirationSeconds" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesSecret" = {

      options = {
        "items" = mkOption {
          description = "items if unspecified, each key-value pair in the Data field of the referenced\nSecret will be projected into the volume as a file whose name is the\nkey and content is the value. If specified, the listed keys will be\nprojected into the specified paths, and unlisted keys will not be\npresent. If a key is specified which is not present in the Secret,\nthe volume setup will error unless it is marked optional. Paths must be\nrelative and may not contain the '..' path or start with '..'.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesSecretItems"
              )
            )
          );
        };
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
        "optional" = mkOption {
          description = "optional field specify whether the Secret or its key must be defined";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "items" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesSecretItems" = {

      options = {
        "key" = mkOption {
          description = "key is the key to project.";
          type = types.str;
        };
        "mode" = mkOption {
          description = "mode is Optional: mode bits used to set permissions on this file.\nMust be an octal value between 0000 and 0777 or a decimal value between 0 and 511.\nYAML accepts both octal and decimal values, JSON requires decimal values for mode bits.\nIf not specified, the volume defaultMode will be used.\nThis might be in conflict with other options that affect the file\nmode, like fsGroup, and the result can be other mode bits set.";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "path is the relative path of the file to map the key to.\nMay not be an absolute path.\nMay not contain the path element '..'.\nMay not start with the string '..'.";
          type = types.str;
        };
      };

      config = {
        "mode" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecProjectedVolumeTemplateSourcesServiceAccountToken" = {

      options = {
        "audience" = mkOption {
          description = "audience is the intended audience of the token. A recipient of a token\nmust identify itself with an identifier specified in the audience of the\ntoken, and otherwise should reject the token. The audience defaults to the\nidentifier of the apiserver.";
          type = (types.nullOr types.str);
        };
        "expirationSeconds" = mkOption {
          description = "expirationSeconds is the requested duration of validity of the service\naccount token. As the token approaches expiration, the kubelet volume\nplugin will proactively rotate the service account token. The kubelet will\nstart trying to rotate the token if the token is older than 80 percent of\nits time to live or if the token is older than 24 hours.Defaults to 1 hour\nand must be at least 10 minutes.";
          type = (types.nullOr types.int);
        };
        "path" = mkOption {
          description = "path is the path relative to the mount point of the file to project the\ntoken into.";
          type = types.str;
        };
      };

      config = {
        "audience" = mkOverride 1002 null;
        "expirationSeconds" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecReplica" = {

      options = {
        "enabled" = mkOption {
          description = "If replica mode is enabled, this cluster will be a replica of an\nexisting cluster. Replica cluster can be created from a recovery\nobject store or via streaming through pg_basebackup.\nRefer to the Replica clusters page of the documentation for more information.";
          type = (types.nullOr types.bool);
        };
        "minApplyDelay" = mkOption {
          description = "When replica mode is enabled, this parameter allows you to replay\ntransactions only when the system time is at least the configured\ntime past the commit time. This provides an opportunity to correct\ndata loss errors. Note that when this parameter is set, a promotion\ntoken cannot be used.";
          type = (types.nullOr types.str);
        };
        "primary" = mkOption {
          description = "Primary defines which Cluster is defined to be the primary in the distributed PostgreSQL cluster, based on the\ntopology specified in externalClusters";
          type = (types.nullOr types.str);
        };
        "promotionToken" = mkOption {
          description = "A demotion token generated by an external cluster used to\ncheck if the promotion requirements are met.";
          type = (types.nullOr types.str);
        };
        "self" = mkOption {
          description = "Self defines the name of this cluster. It is used to determine if this is a primary\nor a replica cluster, comparing it with `primary`";
          type = (types.nullOr types.str);
        };
        "source" = mkOption {
          description = "The name of the external cluster which is the replication origin";
          type = types.str;
        };
      };

      config = {
        "enabled" = mkOverride 1002 null;
        "minApplyDelay" = mkOverride 1002 null;
        "primary" = mkOverride 1002 null;
        "promotionToken" = mkOverride 1002 null;
        "self" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecReplicationSlots" = {

      options = {
        "highAvailability" = mkOption {
          description = "Replication slots for high availability configuration";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecReplicationSlotsHighAvailability")
          );
        };
        "synchronizeReplicas" = mkOption {
          description = "Configures the synchronization of the user defined physical replication slots";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecReplicationSlotsSynchronizeReplicas")
          );
        };
        "updateInterval" = mkOption {
          description = "Standby will update the status of the local replication slots\nevery `updateInterval` seconds (default 30).";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "highAvailability" = mkOverride 1002 null;
        "synchronizeReplicas" = mkOverride 1002 null;
        "updateInterval" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecReplicationSlotsHighAvailability" = {

      options = {
        "enabled" = mkOption {
          description = "If enabled (default), the operator will automatically manage replication slots\non the primary instance and use them in streaming replication\nconnections with all the standby instances that are part of the HA\ncluster. If disabled, the operator will not take advantage\nof replication slots in streaming connections with the replicas.\nThis feature also controls replication slots in replica cluster,\nfrom the designated primary to its cascading replicas.";
          type = (types.nullOr types.bool);
        };
        "slotPrefix" = mkOption {
          description = "Prefix for replication slots managed by the operator for HA.\nIt may only contain lower case letters, numbers, and the underscore character.\nThis can only be set at creation time. By default set to `_cnpg_`.";
          type = (types.nullOr types.str);
        };
        "synchronizeLogicalDecoding" = mkOption {
          description = "When enabled, the operator automatically manages synchronization of logical\ndecoding (replication) slots across high-availability clusters.\n\nRequires one of the following conditions:\n- PostgreSQL version 17 or later\n- PostgreSQL version < 17 with pg_failover_slots extension enabled";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "enabled" = mkOverride 1002 null;
        "slotPrefix" = mkOverride 1002 null;
        "synchronizeLogicalDecoding" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecReplicationSlotsSynchronizeReplicas" = {

      options = {
        "enabled" = mkOption {
          description = "When set to true, every replication slot that is on the primary is synchronized on each standby";
          type = types.bool;
        };
        "excludePatterns" = mkOption {
          description = "List of regular expression patterns to match the names of replication slots to be excluded (by default empty)";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "excludePatterns" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecResources" = {

      options = {
        "claims" = mkOption {
          description = "Claims lists the names of resources, defined in spec.resourceClaims,\nthat are used by this container.\n\nThis field depends on the\nDynamicResourceAllocation feature gate.\n\nThis field is immutable. It can only be set for containers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.ClusterSpecResourcesClaims" "name" [
                "name"
              ]
            )
          );
          apply = attrsToList;
        };
        "limits" = mkOption {
          description = "Limits describes the maximum amount of compute resources allowed.\nMore info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "Requests describes the minimum amount of compute resources required.\nIf Requests is omitted for a container, it defaults to Limits if that is explicitly specified,\notherwise to an implementation-defined value. Requests cannot exceed Limits.\nMore info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "claims" = mkOverride 1002 null;
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecResourcesClaims" = {

      options = {
        "name" = mkOption {
          description = "Name must match the name of one entry in pod.spec.resourceClaims of\nthe Pod where this field is used. It makes that resource available\ninside a container.";
          type = types.str;
        };
        "request" = mkOption {
          description = "Request is the name chosen for a request in the referenced claim.\nIf empty, everything from the claim is made available, otherwise\nonly the result of this request.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "request" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecSeccompProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "localhostProfile indicates a profile defined in a file on the node should be used.\nThe profile must be preconfigured on the node to work.\nMust be a descending path, relative to the kubelet's configured seccomp profile location.\nMust be set if type is \"Localhost\". Must NOT be set for any other type.";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "type indicates which kind of seccomp profile will be applied.\nValid options are:\n\nLocalhost - a profile defined in a file on the node should be used.\nRuntimeDefault - the container runtime default profile should be used.\nUnconfined - no profile should be applied.";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecSecurityContext" = {

      options = {
        "allowPrivilegeEscalation" = mkOption {
          description = "AllowPrivilegeEscalation controls whether a process can gain more\nprivileges than its parent process. This bool directly controls if\nthe no_new_privs flag will be set on the container process.\nAllowPrivilegeEscalation is true always when the container is:\n1) run as Privileged\n2) has CAP_SYS_ADMIN\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr types.bool);
        };
        "appArmorProfile" = mkOption {
          description = "appArmorProfile is the AppArmor options to use by this container. If set, this profile\noverrides the pod's appArmorProfile.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecSecurityContextAppArmorProfile")
          );
        };
        "capabilities" = mkOption {
          description = "The capabilities to add/drop when running containers.\nDefaults to the default set of capabilities granted by the container runtime.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecSecurityContextCapabilities"));
        };
        "privileged" = mkOption {
          description = "Run container in privileged mode.\nProcesses in privileged containers are essentially equivalent to root on the host.\nDefaults to false.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr types.bool);
        };
        "procMount" = mkOption {
          description = "procMount denotes the type of proc mount to use for the containers.\nThe default value is Default which uses the container runtime defaults for\nreadonly paths and masked paths.\nThis requires the ProcMountType feature flag to be enabled.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr types.str);
        };
        "readOnlyRootFilesystem" = mkOption {
          description = "Whether this container has a read-only root filesystem.\nDefault is false.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr types.bool);
        };
        "runAsGroup" = mkOption {
          description = "The GID to run the entrypoint of the container process.\nUses runtime default if unset.\nMay also be set in PodSecurityContext.  If set in both SecurityContext and\nPodSecurityContext, the value specified in SecurityContext takes precedence.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr types.int);
        };
        "runAsNonRoot" = mkOption {
          description = "Indicates that the container must run as a non-root user.\nIf true, the Kubelet will validate the image at runtime to ensure that it\ndoes not run as UID 0 (root) and fail to start the container if it does.\nIf unset or false, no such validation will be performed.\nMay also be set in PodSecurityContext.  If set in both SecurityContext and\nPodSecurityContext, the value specified in SecurityContext takes precedence.";
          type = (types.nullOr types.bool);
        };
        "runAsUser" = mkOption {
          description = "The UID to run the entrypoint of the container process.\nDefaults to user specified in image metadata if unspecified.\nMay also be set in PodSecurityContext.  If set in both SecurityContext and\nPodSecurityContext, the value specified in SecurityContext takes precedence.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr types.int);
        };
        "seLinuxOptions" = mkOption {
          description = "The SELinux context to be applied to the container.\nIf unspecified, the container runtime will allocate a random SELinux context for each\ncontainer.  May also be set in PodSecurityContext.  If set in both SecurityContext and\nPodSecurityContext, the value specified in SecurityContext takes precedence.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecSecurityContextSeLinuxOptions")
          );
        };
        "seccompProfile" = mkOption {
          description = "The seccomp options to use by this container. If seccomp options are\nprovided at both the pod & container level, the container options\noverride the pod options.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecSecurityContextSeccompProfile")
          );
        };
        "windowsOptions" = mkOption {
          description = "The Windows specific settings applied to all containers.\nIf unspecified, the options from the PodSecurityContext will be used.\nIf set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.\nNote that this field cannot be set when spec.os.name is linux.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecSecurityContextWindowsOptions")
          );
        };
      };

      config = {
        "allowPrivilegeEscalation" = mkOverride 1002 null;
        "appArmorProfile" = mkOverride 1002 null;
        "capabilities" = mkOverride 1002 null;
        "privileged" = mkOverride 1002 null;
        "procMount" = mkOverride 1002 null;
        "readOnlyRootFilesystem" = mkOverride 1002 null;
        "runAsGroup" = mkOverride 1002 null;
        "runAsNonRoot" = mkOverride 1002 null;
        "runAsUser" = mkOverride 1002 null;
        "seLinuxOptions" = mkOverride 1002 null;
        "seccompProfile" = mkOverride 1002 null;
        "windowsOptions" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecSecurityContextAppArmorProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "localhostProfile indicates a profile loaded on the node that should be used.\nThe profile must be preconfigured on the node to work.\nMust match the loaded name of the profile.\nMust be set if and only if type is \"Localhost\".";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "type indicates which kind of AppArmor profile will be applied.\nValid options are:\n  Localhost - a profile pre-loaded on the node.\n  RuntimeDefault - the container runtime's default profile.\n  Unconfined - no AppArmor enforcement.";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecSecurityContextCapabilities" = {

      options = {
        "add" = mkOption {
          description = "Added capabilities";
          type = (types.nullOr (types.listOf types.str));
        };
        "drop" = mkOption {
          description = "Removed capabilities";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "add" = mkOverride 1002 null;
        "drop" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecSecurityContextSeLinuxOptions" = {

      options = {
        "level" = mkOption {
          description = "Level is SELinux level label that applies to the container.";
          type = (types.nullOr types.str);
        };
        "role" = mkOption {
          description = "Role is a SELinux role label that applies to the container.";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "Type is a SELinux type label that applies to the container.";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "User is a SELinux user label that applies to the container.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "level" = mkOverride 1002 null;
        "role" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecSecurityContextSeccompProfile" = {

      options = {
        "localhostProfile" = mkOption {
          description = "localhostProfile indicates a profile defined in a file on the node should be used.\nThe profile must be preconfigured on the node to work.\nMust be a descending path, relative to the kubelet's configured seccomp profile location.\nMust be set if type is \"Localhost\". Must NOT be set for any other type.";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "type indicates which kind of seccomp profile will be applied.\nValid options are:\n\nLocalhost - a profile defined in a file on the node should be used.\nRuntimeDefault - the container runtime default profile should be used.\nUnconfined - no profile should be applied.";
          type = types.str;
        };
      };

      config = {
        "localhostProfile" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecSecurityContextWindowsOptions" = {

      options = {
        "gmsaCredentialSpec" = mkOption {
          description = "GMSACredentialSpec is where the GMSA admission webhook\n(https://github.com/kubernetes-sigs/windows-gmsa) inlines the contents of the\nGMSA credential spec named by the GMSACredentialSpecName field.";
          type = (types.nullOr types.str);
        };
        "gmsaCredentialSpecName" = mkOption {
          description = "GMSACredentialSpecName is the name of the GMSA credential spec to use.";
          type = (types.nullOr types.str);
        };
        "hostProcess" = mkOption {
          description = "HostProcess determines if a container should be run as a 'Host Process' container.\nAll of a Pod's containers must have the same effective HostProcess value\n(it is not allowed to have a mix of HostProcess containers and non-HostProcess containers).\nIn addition, if HostProcess is true then HostNetwork must also be set to true.";
          type = (types.nullOr types.bool);
        };
        "runAsUserName" = mkOption {
          description = "The UserName in Windows to run the entrypoint of the container process.\nDefaults to the user specified in image metadata if unspecified.\nMay also be set in PodSecurityContext. If set in both SecurityContext and\nPodSecurityContext, the value specified in SecurityContext takes precedence.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "gmsaCredentialSpec" = mkOverride 1002 null;
        "gmsaCredentialSpecName" = mkOverride 1002 null;
        "hostProcess" = mkOverride 1002 null;
        "runAsUserName" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecServiceAccountTemplate" = {

      options = {
        "metadata" = mkOption {
          description = "Metadata are the metadata to be used for the generated\nservice account";
          type = (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecServiceAccountTemplateMetadata");
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecServiceAccountTemplateMetadata" = {

      options = {
        "annotations" = mkOption {
          description = "Annotations is an unstructured key value map stored with a resource that may be\nset by external tools to store and retrieve arbitrary metadata. They are not\nqueryable and should be preserved when modifying objects.\nMore info: http://kubernetes.io/docs/user-guide/annotations";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "labels" = mkOption {
          description = "Map of string keys and values that can be used to organize and categorize\n(scope and select) objects. May match selectors of replication controllers\nand services.\nMore info: http://kubernetes.io/docs/user-guide/labels";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "name" = mkOption {
          description = "The name of the resource. Only supported for certain types";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "annotations" = mkOverride 1002 null;
        "labels" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecStorage" = {

      options = {
        "pvcTemplate" = mkOption {
          description = "Template to be used to generate the Persistent Volume Claim";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecStoragePvcTemplate"));
        };
        "resizeInUseVolumes" = mkOption {
          description = "Resize existent PVCs, defaults to true";
          type = (types.nullOr types.bool);
        };
        "size" = mkOption {
          description = "Size of the storage. Required if not already specified in the PVC template.\nChanges to this field are automatically reapplied to the created PVCs.\nSize cannot be decreased.";
          type = (types.nullOr types.str);
        };
        "storageClass" = mkOption {
          description = "StorageClass to use for PVCs. Applied after\nevaluating the PVC template, if available.\nIf not specified, the generated PVCs will use the\ndefault storage class";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "pvcTemplate" = mkOverride 1002 null;
        "resizeInUseVolumes" = mkOverride 1002 null;
        "size" = mkOverride 1002 null;
        "storageClass" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecStoragePvcTemplate" = {

      options = {
        "accessModes" = mkOption {
          description = "accessModes contains the desired access modes the volume should have.\nMore info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes-1";
          type = (types.nullOr (types.listOf types.str));
        };
        "dataSource" = mkOption {
          description = "dataSource field can be used to specify either:\n* An existing VolumeSnapshot object (snapshot.storage.k8s.io/VolumeSnapshot)\n* An existing PVC (PersistentVolumeClaim)\nIf the provisioner or an external controller can support the specified data source,\nit will create a new volume based on the contents of the specified data source.\nWhen the AnyVolumeDataSource feature gate is enabled, dataSource contents will be copied to dataSourceRef,\nand dataSourceRef contents will be copied to dataSource when dataSourceRef.namespace is not specified.\nIf the namespace is specified, then dataSourceRef will not be copied to dataSource.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecStoragePvcTemplateDataSource"));
        };
        "dataSourceRef" = mkOption {
          description = "dataSourceRef specifies the object from which to populate the volume with data, if a non-empty\nvolume is desired. This may be any object from a non-empty API group (non\ncore object) or a PersistentVolumeClaim object.\nWhen this field is specified, volume binding will only succeed if the type of\nthe specified object matches some installed volume populator or dynamic\nprovisioner.\nThis field will replace the functionality of the dataSource field and as such\nif both fields are non-empty, they must have the same value. For backwards\ncompatibility, when namespace isn't specified in dataSourceRef,\nboth fields (dataSource and dataSourceRef) will be set to the same\nvalue automatically if one of them is empty and the other is non-empty.\nWhen namespace is specified in dataSourceRef,\ndataSource isn't set to the same value and must be empty.\nThere are three important differences between dataSource and dataSourceRef:\n* While dataSource only allows two specific types of objects, dataSourceRef\n  allows any non-core object, as well as PersistentVolumeClaim objects.\n* While dataSource ignores disallowed values (dropping them), dataSourceRef\n  preserves all values, and generates an error if a disallowed value is\n  specified.\n* While dataSource only allows local objects, dataSourceRef allows objects\n  in any namespaces.\n(Beta) Using this field requires the AnyVolumeDataSource feature gate to be enabled.\n(Alpha) Using the namespace field of dataSourceRef requires the CrossNamespaceVolumeDataSource feature gate to be enabled.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecStoragePvcTemplateDataSourceRef")
          );
        };
        "resources" = mkOption {
          description = "resources represents the minimum resources the volume should have.\nIf RecoverVolumeExpansionFailure feature is enabled users are allowed to specify resource requirements\nthat are lower than previous value but must still be higher than capacity recorded in the\nstatus field of the claim.\nMore info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#resources";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecStoragePvcTemplateResources"));
        };
        "selector" = mkOption {
          description = "selector is a label query over volumes to consider for binding.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecStoragePvcTemplateSelector"));
        };
        "storageClassName" = mkOption {
          description = "storageClassName is the name of the StorageClass required by the claim.\nMore info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#class-1";
          type = (types.nullOr types.str);
        };
        "volumeAttributesClassName" = mkOption {
          description = "volumeAttributesClassName may be used to set the VolumeAttributesClass used by this claim.\nIf specified, the CSI driver will create or update the volume with the attributes defined\nin the corresponding VolumeAttributesClass. This has a different purpose than storageClassName,\nit can be changed after the claim is created. An empty string or nil value indicates that no\nVolumeAttributesClass will be applied to the claim. If the claim enters an Infeasible error state,\nthis field can be reset to its previous value (including nil) to cancel the modification.\nIf the resource referred to by volumeAttributesClass does not exist, this PersistentVolumeClaim will be\nset to a Pending state, as reflected by the modifyVolumeStatus field, until such as a resource\nexists.\nMore info: https://kubernetes.io/docs/concepts/storage/volume-attributes-classes/";
          type = (types.nullOr types.str);
        };
        "volumeMode" = mkOption {
          description = "volumeMode defines what type of volume is required by the claim.\nValue of Filesystem is implied when not included in claim spec.";
          type = (types.nullOr types.str);
        };
        "volumeName" = mkOption {
          description = "volumeName is the binding reference to the PersistentVolume backing this claim.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "dataSource" = mkOverride 1002 null;
        "dataSourceRef" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "volumeAttributesClassName" = mkOverride 1002 null;
        "volumeMode" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecStoragePvcTemplateDataSource" = {

      options = {
        "apiGroup" = mkOption {
          description = "APIGroup is the group for the resource being referenced.\nIf APIGroup is not specified, the specified Kind must be in the core API group.\nFor any other third-party types, APIGroup is required.";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "Kind is the type of resource being referenced";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name is the name of resource being referenced";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecStoragePvcTemplateDataSourceRef" = {

      options = {
        "apiGroup" = mkOption {
          description = "APIGroup is the group for the resource being referenced.\nIf APIGroup is not specified, the specified Kind must be in the core API group.\nFor any other third-party types, APIGroup is required.";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "Kind is the type of resource being referenced";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name is the name of resource being referenced";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "Namespace is the namespace of resource being referenced\nNote that when a namespace is specified, a gateway.networking.k8s.io/ReferenceGrant object is required in the referent namespace to allow that namespace's owner to accept the reference. See the ReferenceGrant documentation for details.\n(Alpha) This field requires the CrossNamespaceVolumeDataSource feature gate to be enabled.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecStoragePvcTemplateResources" = {

      options = {
        "limits" = mkOption {
          description = "Limits describes the maximum amount of compute resources allowed.\nMore info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "Requests describes the minimum amount of compute resources required.\nIf Requests is omitted for a container, it defaults to Limits if that is explicitly specified,\notherwise to an implementation-defined value. Requests cannot exceed Limits.\nMore info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecStoragePvcTemplateSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecStoragePvcTemplateSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels\nmap is equivalent to an element of matchExpressions, whose key field is \"key\", the\noperator is \"In\", and the values array contains only \"value\". The requirements are ANDed.";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecStoragePvcTemplateSelectorMatchExpressions" = {

      options = {
        "key" = mkOption {
          description = "key is the label key that the selector applies to.";
          type = types.str;
        };
        "operator" = mkOption {
          description = "operator represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists and DoesNotExist.";
          type = types.str;
        };
        "values" = mkOption {
          description = "values is an array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. This array is replaced during a strategic\nmerge patch.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "values" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecSuperuserSecret" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterSpecTablespaces" = {

      options = {
        "name" = mkOption {
          description = "The name of the tablespace";
          type = types.str;
        };
        "owner" = mkOption {
          description = "Owner is the PostgreSQL user owning the tablespace";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecTablespacesOwner"));
        };
        "storage" = mkOption {
          description = "The storage configuration for the tablespace";
          type = (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecTablespacesStorage");
        };
        "temporary" = mkOption {
          description = "When set to true, the tablespace will be added as a `temp_tablespaces`\nentry in PostgreSQL, and will be available to automatically house temp\ndatabase objects, or other temporary files. Please refer to PostgreSQL\ndocumentation for more information on the `temp_tablespaces` GUC.";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "owner" = mkOverride 1002 null;
        "temporary" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecTablespacesOwner" = {

      options = {
        "name" = mkOption {
          description = "";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecTablespacesStorage" = {

      options = {
        "pvcTemplate" = mkOption {
          description = "Template to be used to generate the Persistent Volume Claim";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecTablespacesStoragePvcTemplate")
          );
        };
        "resizeInUseVolumes" = mkOption {
          description = "Resize existent PVCs, defaults to true";
          type = (types.nullOr types.bool);
        };
        "size" = mkOption {
          description = "Size of the storage. Required if not already specified in the PVC template.\nChanges to this field are automatically reapplied to the created PVCs.\nSize cannot be decreased.";
          type = (types.nullOr types.str);
        };
        "storageClass" = mkOption {
          description = "StorageClass to use for PVCs. Applied after\nevaluating the PVC template, if available.\nIf not specified, the generated PVCs will use the\ndefault storage class";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "pvcTemplate" = mkOverride 1002 null;
        "resizeInUseVolumes" = mkOverride 1002 null;
        "size" = mkOverride 1002 null;
        "storageClass" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecTablespacesStoragePvcTemplate" = {

      options = {
        "accessModes" = mkOption {
          description = "accessModes contains the desired access modes the volume should have.\nMore info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes-1";
          type = (types.nullOr (types.listOf types.str));
        };
        "dataSource" = mkOption {
          description = "dataSource field can be used to specify either:\n* An existing VolumeSnapshot object (snapshot.storage.k8s.io/VolumeSnapshot)\n* An existing PVC (PersistentVolumeClaim)\nIf the provisioner or an external controller can support the specified data source,\nit will create a new volume based on the contents of the specified data source.\nWhen the AnyVolumeDataSource feature gate is enabled, dataSource contents will be copied to dataSourceRef,\nand dataSourceRef contents will be copied to dataSource when dataSourceRef.namespace is not specified.\nIf the namespace is specified, then dataSourceRef will not be copied to dataSource.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecTablespacesStoragePvcTemplateDataSource"
            )
          );
        };
        "dataSourceRef" = mkOption {
          description = "dataSourceRef specifies the object from which to populate the volume with data, if a non-empty\nvolume is desired. This may be any object from a non-empty API group (non\ncore object) or a PersistentVolumeClaim object.\nWhen this field is specified, volume binding will only succeed if the type of\nthe specified object matches some installed volume populator or dynamic\nprovisioner.\nThis field will replace the functionality of the dataSource field and as such\nif both fields are non-empty, they must have the same value. For backwards\ncompatibility, when namespace isn't specified in dataSourceRef,\nboth fields (dataSource and dataSourceRef) will be set to the same\nvalue automatically if one of them is empty and the other is non-empty.\nWhen namespace is specified in dataSourceRef,\ndataSource isn't set to the same value and must be empty.\nThere are three important differences between dataSource and dataSourceRef:\n* While dataSource only allows two specific types of objects, dataSourceRef\n  allows any non-core object, as well as PersistentVolumeClaim objects.\n* While dataSource ignores disallowed values (dropping them), dataSourceRef\n  preserves all values, and generates an error if a disallowed value is\n  specified.\n* While dataSource only allows local objects, dataSourceRef allows objects\n  in any namespaces.\n(Beta) Using this field requires the AnyVolumeDataSource feature gate to be enabled.\n(Alpha) Using the namespace field of dataSourceRef requires the CrossNamespaceVolumeDataSource feature gate to be enabled.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterSpecTablespacesStoragePvcTemplateDataSourceRef"
            )
          );
        };
        "resources" = mkOption {
          description = "resources represents the minimum resources the volume should have.\nIf RecoverVolumeExpansionFailure feature is enabled users are allowed to specify resource requirements\nthat are lower than previous value but must still be higher than capacity recorded in the\nstatus field of the claim.\nMore info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#resources";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecTablespacesStoragePvcTemplateResources")
          );
        };
        "selector" = mkOption {
          description = "selector is a label query over volumes to consider for binding.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecTablespacesStoragePvcTemplateSelector")
          );
        };
        "storageClassName" = mkOption {
          description = "storageClassName is the name of the StorageClass required by the claim.\nMore info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#class-1";
          type = (types.nullOr types.str);
        };
        "volumeAttributesClassName" = mkOption {
          description = "volumeAttributesClassName may be used to set the VolumeAttributesClass used by this claim.\nIf specified, the CSI driver will create or update the volume with the attributes defined\nin the corresponding VolumeAttributesClass. This has a different purpose than storageClassName,\nit can be changed after the claim is created. An empty string or nil value indicates that no\nVolumeAttributesClass will be applied to the claim. If the claim enters an Infeasible error state,\nthis field can be reset to its previous value (including nil) to cancel the modification.\nIf the resource referred to by volumeAttributesClass does not exist, this PersistentVolumeClaim will be\nset to a Pending state, as reflected by the modifyVolumeStatus field, until such as a resource\nexists.\nMore info: https://kubernetes.io/docs/concepts/storage/volume-attributes-classes/";
          type = (types.nullOr types.str);
        };
        "volumeMode" = mkOption {
          description = "volumeMode defines what type of volume is required by the claim.\nValue of Filesystem is implied when not included in claim spec.";
          type = (types.nullOr types.str);
        };
        "volumeName" = mkOption {
          description = "volumeName is the binding reference to the PersistentVolume backing this claim.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "dataSource" = mkOverride 1002 null;
        "dataSourceRef" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "volumeAttributesClassName" = mkOverride 1002 null;
        "volumeMode" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecTablespacesStoragePvcTemplateDataSource" = {

      options = {
        "apiGroup" = mkOption {
          description = "APIGroup is the group for the resource being referenced.\nIf APIGroup is not specified, the specified Kind must be in the core API group.\nFor any other third-party types, APIGroup is required.";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "Kind is the type of resource being referenced";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name is the name of resource being referenced";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecTablespacesStoragePvcTemplateDataSourceRef" = {

      options = {
        "apiGroup" = mkOption {
          description = "APIGroup is the group for the resource being referenced.\nIf APIGroup is not specified, the specified Kind must be in the core API group.\nFor any other third-party types, APIGroup is required.";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "Kind is the type of resource being referenced";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name is the name of resource being referenced";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "Namespace is the namespace of resource being referenced\nNote that when a namespace is specified, a gateway.networking.k8s.io/ReferenceGrant object is required in the referent namespace to allow that namespace's owner to accept the reference. See the ReferenceGrant documentation for details.\n(Alpha) This field requires the CrossNamespaceVolumeDataSource feature gate to be enabled.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecTablespacesStoragePvcTemplateResources" = {

      options = {
        "limits" = mkOption {
          description = "Limits describes the maximum amount of compute resources allowed.\nMore info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "Requests describes the minimum amount of compute resources required.\nIf Requests is omitted for a container, it defaults to Limits if that is explicitly specified,\notherwise to an implementation-defined value. Requests cannot exceed Limits.\nMore info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecTablespacesStoragePvcTemplateSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecTablespacesStoragePvcTemplateSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels\nmap is equivalent to an element of matchExpressions, whose key field is \"key\", the\noperator is \"In\", and the values array contains only \"value\". The requirements are ANDed.";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecTablespacesStoragePvcTemplateSelectorMatchExpressions" = {

      options = {
        "key" = mkOption {
          description = "key is the label key that the selector applies to.";
          type = types.str;
        };
        "operator" = mkOption {
          description = "operator represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists and DoesNotExist.";
          type = types.str;
        };
        "values" = mkOption {
          description = "values is an array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. This array is replaced during a strategic\nmerge patch.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "values" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecTopologySpreadConstraints" = {

      options = {
        "labelSelector" = mkOption {
          description = "LabelSelector is used to find matching pods.\nPods that match this label selector are counted to determine the number of pods\nin their corresponding topology domain.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecTopologySpreadConstraintsLabelSelector")
          );
        };
        "matchLabelKeys" = mkOption {
          description = "MatchLabelKeys is a set of pod label keys to select the pods over which\nspreading will be calculated. The keys are used to lookup values from the\nincoming pod labels, those key-value labels are ANDed with labelSelector\nto select the group of existing pods over which spreading will be calculated\nfor the incoming pod. The same key is forbidden to exist in both MatchLabelKeys and LabelSelector.\nMatchLabelKeys cannot be set when LabelSelector isn't set.\nKeys that don't exist in the incoming pod labels will\nbe ignored. A null or empty list means only match against labelSelector.\n\nThis is a beta field and requires the MatchLabelKeysInPodTopologySpread feature gate to be enabled (enabled by default).";
          type = (types.nullOr (types.listOf types.str));
        };
        "maxSkew" = mkOption {
          description = "MaxSkew describes the degree to which pods may be unevenly distributed.\nWhen `whenUnsatisfiable=DoNotSchedule`, it is the maximum permitted difference\nbetween the number of matching pods in the target topology and the global minimum.\nThe global minimum is the minimum number of matching pods in an eligible domain\nor zero if the number of eligible domains is less than MinDomains.\nFor example, in a 3-zone cluster, MaxSkew is set to 1, and pods with the same\nlabelSelector spread as 2/2/1:\nIn this case, the global minimum is 1.\n| zone1 | zone2 | zone3 |\n|  P P  |  P P  |   P   |\n- if MaxSkew is 1, incoming pod can only be scheduled to zone3 to become 2/2/2;\nscheduling it onto zone1(zone2) would make the ActualSkew(3-1) on zone1(zone2)\nviolate MaxSkew(1).\n- if MaxSkew is 2, incoming pod can be scheduled onto any zone.\nWhen `whenUnsatisfiable=ScheduleAnyway`, it is used to give higher precedence\nto topologies that satisfy it.\nIt's a required field. Default value is 1 and 0 is not allowed.";
          type = types.int;
        };
        "minDomains" = mkOption {
          description = "MinDomains indicates a minimum number of eligible domains.\nWhen the number of eligible domains with matching topology keys is less than minDomains,\nPod Topology Spread treats \"global minimum\" as 0, and then the calculation of Skew is performed.\nAnd when the number of eligible domains with matching topology keys equals or greater than minDomains,\nthis value has no effect on scheduling.\nAs a result, when the number of eligible domains is less than minDomains,\nscheduler won't schedule more than maxSkew Pods to those domains.\nIf value is nil, the constraint behaves as if MinDomains is equal to 1.\nValid values are integers greater than 0.\nWhen value is not nil, WhenUnsatisfiable must be DoNotSchedule.\n\nFor example, in a 3-zone cluster, MaxSkew is set to 2, MinDomains is set to 5 and pods with the same\nlabelSelector spread as 2/2/2:\n| zone1 | zone2 | zone3 |\n|  P P  |  P P  |  P P  |\nThe number of domains is less than 5(MinDomains), so \"global minimum\" is treated as 0.\nIn this situation, new pod with the same labelSelector cannot be scheduled,\nbecause computed skew will be 3(3 - 0) if new Pod is scheduled to any of the three zones,\nit will violate MaxSkew.";
          type = (types.nullOr types.int);
        };
        "nodeAffinityPolicy" = mkOption {
          description = "NodeAffinityPolicy indicates how we will treat Pod's nodeAffinity/nodeSelector\nwhen calculating pod topology spread skew. Options are:\n- Honor: only nodes matching nodeAffinity/nodeSelector are included in the calculations.\n- Ignore: nodeAffinity/nodeSelector are ignored. All nodes are included in the calculations.\n\nIf this value is nil, the behavior is equivalent to the Honor policy.";
          type = (types.nullOr types.str);
        };
        "nodeTaintsPolicy" = mkOption {
          description = "NodeTaintsPolicy indicates how we will treat node taints when calculating\npod topology spread skew. Options are:\n- Honor: nodes without taints, along with tainted nodes for which the incoming pod\nhas a toleration, are included.\n- Ignore: node taints are ignored. All nodes are included.\n\nIf this value is nil, the behavior is equivalent to the Ignore policy.";
          type = (types.nullOr types.str);
        };
        "topologyKey" = mkOption {
          description = "TopologyKey is the key of node labels. Nodes that have a label with this key\nand identical values are considered to be in the same topology.\nWe consider each <key, value> as a \"bucket\", and try to put balanced number\nof pods into each bucket.\nWe define a domain as a particular instance of a topology.\nAlso, we define an eligible domain as a domain whose nodes meet the requirements of\nnodeAffinityPolicy and nodeTaintsPolicy.\ne.g. If TopologyKey is \"kubernetes.io/hostname\", each Node is a domain of that topology.\nAnd, if TopologyKey is \"topology.kubernetes.io/zone\", each zone is a domain of that topology.\nIt's a required field.";
          type = types.str;
        };
        "whenUnsatisfiable" = mkOption {
          description = "WhenUnsatisfiable indicates how to deal with a pod if it doesn't satisfy\nthe spread constraint.\n- DoNotSchedule (default) tells the scheduler not to schedule it.\n- ScheduleAnyway tells the scheduler to schedule the pod in any location,\n  but giving higher precedence to topologies that would help reduce the\n  skew.\nA constraint is considered \"Unsatisfiable\" for an incoming pod\nif and only if every possible node assignment for that pod would violate\n\"MaxSkew\" on some topology.\nFor example, in a 3-zone cluster, MaxSkew is set to 1, and pods with the same\nlabelSelector spread as 3/1/1:\n| zone1 | zone2 | zone3 |\n| P P P |   P   |   P   |\nIf WhenUnsatisfiable is set to DoNotSchedule, incoming pod can only be scheduled\nto zone2(zone3) to become 3/2/1(3/1/2) as ActualSkew(2-1) on zone2(zone3) satisfies\nMaxSkew(1). In other words, the cluster can still be imbalanced, but scheduler\nwon't make it *more* imbalanced.\nIt's a required field.";
          type = types.str;
        };
      };

      config = {
        "labelSelector" = mkOverride 1002 null;
        "matchLabelKeys" = mkOverride 1002 null;
        "minDomains" = mkOverride 1002 null;
        "nodeAffinityPolicy" = mkOverride 1002 null;
        "nodeTaintsPolicy" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecTopologySpreadConstraintsLabelSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecTopologySpreadConstraintsLabelSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels\nmap is equivalent to an element of matchExpressions, whose key field is \"key\", the\noperator is \"In\", and the values array contains only \"value\". The requirements are ANDed.";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecTopologySpreadConstraintsLabelSelectorMatchExpressions" = {

      options = {
        "key" = mkOption {
          description = "key is the label key that the selector applies to.";
          type = types.str;
        };
        "operator" = mkOption {
          description = "operator represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists and DoesNotExist.";
          type = types.str;
        };
        "values" = mkOption {
          description = "values is an array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. This array is replaced during a strategic\nmerge patch.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "values" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecWalStorage" = {

      options = {
        "pvcTemplate" = mkOption {
          description = "Template to be used to generate the Persistent Volume Claim";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecWalStoragePvcTemplate"));
        };
        "resizeInUseVolumes" = mkOption {
          description = "Resize existent PVCs, defaults to true";
          type = (types.nullOr types.bool);
        };
        "size" = mkOption {
          description = "Size of the storage. Required if not already specified in the PVC template.\nChanges to this field are automatically reapplied to the created PVCs.\nSize cannot be decreased.";
          type = (types.nullOr types.str);
        };
        "storageClass" = mkOption {
          description = "StorageClass to use for PVCs. Applied after\nevaluating the PVC template, if available.\nIf not specified, the generated PVCs will use the\ndefault storage class";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "pvcTemplate" = mkOverride 1002 null;
        "resizeInUseVolumes" = mkOverride 1002 null;
        "size" = mkOverride 1002 null;
        "storageClass" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecWalStoragePvcTemplate" = {

      options = {
        "accessModes" = mkOption {
          description = "accessModes contains the desired access modes the volume should have.\nMore info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes-1";
          type = (types.nullOr (types.listOf types.str));
        };
        "dataSource" = mkOption {
          description = "dataSource field can be used to specify either:\n* An existing VolumeSnapshot object (snapshot.storage.k8s.io/VolumeSnapshot)\n* An existing PVC (PersistentVolumeClaim)\nIf the provisioner or an external controller can support the specified data source,\nit will create a new volume based on the contents of the specified data source.\nWhen the AnyVolumeDataSource feature gate is enabled, dataSource contents will be copied to dataSourceRef,\nand dataSourceRef contents will be copied to dataSource when dataSourceRef.namespace is not specified.\nIf the namespace is specified, then dataSourceRef will not be copied to dataSource.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecWalStoragePvcTemplateDataSource")
          );
        };
        "dataSourceRef" = mkOption {
          description = "dataSourceRef specifies the object from which to populate the volume with data, if a non-empty\nvolume is desired. This may be any object from a non-empty API group (non\ncore object) or a PersistentVolumeClaim object.\nWhen this field is specified, volume binding will only succeed if the type of\nthe specified object matches some installed volume populator or dynamic\nprovisioner.\nThis field will replace the functionality of the dataSource field and as such\nif both fields are non-empty, they must have the same value. For backwards\ncompatibility, when namespace isn't specified in dataSourceRef,\nboth fields (dataSource and dataSourceRef) will be set to the same\nvalue automatically if one of them is empty and the other is non-empty.\nWhen namespace is specified in dataSourceRef,\ndataSource isn't set to the same value and must be empty.\nThere are three important differences between dataSource and dataSourceRef:\n* While dataSource only allows two specific types of objects, dataSourceRef\n  allows any non-core object, as well as PersistentVolumeClaim objects.\n* While dataSource ignores disallowed values (dropping them), dataSourceRef\n  preserves all values, and generates an error if a disallowed value is\n  specified.\n* While dataSource only allows local objects, dataSourceRef allows objects\n  in any namespaces.\n(Beta) Using this field requires the AnyVolumeDataSource feature gate to be enabled.\n(Alpha) Using the namespace field of dataSourceRef requires the CrossNamespaceVolumeDataSource feature gate to be enabled.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecWalStoragePvcTemplateDataSourceRef")
          );
        };
        "resources" = mkOption {
          description = "resources represents the minimum resources the volume should have.\nIf RecoverVolumeExpansionFailure feature is enabled users are allowed to specify resource requirements\nthat are lower than previous value but must still be higher than capacity recorded in the\nstatus field of the claim.\nMore info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#resources";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecWalStoragePvcTemplateResources")
          );
        };
        "selector" = mkOption {
          description = "selector is a label query over volumes to consider for binding.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterSpecWalStoragePvcTemplateSelector")
          );
        };
        "storageClassName" = mkOption {
          description = "storageClassName is the name of the StorageClass required by the claim.\nMore info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#class-1";
          type = (types.nullOr types.str);
        };
        "volumeAttributesClassName" = mkOption {
          description = "volumeAttributesClassName may be used to set the VolumeAttributesClass used by this claim.\nIf specified, the CSI driver will create or update the volume with the attributes defined\nin the corresponding VolumeAttributesClass. This has a different purpose than storageClassName,\nit can be changed after the claim is created. An empty string or nil value indicates that no\nVolumeAttributesClass will be applied to the claim. If the claim enters an Infeasible error state,\nthis field can be reset to its previous value (including nil) to cancel the modification.\nIf the resource referred to by volumeAttributesClass does not exist, this PersistentVolumeClaim will be\nset to a Pending state, as reflected by the modifyVolumeStatus field, until such as a resource\nexists.\nMore info: https://kubernetes.io/docs/concepts/storage/volume-attributes-classes/";
          type = (types.nullOr types.str);
        };
        "volumeMode" = mkOption {
          description = "volumeMode defines what type of volume is required by the claim.\nValue of Filesystem is implied when not included in claim spec.";
          type = (types.nullOr types.str);
        };
        "volumeName" = mkOption {
          description = "volumeName is the binding reference to the PersistentVolume backing this claim.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "accessModes" = mkOverride 1002 null;
        "dataSource" = mkOverride 1002 null;
        "dataSourceRef" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "selector" = mkOverride 1002 null;
        "storageClassName" = mkOverride 1002 null;
        "volumeAttributesClassName" = mkOverride 1002 null;
        "volumeMode" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecWalStoragePvcTemplateDataSource" = {

      options = {
        "apiGroup" = mkOption {
          description = "APIGroup is the group for the resource being referenced.\nIf APIGroup is not specified, the specified Kind must be in the core API group.\nFor any other third-party types, APIGroup is required.";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "Kind is the type of resource being referenced";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name is the name of resource being referenced";
          type = types.str;
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecWalStoragePvcTemplateDataSourceRef" = {

      options = {
        "apiGroup" = mkOption {
          description = "APIGroup is the group for the resource being referenced.\nIf APIGroup is not specified, the specified Kind must be in the core API group.\nFor any other third-party types, APIGroup is required.";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "Kind is the type of resource being referenced";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name is the name of resource being referenced";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "Namespace is the namespace of resource being referenced\nNote that when a namespace is specified, a gateway.networking.k8s.io/ReferenceGrant object is required in the referent namespace to allow that namespace's owner to accept the reference. See the ReferenceGrant documentation for details.\n(Alpha) This field requires the CrossNamespaceVolumeDataSource feature gate to be enabled.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "apiGroup" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecWalStoragePvcTemplateResources" = {

      options = {
        "limits" = mkOption {
          description = "Limits describes the maximum amount of compute resources allowed.\nMore info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "requests" = mkOption {
          description = "Requests describes the minimum amount of compute resources required.\nIf Requests is omitted for a container, it defaults to Limits if that is explicitly specified,\notherwise to an implementation-defined value. Requests cannot exceed Limits.\nMore info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
      };

      config = {
        "limits" = mkOverride 1002 null;
        "requests" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecWalStoragePvcTemplateSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.ClusterSpecWalStoragePvcTemplateSelectorMatchExpressions"
              )
            )
          );
        };
        "matchLabels" = mkOption {
          description = "matchLabels is a map of {key,value} pairs. A single {key,value} in the matchLabels\nmap is equivalent to an element of matchExpressions, whose key field is \"key\", the\noperator is \"In\", and the values array contains only \"value\". The requirements are ANDed.";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "matchExpressions" = mkOverride 1002 null;
        "matchLabels" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterSpecWalStoragePvcTemplateSelectorMatchExpressions" = {

      options = {
        "key" = mkOption {
          description = "key is the label key that the selector applies to.";
          type = types.str;
        };
        "operator" = mkOption {
          description = "operator represents a key's relationship to a set of values.\nValid operators are In, NotIn, Exists and DoesNotExist.";
          type = types.str;
        };
        "values" = mkOption {
          description = "values is an array of string values. If the operator is In or NotIn,\nthe values array must be non-empty. If the operator is Exists or DoesNotExist,\nthe values array must be empty. This array is replaced during a strategic\nmerge patch.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "values" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterStatus" = {

      options = {
        "availableArchitectures" = mkOption {
          description = "AvailableArchitectures reports the available architectures of a cluster";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.ClusterStatusAvailableArchitectures")
            )
          );
        };
        "certificates" = mkOption {
          description = "The configuration for the CA and related certificates, initialized with defaults.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterStatusCertificates"));
        };
        "cloudNativePGCommitHash" = mkOption {
          description = "The commit hash number of which this operator running";
          type = (types.nullOr types.str);
        };
        "cloudNativePGOperatorHash" = mkOption {
          description = "The hash of the binary of the operator";
          type = (types.nullOr types.str);
        };
        "conditions" = mkOption {
          description = "Conditions for cluster object";
          type = (types.nullOr (types.listOf (submoduleOf "postgresql.cnpg.io.v1.ClusterStatusConditions")));
        };
        "configMapResourceVersion" = mkOption {
          description = "The list of resource versions of the configmaps,\nmanaged by the operator. Every change here is done in the\ninterest of the instance manager, which will refresh the\nconfigmap data";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterStatusConfigMapResourceVersion"));
        };
        "currentPrimary" = mkOption {
          description = "Current primary instance";
          type = (types.nullOr types.str);
        };
        "currentPrimaryFailingSinceTimestamp" = mkOption {
          description = "The timestamp when the primary was detected to be unhealthy\nThis field is reported when `.spec.failoverDelay` is populated or during online upgrades";
          type = (types.nullOr types.str);
        };
        "currentPrimaryTimestamp" = mkOption {
          description = "The timestamp when the last actual promotion to primary has occurred";
          type = (types.nullOr types.str);
        };
        "danglingPVC" = mkOption {
          description = "List of all the PVCs created by this cluster and still available\nwhich are not attached to a Pod";
          type = (types.nullOr (types.listOf types.str));
        };
        "demotionToken" = mkOption {
          description = "DemotionToken is a JSON token containing the information\nfrom pg_controldata such as Database system identifier, Latest checkpoint's\nTimeLineID, Latest checkpoint's REDO location, Latest checkpoint's REDO\nWAL file, and Time of latest checkpoint";
          type = (types.nullOr types.str);
        };
        "firstRecoverabilityPoint" = mkOption {
          description = "The first recoverability point, stored as a date in RFC3339 format.\nThis field is calculated from the content of FirstRecoverabilityPointByMethod.\n\nDeprecated: the field is not set for backup plugins.";
          type = (types.nullOr types.str);
        };
        "firstRecoverabilityPointByMethod" = mkOption {
          description = "The first recoverability point, stored as a date in RFC3339 format, per backup method type.\n\nDeprecated: the field is not set for backup plugins.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "healthyPVC" = mkOption {
          description = "List of all the PVCs not dangling nor initializing";
          type = (types.nullOr (types.listOf types.str));
        };
        "image" = mkOption {
          description = "Image contains the image name used by the pods";
          type = (types.nullOr types.str);
        };
        "initializingPVC" = mkOption {
          description = "List of all the PVCs that are being initialized by this cluster";
          type = (types.nullOr (types.listOf types.str));
        };
        "instanceNames" = mkOption {
          description = "List of instance names in the cluster";
          type = (types.nullOr (types.listOf types.str));
        };
        "instances" = mkOption {
          description = "The total number of PVC Groups detected in the cluster. It may differ from the number of existing instance pods.";
          type = (types.nullOr types.int);
        };
        "instancesReportedState" = mkOption {
          description = "The reported state of the instances during the last reconciliation loop";
          type = (types.nullOr (types.attrsOf types.attrs));
        };
        "instancesStatus" = mkOption {
          description = "InstancesStatus indicates in which status the instances are";
          type = (types.nullOr (types.loaOf types.str));
        };
        "jobCount" = mkOption {
          description = "How many Jobs have been created by this cluster";
          type = (types.nullOr types.int);
        };
        "lastFailedBackup" = mkOption {
          description = "Last failed backup, stored as a date in RFC3339 format.\n\nDeprecated: the field is not set for backup plugins.";
          type = (types.nullOr types.str);
        };
        "lastPromotionToken" = mkOption {
          description = "LastPromotionToken is the last verified promotion token that\nwas used to promote a replica cluster";
          type = (types.nullOr types.str);
        };
        "lastSuccessfulBackup" = mkOption {
          description = "Last successful backup, stored as a date in RFC3339 format.\nThis field is calculated from the content of LastSuccessfulBackupByMethod.\n\nDeprecated: the field is not set for backup plugins.";
          type = (types.nullOr types.str);
        };
        "lastSuccessfulBackupByMethod" = mkOption {
          description = "Last successful backup, stored as a date in RFC3339 format, per backup method type.\n\nDeprecated: the field is not set for backup plugins.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "latestGeneratedNode" = mkOption {
          description = "ID of the latest generated node (used to avoid node name clashing)";
          type = (types.nullOr types.int);
        };
        "managedRolesStatus" = mkOption {
          description = "ManagedRolesStatus reports the state of the managed roles in the cluster";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterStatusManagedRolesStatus"));
        };
        "onlineUpdateEnabled" = mkOption {
          description = "OnlineUpdateEnabled shows if the online upgrade is enabled inside the cluster";
          type = (types.nullOr types.bool);
        };
        "pgDataImageInfo" = mkOption {
          description = "PGDataImageInfo contains the details of the latest image that has run on the current data directory.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterStatusPgDataImageInfo"));
        };
        "phase" = mkOption {
          description = "Current phase of the cluster";
          type = (types.nullOr types.str);
        };
        "phaseReason" = mkOption {
          description = "Reason for the current phase";
          type = (types.nullOr types.str);
        };
        "pluginStatus" = mkOption {
          description = "PluginStatus is the status of the loaded plugins";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.ClusterStatusPluginStatus" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "poolerIntegrations" = mkOption {
          description = "The integration needed by poolers referencing the cluster";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterStatusPoolerIntegrations"));
        };
        "pvcCount" = mkOption {
          description = "How many PVCs have been created by this cluster";
          type = (types.nullOr types.int);
        };
        "readService" = mkOption {
          description = "Current list of read pods";
          type = (types.nullOr types.str);
        };
        "readyInstances" = mkOption {
          description = "The total number of ready instances in the cluster. It is equal to the number of ready instance pods.";
          type = (types.nullOr types.int);
        };
        "resizingPVC" = mkOption {
          description = "List of all the PVCs that have ResizingPVC condition.";
          type = (types.nullOr (types.listOf types.str));
        };
        "secretsResourceVersion" = mkOption {
          description = "The list of resource versions of the secrets\nmanaged by the operator. Every change here is done in the\ninterest of the instance manager, which will refresh the\nsecret data";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterStatusSecretsResourceVersion"));
        };
        "switchReplicaClusterStatus" = mkOption {
          description = "SwitchReplicaClusterStatus is the status of the switch to replica cluster";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterStatusSwitchReplicaClusterStatus"));
        };
        "systemID" = mkOption {
          description = "SystemID is the latest detected PostgreSQL SystemID";
          type = (types.nullOr types.str);
        };
        "tablespacesStatus" = mkOption {
          description = "TablespacesStatus reports the state of the declarative tablespaces in the cluster";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.ClusterStatusTablespacesStatus" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "targetPrimary" = mkOption {
          description = "Target primary instance, this is different from the previous one\nduring a switchover or a failover";
          type = (types.nullOr types.str);
        };
        "targetPrimaryTimestamp" = mkOption {
          description = "The timestamp when the last request for a new primary has occurred";
          type = (types.nullOr types.str);
        };
        "timelineID" = mkOption {
          description = "The timeline of the Postgres cluster";
          type = (types.nullOr types.int);
        };
        "topology" = mkOption {
          description = "Instances topology.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ClusterStatusTopology"));
        };
        "unusablePVC" = mkOption {
          description = "List of all the PVCs that are unusable because another PVC is missing";
          type = (types.nullOr (types.listOf types.str));
        };
        "writeService" = mkOption {
          description = "Current write pod";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "availableArchitectures" = mkOverride 1002 null;
        "certificates" = mkOverride 1002 null;
        "cloudNativePGCommitHash" = mkOverride 1002 null;
        "cloudNativePGOperatorHash" = mkOverride 1002 null;
        "conditions" = mkOverride 1002 null;
        "configMapResourceVersion" = mkOverride 1002 null;
        "currentPrimary" = mkOverride 1002 null;
        "currentPrimaryFailingSinceTimestamp" = mkOverride 1002 null;
        "currentPrimaryTimestamp" = mkOverride 1002 null;
        "danglingPVC" = mkOverride 1002 null;
        "demotionToken" = mkOverride 1002 null;
        "firstRecoverabilityPoint" = mkOverride 1002 null;
        "firstRecoverabilityPointByMethod" = mkOverride 1002 null;
        "healthyPVC" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "initializingPVC" = mkOverride 1002 null;
        "instanceNames" = mkOverride 1002 null;
        "instances" = mkOverride 1002 null;
        "instancesReportedState" = mkOverride 1002 null;
        "instancesStatus" = mkOverride 1002 null;
        "jobCount" = mkOverride 1002 null;
        "lastFailedBackup" = mkOverride 1002 null;
        "lastPromotionToken" = mkOverride 1002 null;
        "lastSuccessfulBackup" = mkOverride 1002 null;
        "lastSuccessfulBackupByMethod" = mkOverride 1002 null;
        "latestGeneratedNode" = mkOverride 1002 null;
        "managedRolesStatus" = mkOverride 1002 null;
        "onlineUpdateEnabled" = mkOverride 1002 null;
        "pgDataImageInfo" = mkOverride 1002 null;
        "phase" = mkOverride 1002 null;
        "phaseReason" = mkOverride 1002 null;
        "pluginStatus" = mkOverride 1002 null;
        "poolerIntegrations" = mkOverride 1002 null;
        "pvcCount" = mkOverride 1002 null;
        "readService" = mkOverride 1002 null;
        "readyInstances" = mkOverride 1002 null;
        "resizingPVC" = mkOverride 1002 null;
        "secretsResourceVersion" = mkOverride 1002 null;
        "switchReplicaClusterStatus" = mkOverride 1002 null;
        "systemID" = mkOverride 1002 null;
        "tablespacesStatus" = mkOverride 1002 null;
        "targetPrimary" = mkOverride 1002 null;
        "targetPrimaryTimestamp" = mkOverride 1002 null;
        "timelineID" = mkOverride 1002 null;
        "topology" = mkOverride 1002 null;
        "unusablePVC" = mkOverride 1002 null;
        "writeService" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterStatusAvailableArchitectures" = {

      options = {
        "goArch" = mkOption {
          description = "GoArch is the name of the executable architecture";
          type = types.str;
        };
        "hash" = mkOption {
          description = "Hash is the hash of the executable";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterStatusCertificates" = {

      options = {
        "clientCASecret" = mkOption {
          description = "The secret containing the Client CA certificate. If not defined, a new secret will be created\nwith a self-signed CA and will be used to generate all the client certificates.<br />\n<br />\nContains:<br />\n<br />\n- `ca.crt`: CA that should be used to validate the client certificates,\nused as `ssl_ca_file` of all the instances.<br />\n- `ca.key`: key used to generate client certificates, if ReplicationTLSSecret is provided,\nthis can be omitted.<br />";
          type = (types.nullOr types.str);
        };
        "expirations" = mkOption {
          description = "Expiration dates for all certificates.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "replicationTLSSecret" = mkOption {
          description = "The secret of type kubernetes.io/tls containing the client certificate to authenticate as\nthe `streaming_replica` user.\nIf not defined, ClientCASecret must provide also `ca.key`, and a new secret will be\ncreated using the provided CA.";
          type = (types.nullOr types.str);
        };
        "serverAltDNSNames" = mkOption {
          description = "The list of the server alternative DNS names to be added to the generated server TLS certificates, when required.";
          type = (types.nullOr (types.listOf types.str));
        };
        "serverCASecret" = mkOption {
          description = "The secret containing the Server CA certificate. If not defined, a new secret will be created\nwith a self-signed CA and will be used to generate the TLS certificate ServerTLSSecret.<br />\n<br />\nContains:<br />\n<br />\n- `ca.crt`: CA that should be used to validate the server certificate,\nused as `sslrootcert` in client connection strings.<br />\n- `ca.key`: key used to generate Server SSL certs, if ServerTLSSecret is provided,\nthis can be omitted.<br />";
          type = (types.nullOr types.str);
        };
        "serverTLSSecret" = mkOption {
          description = "The secret of type kubernetes.io/tls containing the server TLS certificate and key that will be set as\n`ssl_cert_file` and `ssl_key_file` so that clients can connect to postgres securely.\nIf not defined, ServerCASecret must provide also `ca.key` and a new secret will be\ncreated using the provided CA.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "clientCASecret" = mkOverride 1002 null;
        "expirations" = mkOverride 1002 null;
        "replicationTLSSecret" = mkOverride 1002 null;
        "serverAltDNSNames" = mkOverride 1002 null;
        "serverCASecret" = mkOverride 1002 null;
        "serverTLSSecret" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterStatusConditions" = {

      options = {
        "lastTransitionTime" = mkOption {
          description = "lastTransitionTime is the last time the condition transitioned from one status to another.\nThis should be when the underlying condition changed.  If that is not known, then using the time when the API field changed is acceptable.";
          type = types.str;
        };
        "message" = mkOption {
          description = "message is a human readable message indicating details about the transition.\nThis may be an empty string.";
          type = types.str;
        };
        "observedGeneration" = mkOption {
          description = "observedGeneration represents the .metadata.generation that the condition was set based upon.\nFor instance, if .metadata.generation is currently 12, but the .status.conditions[x].observedGeneration is 9, the condition is out of date\nwith respect to the current state of the instance.";
          type = (types.nullOr types.int);
        };
        "reason" = mkOption {
          description = "reason contains a programmatic identifier indicating the reason for the condition's last transition.\nProducers of specific condition types may define expected values and meanings for this field,\nand whether the values are considered a guaranteed API.\nThe value should be a CamelCase string.\nThis field may not be empty.";
          type = types.str;
        };
        "status" = mkOption {
          description = "status of the condition, one of True, False, Unknown.";
          type = types.str;
        };
        "type" = mkOption {
          description = "type of condition in CamelCase or in foo.example.com/CamelCase.";
          type = types.str;
        };
      };

      config = {
        "observedGeneration" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterStatusConfigMapResourceVersion" = {

      options = {
        "metrics" = mkOption {
          description = "A map with the versions of all the config maps used to pass metrics.\nMap keys are the config map names, map values are the versions";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "metrics" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterStatusManagedRolesStatus" = {

      options = {
        "byStatus" = mkOption {
          description = "ByStatus gives the list of roles in each state";
          type = (types.nullOr (types.loaOf types.str));
        };
        "cannotReconcile" = mkOption {
          description = "CannotReconcile lists roles that cannot be reconciled in PostgreSQL,\nwith an explanation of the cause";
          type = (types.nullOr (types.loaOf types.str));
        };
        "passwordStatus" = mkOption {
          description = "PasswordStatus gives the last transaction id and password secret version for each managed role";
          type = (types.nullOr (types.attrsOf types.attrs));
        };
      };

      config = {
        "byStatus" = mkOverride 1002 null;
        "cannotReconcile" = mkOverride 1002 null;
        "passwordStatus" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterStatusPgDataImageInfo" = {

      options = {
        "image" = mkOption {
          description = "Image is the image name";
          type = types.str;
        };
        "majorVersion" = mkOption {
          description = "MajorVersion is the major version of the image";
          type = types.int;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterStatusPluginStatus" = {

      options = {
        "backupCapabilities" = mkOption {
          description = "BackupCapabilities are the list of capabilities of the\nplugin regarding the Backup management";
          type = (types.nullOr (types.listOf types.str));
        };
        "capabilities" = mkOption {
          description = "Capabilities are the list of capabilities of the\nplugin";
          type = (types.nullOr (types.listOf types.str));
        };
        "name" = mkOption {
          description = "Name is the name of the plugin";
          type = types.str;
        };
        "operatorCapabilities" = mkOption {
          description = "OperatorCapabilities are the list of capabilities of the\nplugin regarding the reconciler";
          type = (types.nullOr (types.listOf types.str));
        };
        "restoreJobHookCapabilities" = mkOption {
          description = "RestoreJobHookCapabilities are the list of capabilities of the\nplugin regarding the RestoreJobHook management";
          type = (types.nullOr (types.listOf types.str));
        };
        "status" = mkOption {
          description = "Status contain the status reported by the plugin through the SetStatusInCluster interface";
          type = (types.nullOr types.str);
        };
        "version" = mkOption {
          description = "Version is the version of the plugin loaded by the\nlatest reconciliation loop";
          type = types.str;
        };
        "walCapabilities" = mkOption {
          description = "WALCapabilities are the list of capabilities of the\nplugin regarding the WAL management";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "backupCapabilities" = mkOverride 1002 null;
        "capabilities" = mkOverride 1002 null;
        "operatorCapabilities" = mkOverride 1002 null;
        "restoreJobHookCapabilities" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
        "walCapabilities" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterStatusPoolerIntegrations" = {

      options = {
        "pgBouncerIntegration" = mkOption {
          description = "PgBouncerIntegrationStatus encapsulates the needed integration for the pgbouncer poolers referencing the cluster";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.ClusterStatusPoolerIntegrationsPgBouncerIntegration"
            )
          );
        };
      };

      config = {
        "pgBouncerIntegration" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterStatusPoolerIntegrationsPgBouncerIntegration" = {

      options = {
        "secrets" = mkOption {
          description = "";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "secrets" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterStatusSecretsResourceVersion" = {

      options = {
        "applicationSecretVersion" = mkOption {
          description = "The resource version of the \"app\" user secret";
          type = (types.nullOr types.str);
        };
        "barmanEndpointCA" = mkOption {
          description = "The resource version of the Barman Endpoint CA if provided";
          type = (types.nullOr types.str);
        };
        "caSecretVersion" = mkOption {
          description = "Unused. Retained for compatibility with old versions.";
          type = (types.nullOr types.str);
        };
        "clientCaSecretVersion" = mkOption {
          description = "The resource version of the PostgreSQL client-side CA secret version";
          type = (types.nullOr types.str);
        };
        "externalClusterSecretVersion" = mkOption {
          description = "The resource versions of the external cluster secrets";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "managedRoleSecretVersion" = mkOption {
          description = "The resource versions of the managed roles secrets";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "metrics" = mkOption {
          description = "A map with the versions of all the secrets used to pass metrics.\nMap keys are the secret names, map values are the versions";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "replicationSecretVersion" = mkOption {
          description = "The resource version of the \"streaming_replica\" user secret";
          type = (types.nullOr types.str);
        };
        "serverCaSecretVersion" = mkOption {
          description = "The resource version of the PostgreSQL server-side CA secret version";
          type = (types.nullOr types.str);
        };
        "serverSecretVersion" = mkOption {
          description = "The resource version of the PostgreSQL server-side secret version";
          type = (types.nullOr types.str);
        };
        "superuserSecretVersion" = mkOption {
          description = "The resource version of the \"postgres\" user secret";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "applicationSecretVersion" = mkOverride 1002 null;
        "barmanEndpointCA" = mkOverride 1002 null;
        "caSecretVersion" = mkOverride 1002 null;
        "clientCaSecretVersion" = mkOverride 1002 null;
        "externalClusterSecretVersion" = mkOverride 1002 null;
        "managedRoleSecretVersion" = mkOverride 1002 null;
        "metrics" = mkOverride 1002 null;
        "replicationSecretVersion" = mkOverride 1002 null;
        "serverCaSecretVersion" = mkOverride 1002 null;
        "serverSecretVersion" = mkOverride 1002 null;
        "superuserSecretVersion" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterStatusSwitchReplicaClusterStatus" = {

      options = {
        "inProgress" = mkOption {
          description = "InProgress indicates if there is an ongoing procedure of switching a cluster to a replica cluster.";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "inProgress" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterStatusTablespacesStatus" = {

      options = {
        "error" = mkOption {
          description = "Error is the reconciliation error, if any";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "Name is the name of the tablespace";
          type = types.str;
        };
        "owner" = mkOption {
          description = "Owner is the PostgreSQL user owning the tablespace";
          type = (types.nullOr types.str);
        };
        "state" = mkOption {
          description = "State is the latest reconciliation state";
          type = types.str;
        };
      };

      config = {
        "error" = mkOverride 1002 null;
        "owner" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterStatusTopology" = {

      options = {
        "instances" = mkOption {
          description = "Instances contains the pod topology of the instances";
          type = (types.nullOr (types.attrsOf types.attrs));
        };
        "nodesUsed" = mkOption {
          description = "NodesUsed represents the count of distinct nodes accommodating the instances.\nA value of '1' suggests that all instances are hosted on a single node,\nimplying the absence of High Availability (HA). Ideally, this value should\nbe the same as the number of instances in the Postgres HA cluster, implying\nshared nothing architecture on the compute side.";
          type = (types.nullOr types.int);
        };
        "successfullyExtracted" = mkOption {
          description = "SuccessfullyExtracted indicates if the topology data was extract. It is useful to enact fallback behaviors\nin synchronous replica election in case of failures";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "instances" = mkOverride 1002 null;
        "nodesUsed" = mkOverride 1002 null;
        "successfullyExtracted" = mkOverride 1002 null;
      };

    };

  };
in
{
  # all resource versions
  options = {
    resources = {
      "postgresql.cnpg.io"."v1"."Cluster" = mkOption {
        description = "Cluster defines the API schema for a highly available PostgreSQL database cluster\nmanaged by CloudNativePG.";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.Cluster" "clusters" "Cluster" "postgresql.cnpg.io"
              "v1"
          )
        );
        default = { };
      };

    }
    // {
      "clusters" = mkOption {
        description = "Cluster defines the API schema for a highly available PostgreSQL database cluster\nmanaged by CloudNativePG.";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.Cluster" "clusters" "Cluster" "postgresql.cnpg.io"
              "v1"
          )
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
        name = "clusters";
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "Cluster";
        attrName = "clusters";
      }
    ];

    resources = {
      "postgresql.cnpg.io"."v1"."Cluster" = mkAliasDefinitions options.resources."clusters";

    };

    # make all namespaced resources default to the
    # application's namespace
    defaults = [
      {
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "Cluster";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
    ];
  };
}
