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
    "postgresql.cnpg.io.v1.Backup" = {

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
          description = "Specification of the desired behavior of the backup.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status";
          type = (submoduleOf "postgresql.cnpg.io.v1.BackupSpec");
        };
        "status" = mkOption {
          description = "Most recently observed status of the backup. This data may not be up to\ndate. Populated by the system. Read-only.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.BackupSpec" = {

      options = {
        "cluster" = mkOption {
          description = "The cluster to backup";
          type = (submoduleOf "postgresql.cnpg.io.v1.BackupSpecCluster");
        };
        "method" = mkOption {
          description = "The backup method to be used, possible options are `barmanObjectStore`,\n`volumeSnapshot` or `plugin`. Defaults to: `barmanObjectStore`.";
          type = (types.nullOr types.str);
        };
        "online" = mkOption {
          description = "Whether the default type of backup with volume snapshots is\nonline/hot (`true`, default) or offline/cold (`false`)\nOverrides the default setting specified in the cluster field '.spec.backup.volumeSnapshot.online'";
          type = (types.nullOr types.bool);
        };
        "onlineConfiguration" = mkOption {
          description = "Configuration parameters to control the online/hot backup with volume snapshots\nOverrides the default settings specified in the cluster '.backup.volumeSnapshot.onlineConfiguration' stanza";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupSpecOnlineConfiguration"));
        };
        "pluginConfiguration" = mkOption {
          description = "Configuration parameters passed to the plugin managing this backup";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupSpecPluginConfiguration"));
        };
        "target" = mkOption {
          description = "The policy to decide which instance should perform this backup. If empty,\nit defaults to `cluster.spec.backup.target`.\nAvailable options are empty string, `primary` and `prefer-standby`.\n`primary` to have backups run always on primary instances,\n`prefer-standby` to have backups run preferably on the most updated\nstandby, if available.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "method" = mkOverride 1002 null;
        "online" = mkOverride 1002 null;
        "onlineConfiguration" = mkOverride 1002 null;
        "pluginConfiguration" = mkOverride 1002 null;
        "target" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.BackupSpecCluster" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.BackupSpecOnlineConfiguration" = {

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
    "postgresql.cnpg.io.v1.BackupSpecPluginConfiguration" = {

      options = {
        "name" = mkOption {
          description = "Name is the name of the plugin managing this backup";
          type = types.str;
        };
        "parameters" = mkOption {
          description = "Parameters are the configuration parameters passed to the backup\nplugin for this backup";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "parameters" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.BackupStatus" = {

      options = {
        "azureCredentials" = mkOption {
          description = "The credentials to use to upload data to Azure Blob Storage";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupStatusAzureCredentials"));
        };
        "backupId" = mkOption {
          description = "The ID of the Barman backup";
          type = (types.nullOr types.str);
        };
        "backupLabelFile" = mkOption {
          description = "Backup label file content as returned by Postgres in case of online (hot) backups";
          type = (types.nullOr types.str);
        };
        "backupName" = mkOption {
          description = "The Name of the Barman backup";
          type = (types.nullOr types.str);
        };
        "beginLSN" = mkOption {
          description = "The starting xlog";
          type = (types.nullOr types.str);
        };
        "beginWal" = mkOption {
          description = "The starting WAL";
          type = (types.nullOr types.str);
        };
        "commandError" = mkOption {
          description = "The backup command output in case of error";
          type = (types.nullOr types.str);
        };
        "commandOutput" = mkOption {
          description = "Unused. Retained for compatibility with old versions.";
          type = (types.nullOr types.str);
        };
        "destinationPath" = mkOption {
          description = "The path where to store the backup (i.e. s3://bucket/path/to/folder)\nthis path, with different destination folders, will be used for WALs\nand for data. This may not be populated in case of errors.";
          type = (types.nullOr types.str);
        };
        "encryption" = mkOption {
          description = "Encryption method required to S3 API";
          type = (types.nullOr types.str);
        };
        "endLSN" = mkOption {
          description = "The ending xlog";
          type = (types.nullOr types.str);
        };
        "endWal" = mkOption {
          description = "The ending WAL";
          type = (types.nullOr types.str);
        };
        "endpointCA" = mkOption {
          description = "EndpointCA store the CA bundle of the barman endpoint.\nUseful when using self-signed certificates to avoid\nerrors with certificate issuer and barman-cloud-wal-archive.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupStatusEndpointCA"));
        };
        "endpointURL" = mkOption {
          description = "Endpoint to be used to upload data to the cloud,\noverriding the automatic endpoint discovery";
          type = (types.nullOr types.str);
        };
        "error" = mkOption {
          description = "The detected error";
          type = (types.nullOr types.str);
        };
        "googleCredentials" = mkOption {
          description = "The credentials to use to upload data to Google Cloud Storage";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupStatusGoogleCredentials"));
        };
        "instanceID" = mkOption {
          description = "Information to identify the instance where the backup has been taken from";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupStatusInstanceID"));
        };
        "majorVersion" = mkOption {
          description = "The PostgreSQL major version that was running when the\nbackup was taken.";
          type = (types.nullOr types.int);
        };
        "method" = mkOption {
          description = "The backup method being used";
          type = (types.nullOr types.str);
        };
        "online" = mkOption {
          description = "Whether the backup was online/hot (`true`) or offline/cold (`false`)";
          type = (types.nullOr types.bool);
        };
        "phase" = mkOption {
          description = "The last backup status";
          type = (types.nullOr types.str);
        };
        "pluginMetadata" = mkOption {
          description = "A map containing the plugin metadata";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "s3Credentials" = mkOption {
          description = "The credentials to use to upload data to S3";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupStatusS3Credentials"));
        };
        "serverName" = mkOption {
          description = "The server name on S3, the cluster name is used if this\nparameter is omitted";
          type = (types.nullOr types.str);
        };
        "snapshotBackupStatus" = mkOption {
          description = "Status of the volumeSnapshot backup";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupStatusSnapshotBackupStatus"));
        };
        "startedAt" = mkOption {
          description = "When the backup was started";
          type = (types.nullOr types.str);
        };
        "stoppedAt" = mkOption {
          description = "When the backup was terminated";
          type = (types.nullOr types.str);
        };
        "tablespaceMapFile" = mkOption {
          description = "Tablespace map file content as returned by Postgres in case of online (hot) backups";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "azureCredentials" = mkOverride 1002 null;
        "backupId" = mkOverride 1002 null;
        "backupLabelFile" = mkOverride 1002 null;
        "backupName" = mkOverride 1002 null;
        "beginLSN" = mkOverride 1002 null;
        "beginWal" = mkOverride 1002 null;
        "commandError" = mkOverride 1002 null;
        "commandOutput" = mkOverride 1002 null;
        "destinationPath" = mkOverride 1002 null;
        "encryption" = mkOverride 1002 null;
        "endLSN" = mkOverride 1002 null;
        "endWal" = mkOverride 1002 null;
        "endpointCA" = mkOverride 1002 null;
        "endpointURL" = mkOverride 1002 null;
        "error" = mkOverride 1002 null;
        "googleCredentials" = mkOverride 1002 null;
        "instanceID" = mkOverride 1002 null;
        "majorVersion" = mkOverride 1002 null;
        "method" = mkOverride 1002 null;
        "online" = mkOverride 1002 null;
        "phase" = mkOverride 1002 null;
        "pluginMetadata" = mkOverride 1002 null;
        "s3Credentials" = mkOverride 1002 null;
        "serverName" = mkOverride 1002 null;
        "snapshotBackupStatus" = mkOverride 1002 null;
        "startedAt" = mkOverride 1002 null;
        "stoppedAt" = mkOverride 1002 null;
        "tablespaceMapFile" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.BackupStatusAzureCredentials" = {

      options = {
        "connectionString" = mkOption {
          description = "The connection string to be used";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupStatusAzureCredentialsConnectionString")
          );
        };
        "inheritFromAzureAD" = mkOption {
          description = "Use the Azure AD based authentication without providing explicitly the keys.";
          type = (types.nullOr types.bool);
        };
        "storageAccount" = mkOption {
          description = "The storage account where to upload data";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupStatusAzureCredentialsStorageAccount")
          );
        };
        "storageKey" = mkOption {
          description = "The storage account key to be used in conjunction\nwith the storage account name";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupStatusAzureCredentialsStorageKey"));
        };
        "storageSasToken" = mkOption {
          description = "A shared-access-signature to be used in conjunction with\nthe storage account name";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupStatusAzureCredentialsStorageSasToken")
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
    "postgresql.cnpg.io.v1.BackupStatusAzureCredentialsConnectionString" = {

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
    "postgresql.cnpg.io.v1.BackupStatusAzureCredentialsStorageAccount" = {

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
    "postgresql.cnpg.io.v1.BackupStatusAzureCredentialsStorageKey" = {

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
    "postgresql.cnpg.io.v1.BackupStatusAzureCredentialsStorageSasToken" = {

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
    "postgresql.cnpg.io.v1.BackupStatusEndpointCA" = {

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
    "postgresql.cnpg.io.v1.BackupStatusGoogleCredentials" = {

      options = {
        "applicationCredentials" = mkOption {
          description = "The secret containing the Google Cloud Storage JSON file with the credentials";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.BackupStatusGoogleCredentialsApplicationCredentials"
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
    "postgresql.cnpg.io.v1.BackupStatusGoogleCredentialsApplicationCredentials" = {

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
    "postgresql.cnpg.io.v1.BackupStatusInstanceID" = {

      options = {
        "ContainerID" = mkOption {
          description = "The container ID";
          type = (types.nullOr types.str);
        };
        "podName" = mkOption {
          description = "The pod name";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "ContainerID" = mkOverride 1002 null;
        "podName" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.BackupStatusS3Credentials" = {

      options = {
        "accessKeyId" = mkOption {
          description = "The reference to the access key id";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupStatusS3CredentialsAccessKeyId"));
        };
        "inheritFromIAMRole" = mkOption {
          description = "Use the role based authentication without providing explicitly the keys.";
          type = (types.nullOr types.bool);
        };
        "region" = mkOption {
          description = "The reference to the secret containing the region name";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupStatusS3CredentialsRegion"));
        };
        "secretAccessKey" = mkOption {
          description = "The reference to the secret access key";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupStatusS3CredentialsSecretAccessKey")
          );
        };
        "sessionToken" = mkOption {
          description = "The references to the session key";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.BackupStatusS3CredentialsSessionToken"));
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
    "postgresql.cnpg.io.v1.BackupStatusS3CredentialsAccessKeyId" = {

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
    "postgresql.cnpg.io.v1.BackupStatusS3CredentialsRegion" = {

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
    "postgresql.cnpg.io.v1.BackupStatusS3CredentialsSecretAccessKey" = {

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
    "postgresql.cnpg.io.v1.BackupStatusS3CredentialsSessionToken" = {

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
    "postgresql.cnpg.io.v1.BackupStatusSnapshotBackupStatus" = {

      options = {
        "elements" = mkOption {
          description = "The elements list, populated with the gathered volume snapshots";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.BackupStatusSnapshotBackupStatusElements"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
      };

      config = {
        "elements" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.BackupStatusSnapshotBackupStatusElements" = {

      options = {
        "name" = mkOption {
          description = "Name is the snapshot resource name";
          type = types.str;
        };
        "tablespaceName" = mkOption {
          description = "TablespaceName is the name of the snapshotted tablespace. Only set\nwhen type is PG_TABLESPACE";
          type = (types.nullOr types.str);
        };
        "type" = mkOption {
          description = "Type is tho role of the snapshot in the cluster, such as PG_DATA, PG_WAL and PG_TABLESPACE";
          type = types.str;
        };
      };

      config = {
        "tablespaceName" = mkOverride 1002 null;
      };

    };
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
    "postgresql.cnpg.io.v1.ClusterImageCatalog" = {

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
          description = "Specification of the desired behavior of the ClusterImageCatalog.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status";
          type = (submoduleOf "postgresql.cnpg.io.v1.ClusterImageCatalogSpec");
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ClusterImageCatalogSpec" = {

      options = {
        "images" = mkOption {
          description = "List of CatalogImages available in the catalog";
          type = (types.listOf (submoduleOf "postgresql.cnpg.io.v1.ClusterImageCatalogSpecImages"));
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ClusterImageCatalogSpecImages" = {

      options = {
        "image" = mkOption {
          description = "The image reference";
          type = types.str;
        };
        "major" = mkOption {
          description = "The PostgreSQL major version of the image. Must be unique within the catalog.";
          type = types.int;
        };
      };

      config = { };

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
    "postgresql.cnpg.io.v1.Database" = {

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
          description = "Specification of the desired Database.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status";
          type = (submoduleOf "postgresql.cnpg.io.v1.DatabaseSpec");
        };
        "status" = mkOption {
          description = "Most recently observed status of the Database. This data may not be up to\ndate. Populated by the system. Read-only.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.DatabaseStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.DatabaseSpec" = {

      options = {
        "allowConnections" = mkOption {
          description = "Maps to the `ALLOW_CONNECTIONS` parameter of `CREATE DATABASE` and\n`ALTER DATABASE`. If false then no one can connect to this database.";
          type = (types.nullOr types.bool);
        };
        "builtinLocale" = mkOption {
          description = "Maps to the `BUILTIN_LOCALE` parameter of `CREATE DATABASE`. This\nsetting cannot be changed. Specifies the locale name when the\nbuiltin provider is used. This option requires `localeProvider` to\nbe set to `builtin`. Available from PostgreSQL 17.";
          type = (types.nullOr types.str);
        };
        "cluster" = mkOption {
          description = "The name of the PostgreSQL cluster hosting the database.";
          type = (submoduleOf "postgresql.cnpg.io.v1.DatabaseSpecCluster");
        };
        "collationVersion" = mkOption {
          description = "Maps to the `COLLATION_VERSION` parameter of `CREATE DATABASE`. This\nsetting cannot be changed.";
          type = (types.nullOr types.str);
        };
        "connectionLimit" = mkOption {
          description = "Maps to the `CONNECTION LIMIT` clause of `CREATE DATABASE` and\n`ALTER DATABASE`. How many concurrent connections can be made to\nthis database. -1 (the default) means no limit.";
          type = (types.nullOr types.int);
        };
        "databaseReclaimPolicy" = mkOption {
          description = "The policy for end-of-life maintenance of this database.";
          type = (types.nullOr types.str);
        };
        "encoding" = mkOption {
          description = "Maps to the `ENCODING` parameter of `CREATE DATABASE`. This setting\ncannot be changed. Character set encoding to use in the database.";
          type = (types.nullOr types.str);
        };
        "ensure" = mkOption {
          description = "Ensure the PostgreSQL database is `present` or `absent` - defaults to \"present\".";
          type = (types.nullOr types.str);
        };
        "extensions" = mkOption {
          description = "The list of extensions to be managed in the database";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.DatabaseSpecExtensions" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "fdws" = mkOption {
          description = "The list of foreign data wrappers to be managed in the database";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.DatabaseSpecFdws" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "icuLocale" = mkOption {
          description = "Maps to the `ICU_LOCALE` parameter of `CREATE DATABASE`. This\nsetting cannot be changed. Specifies the ICU locale when the ICU\nprovider is used. This option requires `localeProvider` to be set to\n`icu`. Available from PostgreSQL 15.";
          type = (types.nullOr types.str);
        };
        "icuRules" = mkOption {
          description = "Maps to the `ICU_RULES` parameter of `CREATE DATABASE`. This setting\ncannot be changed. Specifies additional collation rules to customize\nthe behavior of the default collation. This option requires\n`localeProvider` to be set to `icu`. Available from PostgreSQL 16.";
          type = (types.nullOr types.str);
        };
        "isTemplate" = mkOption {
          description = "Maps to the `IS_TEMPLATE` parameter of `CREATE DATABASE` and `ALTER\nDATABASE`. If true, this database is considered a template and can\nbe cloned by any user with `CREATEDB` privileges.";
          type = (types.nullOr types.bool);
        };
        "locale" = mkOption {
          description = "Maps to the `LOCALE` parameter of `CREATE DATABASE`. This setting\ncannot be changed. Sets the default collation order and character\nclassification in the new database.";
          type = (types.nullOr types.str);
        };
        "localeCType" = mkOption {
          description = "Maps to the `LC_CTYPE` parameter of `CREATE DATABASE`. This setting\ncannot be changed.";
          type = (types.nullOr types.str);
        };
        "localeCollate" = mkOption {
          description = "Maps to the `LC_COLLATE` parameter of `CREATE DATABASE`. This\nsetting cannot be changed.";
          type = (types.nullOr types.str);
        };
        "localeProvider" = mkOption {
          description = "Maps to the `LOCALE_PROVIDER` parameter of `CREATE DATABASE`. This\nsetting cannot be changed. This option sets the locale provider for\ndatabases created in the new cluster. Available from PostgreSQL 16.";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "The name of the database to create inside PostgreSQL. This setting cannot be changed.";
          type = types.str;
        };
        "owner" = mkOption {
          description = "Maps to the `OWNER` parameter of `CREATE DATABASE`.\nMaps to the `OWNER TO` command of `ALTER DATABASE`.\nThe role name of the user who owns the database inside PostgreSQL.";
          type = types.str;
        };
        "schemas" = mkOption {
          description = "The list of schemas to be managed in the database";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.DatabaseSpecSchemas" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "servers" = mkOption {
          description = "The list of foreign servers to be managed in the database";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.DatabaseSpecServers" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "tablespace" = mkOption {
          description = "Maps to the `TABLESPACE` parameter of `CREATE DATABASE`.\nMaps to the `SET TABLESPACE` command of `ALTER DATABASE`.\nThe name of the tablespace (in PostgreSQL) that will be associated\nwith the new database. This tablespace will be the default\ntablespace used for objects created in this database.";
          type = (types.nullOr types.str);
        };
        "template" = mkOption {
          description = "Maps to the `TEMPLATE` parameter of `CREATE DATABASE`. This setting\ncannot be changed. The name of the template from which to create\nthis database.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "allowConnections" = mkOverride 1002 null;
        "builtinLocale" = mkOverride 1002 null;
        "collationVersion" = mkOverride 1002 null;
        "connectionLimit" = mkOverride 1002 null;
        "databaseReclaimPolicy" = mkOverride 1002 null;
        "encoding" = mkOverride 1002 null;
        "ensure" = mkOverride 1002 null;
        "extensions" = mkOverride 1002 null;
        "fdws" = mkOverride 1002 null;
        "icuLocale" = mkOverride 1002 null;
        "icuRules" = mkOverride 1002 null;
        "isTemplate" = mkOverride 1002 null;
        "locale" = mkOverride 1002 null;
        "localeCType" = mkOverride 1002 null;
        "localeCollate" = mkOverride 1002 null;
        "localeProvider" = mkOverride 1002 null;
        "schemas" = mkOverride 1002 null;
        "servers" = mkOverride 1002 null;
        "tablespace" = mkOverride 1002 null;
        "template" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.DatabaseSpecCluster" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.DatabaseSpecExtensions" = {

      options = {
        "ensure" = mkOption {
          description = "Specifies whether an object (e.g schema) should be present or absent\nin the database. If set to `present`, the object will be created if\nit does not exist. If set to `absent`, the extension/schema will be\nremoved if it exists.";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "Name of the object (extension, schema, FDW, server)";
          type = types.str;
        };
        "schema" = mkOption {
          description = "The name of the schema in which to install the extension's objects,\nin case the extension allows its contents to be relocated. If not\nspecified (default), and the extension's control file does not\nspecify a schema either, the current default object creation schema\nis used.";
          type = (types.nullOr types.str);
        };
        "version" = mkOption {
          description = "The version of the extension to install. If empty, the operator will\ninstall the default version (whatever is specified in the\nextension's control file)";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "ensure" = mkOverride 1002 null;
        "schema" = mkOverride 1002 null;
        "version" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.DatabaseSpecFdws" = {

      options = {
        "ensure" = mkOption {
          description = "Specifies whether an object (e.g schema) should be present or absent\nin the database. If set to `present`, the object will be created if\nit does not exist. If set to `absent`, the extension/schema will be\nremoved if it exists.";
          type = (types.nullOr types.str);
        };
        "handler" = mkOption {
          description = "Name of the handler function (e.g., \"postgres_fdw_handler\").\nThis will be empty if no handler is specified. In that case,\nthe default handler is registered when the FDW extension is created.";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "Name of the object (extension, schema, FDW, server)";
          type = types.str;
        };
        "options" = mkOption {
          description = "Options specifies the configuration options for the FDW.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.DatabaseSpecFdwsOptions" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "owner" = mkOption {
          description = "Owner specifies the database role that will own the Foreign Data Wrapper.\nThe role must have superuser privileges in the target database.";
          type = (types.nullOr types.str);
        };
        "usage" = mkOption {
          description = "List of roles for which `USAGE` privileges on the FDW are granted or revoked.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.DatabaseSpecFdwsUsage" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "validator" = mkOption {
          description = "Name of the validator function (e.g., \"postgres_fdw_validator\").\nThis will be empty if no validator is specified. In that case,\nthe default validator is registered when the FDW extension is created.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "ensure" = mkOverride 1002 null;
        "handler" = mkOverride 1002 null;
        "options" = mkOverride 1002 null;
        "owner" = mkOverride 1002 null;
        "usage" = mkOverride 1002 null;
        "validator" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.DatabaseSpecFdwsOptions" = {

      options = {
        "ensure" = mkOption {
          description = "Specifies whether an option should be present or absent in\nthe database. If set to `present`, the option will be\ncreated if it does not exist. If set to `absent`, the\noption will be removed if it exists.";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "Name of the option";
          type = types.str;
        };
        "value" = mkOption {
          description = "Value of the option";
          type = types.str;
        };
      };

      config = {
        "ensure" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.DatabaseSpecFdwsUsage" = {

      options = {
        "name" = mkOption {
          description = "Name of the usage";
          type = types.str;
        };
        "type" = mkOption {
          description = "The type of usage";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "type" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.DatabaseSpecSchemas" = {

      options = {
        "ensure" = mkOption {
          description = "Specifies whether an object (e.g schema) should be present or absent\nin the database. If set to `present`, the object will be created if\nit does not exist. If set to `absent`, the extension/schema will be\nremoved if it exists.";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "Name of the object (extension, schema, FDW, server)";
          type = types.str;
        };
        "owner" = mkOption {
          description = "The role name of the user who owns the schema inside PostgreSQL.\nIt maps to the `AUTHORIZATION` parameter of `CREATE SCHEMA` and the\n`OWNER TO` command of `ALTER SCHEMA`.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "ensure" = mkOverride 1002 null;
        "owner" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.DatabaseSpecServers" = {

      options = {
        "ensure" = mkOption {
          description = "Specifies whether an object (e.g schema) should be present or absent\nin the database. If set to `present`, the object will be created if\nit does not exist. If set to `absent`, the extension/schema will be\nremoved if it exists.";
          type = (types.nullOr types.str);
        };
        "fdw" = mkOption {
          description = "The name of the Foreign Data Wrapper (FDW)";
          type = types.str;
        };
        "name" = mkOption {
          description = "Name of the object (extension, schema, FDW, server)";
          type = types.str;
        };
        "options" = mkOption {
          description = "Options specifies the configuration options for the server\n(key is the option name, value is the option value).";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.DatabaseSpecServersOptions" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "usage" = mkOption {
          description = "List of roles for which `USAGE` privileges on the server are granted or revoked.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.DatabaseSpecServersUsage" "name" [ ]
            )
          );
          apply = attrsToList;
        };
      };

      config = {
        "ensure" = mkOverride 1002 null;
        "options" = mkOverride 1002 null;
        "usage" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.DatabaseSpecServersOptions" = {

      options = {
        "ensure" = mkOption {
          description = "Specifies whether an option should be present or absent in\nthe database. If set to `present`, the option will be\ncreated if it does not exist. If set to `absent`, the\noption will be removed if it exists.";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "Name of the option";
          type = types.str;
        };
        "value" = mkOption {
          description = "Value of the option";
          type = types.str;
        };
      };

      config = {
        "ensure" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.DatabaseSpecServersUsage" = {

      options = {
        "name" = mkOption {
          description = "Name of the usage";
          type = types.str;
        };
        "type" = mkOption {
          description = "The type of usage";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "type" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.DatabaseStatus" = {

      options = {
        "applied" = mkOption {
          description = "Applied is true if the database was reconciled correctly";
          type = (types.nullOr types.bool);
        };
        "extensions" = mkOption {
          description = "Extensions is the status of the managed extensions";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.DatabaseStatusExtensions" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "fdws" = mkOption {
          description = "FDWs is the status of the managed FDWs";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.DatabaseStatusFdws" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "message" = mkOption {
          description = "Message is the reconciliation output message";
          type = (types.nullOr types.str);
        };
        "observedGeneration" = mkOption {
          description = "A sequence number representing the latest\ndesired state that was synchronized";
          type = (types.nullOr types.int);
        };
        "schemas" = mkOption {
          description = "Schemas is the status of the managed schemas";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.DatabaseStatusSchemas" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "servers" = mkOption {
          description = "Servers is the status of the managed servers";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.DatabaseStatusServers" "name" [ ]
            )
          );
          apply = attrsToList;
        };
      };

      config = {
        "applied" = mkOverride 1002 null;
        "extensions" = mkOverride 1002 null;
        "fdws" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "observedGeneration" = mkOverride 1002 null;
        "schemas" = mkOverride 1002 null;
        "servers" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.DatabaseStatusExtensions" = {

      options = {
        "applied" = mkOption {
          description = "True of the object has been installed successfully in\nthe database";
          type = types.bool;
        };
        "message" = mkOption {
          description = "Message is the object reconciliation message";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "The name of the object";
          type = types.str;
        };
      };

      config = {
        "message" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.DatabaseStatusFdws" = {

      options = {
        "applied" = mkOption {
          description = "True of the object has been installed successfully in\nthe database";
          type = types.bool;
        };
        "message" = mkOption {
          description = "Message is the object reconciliation message";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "The name of the object";
          type = types.str;
        };
      };

      config = {
        "message" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.DatabaseStatusSchemas" = {

      options = {
        "applied" = mkOption {
          description = "True of the object has been installed successfully in\nthe database";
          type = types.bool;
        };
        "message" = mkOption {
          description = "Message is the object reconciliation message";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "The name of the object";
          type = types.str;
        };
      };

      config = {
        "message" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.DatabaseStatusServers" = {

      options = {
        "applied" = mkOption {
          description = "True of the object has been installed successfully in\nthe database";
          type = types.bool;
        };
        "message" = mkOption {
          description = "Message is the object reconciliation message";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "The name of the object";
          type = types.str;
        };
      };

      config = {
        "message" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.FailoverQuorum" = {

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
        "status" = mkOption {
          description = "Most recently observed status of the failover quorum.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.FailoverQuorumStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.FailoverQuorumStatus" = {

      options = {
        "method" = mkOption {
          description = "Contains the latest reported Method value.";
          type = (types.nullOr types.str);
        };
        "primary" = mkOption {
          description = "Primary is the name of the primary instance that updated\nthis object the latest time.";
          type = (types.nullOr types.str);
        };
        "standbyNames" = mkOption {
          description = "StandbyNames is the list of potentially synchronous\ninstance names.";
          type = (types.nullOr (types.listOf types.str));
        };
        "standbyNumber" = mkOption {
          description = "StandbyNumber is the number of synchronous standbys that transactions\nneed to wait for replies from.";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "method" = mkOverride 1002 null;
        "primary" = mkOverride 1002 null;
        "standbyNames" = mkOverride 1002 null;
        "standbyNumber" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ImageCatalog" = {

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
          description = "Specification of the desired behavior of the ImageCatalog.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status";
          type = (submoduleOf "postgresql.cnpg.io.v1.ImageCatalogSpec");
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ImageCatalogSpec" = {

      options = {
        "images" = mkOption {
          description = "List of CatalogImages available in the catalog";
          type = (types.listOf (submoduleOf "postgresql.cnpg.io.v1.ImageCatalogSpecImages"));
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ImageCatalogSpecImages" = {

      options = {
        "image" = mkOption {
          description = "The image reference";
          type = types.str;
        };
        "major" = mkOption {
          description = "The PostgreSQL major version of the image. Must be unique within the catalog.";
          type = types.int;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.Pooler" = {

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
          description = "Specification of the desired behavior of the Pooler.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status";
          type = (submoduleOf "postgresql.cnpg.io.v1.PoolerSpec");
        };
        "status" = mkOption {
          description = "Most recently observed status of the Pooler. This data may not be up to\ndate. Populated by the system. Read-only.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpec" = {

      options = {
        "cluster" = mkOption {
          description = "This is the cluster reference on which the Pooler will work.\nPooler name should never match with any cluster name within the same namespace.";
          type = (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecCluster");
        };
        "deploymentStrategy" = mkOption {
          description = "The deployment strategy to use for pgbouncer to replace existing pods with new ones";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecDeploymentStrategy"));
        };
        "instances" = mkOption {
          description = "The number of replicas we want. Default: 1.";
          type = (types.nullOr types.int);
        };
        "monitoring" = mkOption {
          description = "The configuration of the monitoring infrastructure of this pooler.\n\nDeprecated: This feature will be removed in an upcoming release. If\nyou need this functionality, you can create a PodMonitor manually.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecMonitoring"));
        };
        "pgbouncer" = mkOption {
          description = "The PgBouncer configuration";
          type = (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecPgbouncer");
        };
        "serviceTemplate" = mkOption {
          description = "Template for the Service to be created";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecServiceTemplate"));
        };
        "template" = mkOption {
          description = "The template of the Pod to be created";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplate"));
        };
        "type" = mkOption {
          description = "Type of service to forward traffic to. Default: `rw`.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "deploymentStrategy" = mkOverride 1002 null;
        "instances" = mkOverride 1002 null;
        "monitoring" = mkOverride 1002 null;
        "serviceTemplate" = mkOverride 1002 null;
        "template" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecCluster" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecDeploymentStrategy" = {

      options = {
        "rollingUpdate" = mkOption {
          description = "Rolling update config params. Present only if DeploymentStrategyType =\nRollingUpdate.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecDeploymentStrategyRollingUpdate")
          );
        };
        "type" = mkOption {
          description = "Type of deployment. Can be \"Recreate\" or \"RollingUpdate\". Default is RollingUpdate.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "rollingUpdate" = mkOverride 1002 null;
        "type" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecDeploymentStrategyRollingUpdate" = {

      options = {
        "maxSurge" = mkOption {
          description = "The maximum number of pods that can be scheduled above the desired number of\npods.\nValue can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%).\nThis can not be 0 if MaxUnavailable is 0.\nAbsolute number is calculated from percentage by rounding up.\nDefaults to 25%.\nExample: when this is set to 30%, the new ReplicaSet can be scaled up immediately when\nthe rolling update starts, such that the total number of old and new pods do not exceed\n130% of desired pods. Once old pods have been killed,\nnew ReplicaSet can be scaled up further, ensuring that total number of pods running\nat any time during the update is at most 130% of desired pods.";
          type = (types.nullOr (types.either types.int types.str));
        };
        "maxUnavailable" = mkOption {
          description = "The maximum number of pods that can be unavailable during the update.\nValue can be an absolute number (ex: 5) or a percentage of desired pods (ex: 10%).\nAbsolute number is calculated from percentage by rounding down.\nThis can not be 0 if MaxSurge is 0.\nDefaults to 25%.\nExample: when this is set to 30%, the old ReplicaSet can be scaled down to 70% of desired pods\nimmediately when the rolling update starts. Once new pods are ready, old ReplicaSet\ncan be scaled down further, followed by scaling up the new ReplicaSet, ensuring\nthat the total number of pods available at all times during the update is at\nleast 70% of desired pods.";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "maxSurge" = mkOverride 1002 null;
        "maxUnavailable" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecMonitoring" = {

      options = {
        "enablePodMonitor" = mkOption {
          description = "Enable or disable the `PodMonitor`";
          type = (types.nullOr types.bool);
        };
        "podMonitorMetricRelabelings" = mkOption {
          description = "The list of metric relabelings for the `PodMonitor`. Applied to samples before ingestion.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecMonitoringPodMonitorMetricRelabelings")
            )
          );
        };
        "podMonitorRelabelings" = mkOption {
          description = "The list of relabelings for the `PodMonitor`. Applied to samples before scraping.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecMonitoringPodMonitorRelabelings")
            )
          );
        };
      };

      config = {
        "enablePodMonitor" = mkOverride 1002 null;
        "podMonitorMetricRelabelings" = mkOverride 1002 null;
        "podMonitorRelabelings" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecMonitoringPodMonitorMetricRelabelings" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecMonitoringPodMonitorRelabelings" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecPgbouncer" = {

      options = {
        "authQuery" = mkOption {
          description = "The query that will be used to download the hash of the password\nof a certain user. Default: \"SELECT usename, passwd FROM public.user_search($1)\".\nIn case it is specified, also an AuthQuerySecret has to be specified and\nno automatic CNPG Cluster integration will be triggered.";
          type = (types.nullOr types.str);
        };
        "authQuerySecret" = mkOption {
          description = "The credentials of the user that need to be used for the authentication\nquery. In case it is specified, also an AuthQuery\n(e.g. \"SELECT usename, passwd FROM pg_catalog.pg_shadow WHERE usename=$1\")\nhas to be specified and no automatic CNPG Cluster integration will be triggered.\n\nDeprecated.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecPgbouncerAuthQuerySecret"));
        };
        "clientCASecret" = mkOption {
          description = "ClientCASecret provides PgBouncer’s client_tls_ca_file, the root\nCA for validating client certificates";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecPgbouncerClientCASecret"));
        };
        "clientTLSSecret" = mkOption {
          description = "ClientTLSSecret provides PgBouncer’s client_tls_key_file (private key)\nand client_tls_cert_file (certificate) used to accept client connections";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecPgbouncerClientTLSSecret"));
        };
        "parameters" = mkOption {
          description = "Additional parameters to be passed to PgBouncer - please check\nthe CNPG documentation for a list of options you can configure";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "paused" = mkOption {
          description = "When set to `true`, PgBouncer will disconnect from the PostgreSQL\nserver, first waiting for all queries to complete, and pause all new\nclient connections until this value is set to `false` (default). Internally,\nthe operator calls PgBouncer's `PAUSE` and `RESUME` commands.";
          type = (types.nullOr types.bool);
        };
        "pg_hba" = mkOption {
          description = "PostgreSQL Host Based Authentication rules (lines to be appended\nto the pg_hba.conf file)";
          type = (types.nullOr (types.listOf types.str));
        };
        "poolMode" = mkOption {
          description = "The pool mode. Default: `session`.";
          type = (types.nullOr types.str);
        };
        "serverCASecret" = mkOption {
          description = "ServerCASecret provides PgBouncer’s server_tls_ca_file, the root\nCA for validating PostgreSQL certificates";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecPgbouncerServerCASecret"));
        };
        "serverTLSSecret" = mkOption {
          description = "ServerTLSSecret, when pointing to a TLS secret, provides pgbouncer's\n`server_tls_key_file` and `server_tls_cert_file`, used when\nauthenticating against PostgreSQL.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecPgbouncerServerTLSSecret"));
        };
      };

      config = {
        "authQuery" = mkOverride 1002 null;
        "authQuerySecret" = mkOverride 1002 null;
        "clientCASecret" = mkOverride 1002 null;
        "clientTLSSecret" = mkOverride 1002 null;
        "parameters" = mkOverride 1002 null;
        "paused" = mkOverride 1002 null;
        "pg_hba" = mkOverride 1002 null;
        "poolMode" = mkOverride 1002 null;
        "serverCASecret" = mkOverride 1002 null;
        "serverTLSSecret" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecPgbouncerAuthQuerySecret" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecPgbouncerClientCASecret" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecPgbouncerClientTLSSecret" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecPgbouncerServerCASecret" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecPgbouncerServerTLSSecret" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecServiceTemplate" = {

      options = {
        "metadata" = mkOption {
          description = "Standard object's metadata.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecServiceTemplateMetadata"));
        };
        "spec" = mkOption {
          description = "Specification of the desired behavior of the service.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecServiceTemplateSpec"));
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecServiceTemplateMetadata" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecServiceTemplateSpec" = {

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
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.PoolerSpecServiceTemplateSpecPorts" "name"
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
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecServiceTemplateSpecSessionAffinityConfig"
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
    "postgresql.cnpg.io.v1.PoolerSpecServiceTemplateSpecPorts" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecServiceTemplateSpecSessionAffinityConfig" = {

      options = {
        "clientIP" = mkOption {
          description = "clientIP contains the configurations of Client IP based session affinity.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecServiceTemplateSpecSessionAffinityConfigClientIP"
            )
          );
        };
      };

      config = {
        "clientIP" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecServiceTemplateSpecSessionAffinityConfigClientIP" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplate" = {

      options = {
        "metadata" = mkOption {
          description = "Standard object's metadata.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#metadata";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateMetadata"));
        };
        "spec" = mkOption {
          description = "Specification of the desired behavior of the pod.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpec"));
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
        "spec" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateMetadata" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpec" = {

      options = {
        "activeDeadlineSeconds" = mkOption {
          description = "Optional duration in seconds the pod may be active on the node relative to\nStartTime before the system will actively try to mark it failed and kill associated containers.\nValue must be a positive integer.";
          type = (types.nullOr types.int);
        };
        "affinity" = mkOption {
          description = "If specified, the pod's scheduling constraints";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinity"));
        };
        "automountServiceAccountToken" = mkOption {
          description = "AutomountServiceAccountToken indicates whether a service account token should be automatically mounted.";
          type = (types.nullOr types.bool);
        };
        "containers" = mkOption {
          description = "List of containers belonging to the pod.\nContainers cannot currently be added or removed.\nThere must be at least one container in a Pod.\nCannot be updated.";
          type = (
            coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainers" "name" [
              "name"
            ]
          );
          apply = attrsToList;
        };
        "dnsConfig" = mkOption {
          description = "Specifies the DNS parameters of a pod.\nParameters specified here will be merged to the generated DNS\nconfiguration based on DNSPolicy.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecDnsConfig"));
        };
        "dnsPolicy" = mkOption {
          description = "Set DNS policy for the pod.\nDefaults to \"ClusterFirst\".\nValid values are 'ClusterFirstWithHostNet', 'ClusterFirst', 'Default' or 'None'.\nDNS parameters given in DNSConfig will be merged with the policy selected with DNSPolicy.\nTo have DNS options set along with hostNetwork, you have to specify DNS policy\nexplicitly to 'ClusterFirstWithHostNet'.";
          type = (types.nullOr types.str);
        };
        "enableServiceLinks" = mkOption {
          description = "EnableServiceLinks indicates whether information about services should be injected into pod's\nenvironment variables, matching the syntax of Docker links.\nOptional: Defaults to true.";
          type = (types.nullOr types.bool);
        };
        "ephemeralContainers" = mkOption {
          description = "List of ephemeral containers run in this pod. Ephemeral containers may be run in an existing\npod to perform user-initiated actions such as debugging. This list cannot be specified when\ncreating a pod, and it cannot be modified by updating the pod spec. In order to add an\nephemeral container to an existing pod, use the pod's ephemeralcontainers subresource.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainers"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "hostAliases" = mkOption {
          description = "HostAliases is an optional list of hosts and IPs that will be injected into the pod's hosts\nfile if specified.";
          type = (
            types.nullOr (types.listOf (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecHostAliases"))
          );
        };
        "hostIPC" = mkOption {
          description = "Use the host's ipc namespace.\nOptional: Default to false.";
          type = (types.nullOr types.bool);
        };
        "hostNetwork" = mkOption {
          description = "Host networking requested for this pod. Use the host's network namespace.\nWhen using HostNetwork you should specify ports so the scheduler is aware.\nWhen `hostNetwork` is true, specified `hostPort` fields in port definitions must match `containerPort`,\nand unspecified `hostPort` fields in port definitions are defaulted to match `containerPort`.\nDefault to false.";
          type = (types.nullOr types.bool);
        };
        "hostPID" = mkOption {
          description = "Use the host's pid namespace.\nOptional: Default to false.";
          type = (types.nullOr types.bool);
        };
        "hostUsers" = mkOption {
          description = "Use the host's user namespace.\nOptional: Default to true.\nIf set to true or not present, the pod will be run in the host user namespace, useful\nfor when the pod needs a feature only available to the host user namespace, such as\nloading a kernel module with CAP_SYS_MODULE.\nWhen set to false, a new userns is created for the pod. Setting false is useful for\nmitigating container breakout vulnerabilities even allowing users to run their\ncontainers as root without actually having root privileges on the host.\nThis field is alpha-level and is only honored by servers that enable the UserNamespacesSupport feature.";
          type = (types.nullOr types.bool);
        };
        "hostname" = mkOption {
          description = "Specifies the hostname of the Pod\nIf not specified, the pod's hostname will be set to a system-defined value.";
          type = (types.nullOr types.str);
        };
        "hostnameOverride" = mkOption {
          description = "HostnameOverride specifies an explicit override for the pod's hostname as perceived by the pod.\nThis field only specifies the pod's hostname and does not affect its DNS records.\nWhen this field is set to a non-empty string:\n- It takes precedence over the values set in `hostname` and `subdomain`.\n- The Pod's hostname will be set to this value.\n- `setHostnameAsFQDN` must be nil or set to false.\n- `hostNetwork` must be set to false.\n\nThis field must be a valid DNS subdomain as defined in RFC 1123 and contain at most 64 characters.\nRequires the HostnameOverride feature gate to be enabled.";
          type = (types.nullOr types.str);
        };
        "imagePullSecrets" = mkOption {
          description = "ImagePullSecrets is an optional list of references to secrets in the same namespace to use for pulling any of the images used by this PodSpec.\nIf specified, these secrets will be passed to individual puller implementations for them to use.\nMore info: https://kubernetes.io/docs/concepts/containers/images#specifying-imagepullsecrets-on-a-pod";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecImagePullSecrets"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "initContainers" = mkOption {
          description = "List of initialization containers belonging to the pod.\nInit containers are executed in order prior to containers being started. If any\ninit container fails, the pod is considered to have failed and is handled according\nto its restartPolicy. The name for an init container or normal container must be\nunique among all containers.\nInit containers may not have Lifecycle actions, Readiness probes, Liveness probes, or Startup probes.\nThe resourceRequirements of an init container are taken into account during scheduling\nby finding the highest request/limit for each resource type, and then using the max of\nthat value or the sum of the normal containers. Limits are applied to init containers\nin a similar fashion.\nInit containers cannot currently be added or removed.\nCannot be updated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/init-containers/";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainers"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "nodeName" = mkOption {
          description = "NodeName indicates in which node this pod is scheduled.\nIf empty, this pod is a candidate for scheduling by the scheduler defined in schedulerName.\nOnce this field is set, the kubelet for this node becomes responsible for the lifecycle of this pod.\nThis field should not be used to express a desire for the pod to be scheduled on a specific node.\nhttps://kubernetes.io/docs/concepts/scheduling-eviction/assign-pod-node/#nodename";
          type = (types.nullOr types.str);
        };
        "nodeSelector" = mkOption {
          description = "NodeSelector is a selector which must be true for the pod to fit on a node.\nSelector which must match a node's labels for the pod to be scheduled on that node.\nMore info: https://kubernetes.io/docs/concepts/configuration/assign-pod-node/";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "os" = mkOption {
          description = "Specifies the OS of the containers in the pod.\nSome pod and container fields are restricted if this is set.\n\nIf the OS field is set to linux, the following fields must be unset:\n-securityContext.windowsOptions\n\nIf the OS field is set to windows, following fields must be unset:\n- spec.hostPID\n- spec.hostIPC\n- spec.hostUsers\n- spec.resources\n- spec.securityContext.appArmorProfile\n- spec.securityContext.seLinuxOptions\n- spec.securityContext.seccompProfile\n- spec.securityContext.fsGroup\n- spec.securityContext.fsGroupChangePolicy\n- spec.securityContext.sysctls\n- spec.shareProcessNamespace\n- spec.securityContext.runAsUser\n- spec.securityContext.runAsGroup\n- spec.securityContext.supplementalGroups\n- spec.securityContext.supplementalGroupsPolicy\n- spec.containers[*].securityContext.appArmorProfile\n- spec.containers[*].securityContext.seLinuxOptions\n- spec.containers[*].securityContext.seccompProfile\n- spec.containers[*].securityContext.capabilities\n- spec.containers[*].securityContext.readOnlyRootFilesystem\n- spec.containers[*].securityContext.privileged\n- spec.containers[*].securityContext.allowPrivilegeEscalation\n- spec.containers[*].securityContext.procMount\n- spec.containers[*].securityContext.runAsUser\n- spec.containers[*].securityContext.runAsGroup";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecOs"));
        };
        "overhead" = mkOption {
          description = "Overhead represents the resource overhead associated with running a pod for a given RuntimeClass.\nThis field will be autopopulated at admission time by the RuntimeClass admission controller. If\nthe RuntimeClass admission controller is enabled, overhead must not be set in Pod create requests.\nThe RuntimeClass admission controller will reject Pod create requests which have the overhead already\nset. If RuntimeClass is configured and selected in the PodSpec, Overhead will be set to the value\ndefined in the corresponding RuntimeClass, otherwise it will remain unset and treated as zero.\nMore info: https://git.k8s.io/enhancements/keps/sig-node/688-pod-overhead/README.md";
          type = (types.nullOr (types.attrsOf (types.either types.int types.str)));
        };
        "preemptionPolicy" = mkOption {
          description = "PreemptionPolicy is the Policy for preempting pods with lower priority.\nOne of Never, PreemptLowerPriority.\nDefaults to PreemptLowerPriority if unset.";
          type = (types.nullOr types.str);
        };
        "priority" = mkOption {
          description = "The priority value. Various system components use this field to find the\npriority of the pod. When Priority Admission Controller is enabled, it\nprevents users from setting this field. The admission controller populates\nthis field from PriorityClassName.\nThe higher the value, the higher the priority.";
          type = (types.nullOr types.int);
        };
        "priorityClassName" = mkOption {
          description = "If specified, indicates the pod's priority. \"system-node-critical\" and\n\"system-cluster-critical\" are two special keywords which indicate the\nhighest priorities with the former being the highest priority. Any other\nname must be defined by creating a PriorityClass object with that name.\nIf not specified, the pod priority will be default or zero if there is no\ndefault.";
          type = (types.nullOr types.str);
        };
        "readinessGates" = mkOption {
          description = "If specified, all readiness gates will be evaluated for pod readiness.\nA pod is ready when all its containers are ready AND\nall conditions specified in the readiness gates have status equal to \"True\"\nMore info: https://git.k8s.io/enhancements/keps/sig-network/580-pod-readiness-gates";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecReadinessGates")
            )
          );
        };
        "resourceClaims" = mkOption {
          description = "ResourceClaims defines which ResourceClaims must be allocated\nand reserved before the Pod is allowed to start. The resources\nwill be made available to those containers which consume them\nby name.\n\nThis is an alpha field and requires enabling the\nDynamicResourceAllocation feature gate.\n\nThis field is immutable.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecResourceClaims"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "resources" = mkOption {
          description = "Resources is the total amount of CPU and Memory resources required by all\ncontainers in the pod. It supports specifying Requests and Limits for\n\"cpu\", \"memory\" and \"hugepages-\" resource names only. ResourceClaims are not supported.\n\nThis field enables fine-grained control over resource allocation for the\nentire pod, allowing resource sharing among containers in a pod.\n\nThis is an alpha field and requires enabling the PodLevelResources feature\ngate.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecResources"));
        };
        "restartPolicy" = mkOption {
          description = "Restart policy for all containers within the pod.\nOne of Always, OnFailure, Never. In some contexts, only a subset of those values may be permitted.\nDefault to Always.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle/#restart-policy";
          type = (types.nullOr types.str);
        };
        "runtimeClassName" = mkOption {
          description = "RuntimeClassName refers to a RuntimeClass object in the node.k8s.io group, which should be used\nto run this pod.  If no RuntimeClass resource matches the named class, the pod will not be run.\nIf unset or empty, the \"legacy\" RuntimeClass will be used, which is an implicit class with an\nempty definition that uses the default runtime handler.\nMore info: https://git.k8s.io/enhancements/keps/sig-node/585-runtime-class";
          type = (types.nullOr types.str);
        };
        "schedulerName" = mkOption {
          description = "If specified, the pod will be dispatched by specified scheduler.\nIf not specified, the pod will be dispatched by default scheduler.";
          type = (types.nullOr types.str);
        };
        "schedulingGates" = mkOption {
          description = "SchedulingGates is an opaque list of values that if specified will block scheduling the pod.\nIf schedulingGates is not empty, the pod will stay in the SchedulingGated state and the\nscheduler will not attempt to schedule the pod.\n\nSchedulingGates can only be set at pod creation time, and be removed only afterwards.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecSchedulingGates"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "securityContext" = mkOption {
          description = "SecurityContext holds pod-level security attributes and common container settings.\nOptional: Defaults to empty.  See type description for default values of each field.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecSecurityContext"));
        };
        "serviceAccount" = mkOption {
          description = "DeprecatedServiceAccount is a deprecated alias for ServiceAccountName.\nDeprecated: Use serviceAccountName instead.";
          type = (types.nullOr types.str);
        };
        "serviceAccountName" = mkOption {
          description = "ServiceAccountName is the name of the ServiceAccount to use to run this pod.\nMore info: https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/";
          type = (types.nullOr types.str);
        };
        "setHostnameAsFQDN" = mkOption {
          description = "If true the pod's hostname will be configured as the pod's FQDN, rather than the leaf name (the default).\nIn Linux containers, this means setting the FQDN in the hostname field of the kernel (the nodename field of struct utsname).\nIn Windows containers, this means setting the registry value of hostname for the registry key HKEY_LOCAL_MACHINE\\\\SYSTEM\\\\CurrentControlSet\\\\Services\\\\Tcpip\\\\Parameters to FQDN.\nIf a pod does not have FQDN, this has no effect.\nDefault to false.";
          type = (types.nullOr types.bool);
        };
        "shareProcessNamespace" = mkOption {
          description = "Share a single process namespace between all of the containers in a pod.\nWhen this is set containers will be able to view and signal processes from other containers\nin the same pod, and the first process in each container will not be assigned PID 1.\nHostPID and ShareProcessNamespace cannot both be set.\nOptional: Default to false.";
          type = (types.nullOr types.bool);
        };
        "subdomain" = mkOption {
          description = "If specified, the fully qualified Pod hostname will be \"<hostname>.<subdomain>.<pod namespace>.svc.<cluster domain>\".\nIf not specified, the pod will not have a domainname at all.";
          type = (types.nullOr types.str);
        };
        "terminationGracePeriodSeconds" = mkOption {
          description = "Optional duration in seconds the pod needs to terminate gracefully. May be decreased in delete request.\nValue must be non-negative integer. The value zero indicates stop immediately via\nthe kill signal (no opportunity to shut down).\nIf this value is nil, the default grace period will be used instead.\nThe grace period is the duration in seconds after the processes running in the pod are sent\na termination signal and the time when the processes are forcibly halted with a kill signal.\nSet this value longer than the expected cleanup time for your process.\nDefaults to 30 seconds.";
          type = (types.nullOr types.int);
        };
        "tolerations" = mkOption {
          description = "If specified, the pod's tolerations.";
          type = (
            types.nullOr (types.listOf (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecTolerations"))
          );
        };
        "topologySpreadConstraints" = mkOption {
          description = "TopologySpreadConstraints describes how a group of pods ought to spread across topology\ndomains. Scheduler will schedule pods in a way which abides by the constraints.\nAll topologySpreadConstraints are ANDed.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecTopologySpreadConstraints")
            )
          );
        };
        "volumes" = mkOption {
          description = "List of volumes that can be mounted by containers belonging to the pod.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumes" "name" [
                "name"
              ]
            )
          );
          apply = attrsToList;
        };
      };

      config = {
        "activeDeadlineSeconds" = mkOverride 1002 null;
        "affinity" = mkOverride 1002 null;
        "automountServiceAccountToken" = mkOverride 1002 null;
        "dnsConfig" = mkOverride 1002 null;
        "dnsPolicy" = mkOverride 1002 null;
        "enableServiceLinks" = mkOverride 1002 null;
        "ephemeralContainers" = mkOverride 1002 null;
        "hostAliases" = mkOverride 1002 null;
        "hostIPC" = mkOverride 1002 null;
        "hostNetwork" = mkOverride 1002 null;
        "hostPID" = mkOverride 1002 null;
        "hostUsers" = mkOverride 1002 null;
        "hostname" = mkOverride 1002 null;
        "hostnameOverride" = mkOverride 1002 null;
        "imagePullSecrets" = mkOverride 1002 null;
        "initContainers" = mkOverride 1002 null;
        "nodeName" = mkOverride 1002 null;
        "nodeSelector" = mkOverride 1002 null;
        "os" = mkOverride 1002 null;
        "overhead" = mkOverride 1002 null;
        "preemptionPolicy" = mkOverride 1002 null;
        "priority" = mkOverride 1002 null;
        "priorityClassName" = mkOverride 1002 null;
        "readinessGates" = mkOverride 1002 null;
        "resourceClaims" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "restartPolicy" = mkOverride 1002 null;
        "runtimeClassName" = mkOverride 1002 null;
        "schedulerName" = mkOverride 1002 null;
        "schedulingGates" = mkOverride 1002 null;
        "securityContext" = mkOverride 1002 null;
        "serviceAccount" = mkOverride 1002 null;
        "serviceAccountName" = mkOverride 1002 null;
        "setHostnameAsFQDN" = mkOverride 1002 null;
        "shareProcessNamespace" = mkOverride 1002 null;
        "subdomain" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "tolerations" = mkOverride 1002 null;
        "topologySpreadConstraints" = mkOverride 1002 null;
        "volumes" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinity" = {

      options = {
        "nodeAffinity" = mkOption {
          description = "Describes node affinity scheduling rules for the pod.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinity")
          );
        };
        "podAffinity" = mkOption {
          description = "Describes pod affinity scheduling rules (e.g. co-locate this pod in the same node, zone, etc. as some other pod(s)).";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinity")
          );
        };
        "podAntiAffinity" = mkOption {
          description = "Describes pod anti-affinity scheduling rules (e.g. avoid putting this pod in the same node, zone, etc. as some other pod(s)).";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinity")
          );
        };
      };

      config = {
        "nodeAffinity" = mkOverride 1002 null;
        "podAffinity" = mkOverride 1002 null;
        "podAntiAffinity" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "The scheduler will prefer to schedule pods to nodes that satisfy\nthe affinity expressions specified by this field, but it may choose\na node that violates one or more of the expressions. The node that is\nmost preferred is the one with the greatest sum of weights, i.e.\nfor each node that meets all of the scheduling requirements (resource\nrequest, requiredDuringScheduling affinity expressions, etc.),\ncompute a sum by iterating through the elements of this field and adding\n\"weight\" to the sum if the node matches the corresponding matchExpressions; the\nnode(s) with the highest sum are the most preferred.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "If the affinity requirements specified by this field are not met at\nscheduling time, the pod will not be scheduled onto the node.\nIf the affinity requirements specified by this field cease to be met\nat some point during pod execution (e.g. due to an update), the system\nmay or may not try to eventually evict the pod from its node.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecution"
            )
          );
        };
      };

      config = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "preference" = mkOption {
            description = "A node selector term, associated with the corresponding weight.";
            type = (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreference"
            );
          };
          "weight" = mkOption {
            description = "Weight associated with matching the corresponding nodeSelectorTerm, in the range 1-100.";
            type = types.int;
          };
        };

        config = { };

      };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreference" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "A list of node selector requirements by node's labels.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchExpressions"
                )
              )
            );
          };
          "matchFields" = mkOption {
            description = "A list of node selector requirements by node's fields.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchFields"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchExpressions" =
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinityPreferredDuringSchedulingIgnoredDuringExecutionPreferenceMatchFields" =
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "nodeSelectorTerms" = mkOption {
            description = "Required. A list of node selector terms. The terms are ORed.";
            type = (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTerms"
              )
            );
          };
        };

        config = { };

      };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTerms" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "A list of node selector requirements by node's labels.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchExpressions"
                )
              )
            );
          };
          "matchFields" = mkOption {
            description = "A list of node selector requirements by node's fields.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchFields"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchExpressions" =
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityNodeAffinityRequiredDuringSchedulingIgnoredDuringExecutionNodeSelectorTermsMatchFields" =
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "The scheduler will prefer to schedule pods to nodes that satisfy\nthe affinity expressions specified by this field, but it may choose\na node that violates one or more of the expressions. The node that is\nmost preferred is the one with the greatest sum of weights, i.e.\nfor each node that meets all of the scheduling requirements (resource\nrequest, requiredDuringScheduling affinity expressions, etc.),\ncompute a sum by iterating through the elements of this field and adding\n\"weight\" to the sum if the node has pods which matches the corresponding podAffinityTerm; the\nnode(s) with the highest sum are the most preferred.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "If the affinity requirements specified by this field are not met at\nscheduling time, the pod will not be scheduled onto the node.\nIf the affinity requirements specified by this field cease to be met\nat some point during pod execution (e.g. due to a pod label update), the\nsystem may or may not try to eventually evict the pod from its node.\nWhen there are multiple elements, the lists of nodes corresponding to each\npodAffinityTerm are intersected, i.e. all terms must be satisfied.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecution"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "podAffinityTerm" = mkOption {
            description = "Required. A pod affinity term, associated with the corresponding weight.";
            type = (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm"
            );
          };
          "weight" = mkOption {
            description = "weight associated with matching the corresponding podAffinityTerm,\nin the range 1-100.";
            type = types.int;
          };
        };

        config = { };

      };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "A label query over a set of resources, in this case pods.\nIf it's null, this PodAffinityTerm matches with no Pods.";
            type = (
              types.nullOr (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector"
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
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions" =
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions" =
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "A label query over a set of resources, in this case pods.\nIf it's null, this PodAffinityTerm matches with no Pods.";
            type = (
              types.nullOr (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector"
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
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions" =
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions" =
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinity" = {

      options = {
        "preferredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "The scheduler will prefer to schedule pods to nodes that satisfy\nthe anti-affinity expressions specified by this field, but it may choose\na node that violates one or more of the expressions. The node that is\nmost preferred is the one with the greatest sum of weights, i.e.\nfor each node that meets all of the scheduling requirements (resource\nrequest, requiredDuringScheduling anti-affinity expressions, etc.),\ncompute a sum by iterating through the elements of this field and subtracting\n\"weight\" from the sum if the node has pods which matches the corresponding podAffinityTerm; the\nnode(s) with the highest sum are the most preferred.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecution"
              )
            )
          );
        };
        "requiredDuringSchedulingIgnoredDuringExecution" = mkOption {
          description = "If the anti-affinity requirements specified by this field are not met at\nscheduling time, the pod will not be scheduled onto the node.\nIf the anti-affinity requirements specified by this field cease to be met\nat some point during pod execution (e.g. due to a pod label update), the\nsystem may or may not try to eventually evict the pod from its node.\nWhen there are multiple elements, the lists of nodes corresponding to each\npodAffinityTerm are intersected, i.e. all terms must be satisfied.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecution"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "podAffinityTerm" = mkOption {
            description = "Required. A pod affinity term, associated with the corresponding weight.";
            type = (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm"
            );
          };
          "weight" = mkOption {
            description = "weight associated with matching the corresponding podAffinityTerm,\nin the range 1-100.";
            type = types.int;
          };
        };

        config = { };

      };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTerm" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "A label query over a set of resources, in this case pods.\nIf it's null, this PodAffinityTerm matches with no Pods.";
            type = (
              types.nullOr (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector"
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
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermLabelSelectorMatchExpressions" =
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityPreferredDuringSchedulingIgnoredDuringExecutionPodAffinityTermNamespaceSelectorMatchExpressions" =
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecution" =
      {

        options = {
          "labelSelector" = mkOption {
            description = "A label query over a set of resources, in this case pods.\nIf it's null, this PodAffinityTerm matches with no Pods.";
            type = (
              types.nullOr (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector"
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
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionLabelSelectorMatchExpressions" =
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecAffinityPodAntiAffinityRequiredDuringSchedulingIgnoredDuringExecutionNamespaceSelectorMatchExpressions" =
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainers" = {

      options = {
        "args" = mkOption {
          description = "Arguments to the entrypoint.\nThe container image's CMD is used if this is not provided.\nVariable references $(VAR_NAME) are expanded using the container's environment. If a variable\ncannot be resolved, the reference in the input string will be unchanged. Double $$ are reduced\nto a single $, which allows for escaping the $(VAR_NAME) syntax: i.e. \"$$(VAR_NAME)\" will\nproduce the string literal \"$(VAR_NAME)\". Escaped references will never be expanded, regardless\nof whether the variable exists or not. Cannot be updated.\nMore info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell";
          type = (types.nullOr (types.listOf types.str));
        };
        "command" = mkOption {
          description = "Entrypoint array. Not executed within a shell.\nThe container image's ENTRYPOINT is used if this is not provided.\nVariable references $(VAR_NAME) are expanded using the container's environment. If a variable\ncannot be resolved, the reference in the input string will be unchanged. Double $$ are reduced\nto a single $, which allows for escaping the $(VAR_NAME) syntax: i.e. \"$$(VAR_NAME)\" will\nproduce the string literal \"$(VAR_NAME)\". Escaped references will never be expanded, regardless\nof whether the variable exists or not. Cannot be updated.\nMore info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell";
          type = (types.nullOr (types.listOf types.str));
        };
        "env" = mkOption {
          description = "List of environment variables to set in the container.\nCannot be updated.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnv"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "envFrom" = mkOption {
          description = "List of sources to populate environment variables in the container.\nThe keys defined within a source may consist of any printable ASCII characters except '='.\nWhen a key exists in multiple\nsources, the value associated with the last source will take precedence.\nValues defined by an Env with a duplicate key will take precedence.\nCannot be updated.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvFrom")
            )
          );
        };
        "image" = mkOption {
          description = "Container image name.\nMore info: https://kubernetes.io/docs/concepts/containers/images\nThis field is optional to allow higher level config management to default or override\ncontainer images in workload controllers like Deployments and StatefulSets.";
          type = (types.nullOr types.str);
        };
        "imagePullPolicy" = mkOption {
          description = "Image pull policy.\nOne of Always, Never, IfNotPresent.\nDefaults to Always if :latest tag is specified, or IfNotPresent otherwise.\nCannot be updated.\nMore info: https://kubernetes.io/docs/concepts/containers/images#updating-images";
          type = (types.nullOr types.str);
        };
        "lifecycle" = mkOption {
          description = "Actions that the management system should take in response to container lifecycle events.\nCannot be updated.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecycle")
          );
        };
        "livenessProbe" = mkOption {
          description = "Periodic probe of container liveness.\nContainer will be restarted if the probe fails.\nCannot be updated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLivenessProbe")
          );
        };
        "name" = mkOption {
          description = "Name of the container specified as a DNS_LABEL.\nEach container in a pod must have a unique name (DNS_LABEL).\nCannot be updated.";
          type = types.str;
        };
        "ports" = mkOption {
          description = "List of ports to expose from the container. Not specifying a port here\nDOES NOT prevent that port from being exposed. Any port which is\nlistening on the default \"0.0.0.0\" address inside a container will be\naccessible from the network.\nModifying this array with strategic merge patch may corrupt the data.\nFor more information See https://github.com/kubernetes/kubernetes/issues/108255.\nCannot be updated.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersPorts"
                "name"
                [
                  "containerPort"
                  "protocol"
                ]
            )
          );
          apply = attrsToList;
        };
        "readinessProbe" = mkOption {
          description = "Periodic probe of container service readiness.\nContainer will be removed from service endpoints if the probe fails.\nCannot be updated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersReadinessProbe")
          );
        };
        "resizePolicy" = mkOption {
          description = "Resources resize policy for the container.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersResizePolicy")
            )
          );
        };
        "resources" = mkOption {
          description = "Compute Resources required by this container.\nCannot be updated.\nMore info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersResources")
          );
        };
        "restartPolicy" = mkOption {
          description = "RestartPolicy defines the restart behavior of individual containers in a pod.\nThis overrides the pod-level restart policy. When this field is not specified,\nthe restart behavior is defined by the Pod's restart policy and the container type.\nAdditionally, setting the RestartPolicy as \"Always\" for the init container will\nhave the following effect:\nthis init container will be continually restarted on\nexit until all regular containers have terminated. Once all regular\ncontainers have completed, all init containers with restartPolicy \"Always\"\nwill be shut down. This lifecycle differs from normal init containers and\nis often referred to as a \"sidecar\" container. Although this init\ncontainer still starts in the init container sequence, it does not wait\nfor the container to complete before proceeding to the next init\ncontainer. Instead, the next init container starts immediately after this\ninit container is started, or after any startupProbe has successfully\ncompleted.";
          type = (types.nullOr types.str);
        };
        "restartPolicyRules" = mkOption {
          description = "Represents a list of rules to be checked to determine if the\ncontainer should be restarted on exit. The rules are evaluated in\norder. Once a rule matches a container exit condition, the remaining\nrules are ignored. If no rule matches the container exit condition,\nthe Container-level restart policy determines the whether the container\nis restarted or not. Constraints on the rules:\n- At most 20 rules are allowed.\n- Rules can have the same action.\n- Identical rules are not forbidden in validations.\nWhen rules are specified, container MUST set RestartPolicy explicitly\neven it if matches the Pod's RestartPolicy.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersRestartPolicyRules"
              )
            )
          );
        };
        "securityContext" = mkOption {
          description = "SecurityContext defines the security options the container should be run with.\nIf set, the fields of SecurityContext override the equivalent fields of PodSecurityContext.\nMore info: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersSecurityContext")
          );
        };
        "startupProbe" = mkOption {
          description = "StartupProbe indicates that the Pod has successfully initialized.\nIf specified, no other probes are executed until this completes successfully.\nIf this probe fails, the Pod will be restarted, just as if the livenessProbe failed.\nThis can be used to provide different probe parameters at the beginning of a Pod's lifecycle,\nwhen it might take a long time to load data or warm a cache, than during steady-state operation.\nThis cannot be updated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersStartupProbe")
          );
        };
        "stdin" = mkOption {
          description = "Whether this container should allocate a buffer for stdin in the container runtime. If this\nis not set, reads from stdin in the container will always result in EOF.\nDefault is false.";
          type = (types.nullOr types.bool);
        };
        "stdinOnce" = mkOption {
          description = "Whether the container runtime should close the stdin channel after it has been opened by\na single attach. When stdin is true the stdin stream will remain open across multiple attach\nsessions. If stdinOnce is set to true, stdin is opened on container start, is empty until the\nfirst client attaches to stdin, and then remains open and accepts data until the client disconnects,\nat which time stdin is closed and remains closed until the container is restarted. If this\nflag is false, a container processes that reads from stdin will never receive an EOF.\nDefault is false";
          type = (types.nullOr types.bool);
        };
        "terminationMessagePath" = mkOption {
          description = "Optional: Path at which the file to which the container's termination message\nwill be written is mounted into the container's filesystem.\nMessage written is intended to be brief final status, such as an assertion failure message.\nWill be truncated by the node if greater than 4096 bytes. The total message length across\nall containers will be limited to 12kb.\nDefaults to /dev/termination-log.\nCannot be updated.";
          type = (types.nullOr types.str);
        };
        "terminationMessagePolicy" = mkOption {
          description = "Indicate how the termination message should be populated. File will use the contents of\nterminationMessagePath to populate the container status message on both success and failure.\nFallbackToLogsOnError will use the last chunk of container log output if the termination\nmessage file is empty and the container exited with an error.\nThe log output is limited to 2048 bytes or 80 lines, whichever is smaller.\nDefaults to File.\nCannot be updated.";
          type = (types.nullOr types.str);
        };
        "tty" = mkOption {
          description = "Whether this container should allocate a TTY for itself, also requires 'stdin' to be true.\nDefault is false.";
          type = (types.nullOr types.bool);
        };
        "volumeDevices" = mkOption {
          description = "volumeDevices is the list of block devices to be used by the container.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersVolumeDevices"
                "name"
                [ "devicePath" ]
            )
          );
          apply = attrsToList;
        };
        "volumeMounts" = mkOption {
          description = "Pod volumes to mount into the container's filesystem.\nCannot be updated.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersVolumeMounts"
                "name"
                [ "mountPath" ]
            )
          );
          apply = attrsToList;
        };
        "workingDir" = mkOption {
          description = "Container's working directory.\nIf not specified, the container runtime's default will be used, which\nmight be configured in the container image.\nCannot be updated.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "args" = mkOverride 1002 null;
        "command" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "envFrom" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "imagePullPolicy" = mkOverride 1002 null;
        "lifecycle" = mkOverride 1002 null;
        "livenessProbe" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
        "readinessProbe" = mkOverride 1002 null;
        "resizePolicy" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "restartPolicy" = mkOverride 1002 null;
        "restartPolicyRules" = mkOverride 1002 null;
        "securityContext" = mkOverride 1002 null;
        "startupProbe" = mkOverride 1002 null;
        "stdin" = mkOverride 1002 null;
        "stdinOnce" = mkOverride 1002 null;
        "terminationMessagePath" = mkOverride 1002 null;
        "terminationMessagePolicy" = mkOverride 1002 null;
        "tty" = mkOverride 1002 null;
        "volumeDevices" = mkOverride 1002 null;
        "volumeMounts" = mkOverride 1002 null;
        "workingDir" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnv" = {

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
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvValueFrom")
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvFrom" = {

      options = {
        "configMapRef" = mkOption {
          description = "The ConfigMap to select from";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvFromConfigMapRef"
            )
          );
        };
        "prefix" = mkOption {
          description = "Optional text to prepend to the name of each environment variable.\nMay consist of any printable ASCII characters except '='.";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description = "The Secret to select from";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvFromSecretRef")
          );
        };
      };

      config = {
        "configMapRef" = mkOverride 1002 null;
        "prefix" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvFromConfigMapRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvFromSecretRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "Selects a key of a ConfigMap.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "Selects a field of the pod: supports metadata.name, metadata.namespace, `metadata.labels['<KEY>']`, `metadata.annotations['<KEY>']`,\nspec.nodeName, spec.serviceAccountName, status.hostIP, status.podIP, status.podIPs.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvValueFromFieldRef"
            )
          );
        };
        "fileKeyRef" = mkOption {
          description = "FileKeyRef selects a key of the env file.\nRequires the EnvFiles feature gate to be enabled.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvValueFromFileKeyRef"
            )
          );
        };
        "resourceFieldRef" = mkOption {
          description = "Selects a resource of the container: only resources limits and requests\n(limits.cpu, limits.memory, limits.ephemeral-storage, requests.cpu, requests.memory and requests.ephemeral-storage) are currently supported.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "Selects a key of a secret in the pod's namespace";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvValueFromSecretKeyRef"
            )
          );
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvValueFromConfigMapKeyRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvValueFromFieldRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvValueFromFileKeyRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvValueFromResourceFieldRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersEnvValueFromSecretKeyRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecycle" = {

      options = {
        "postStart" = mkOption {
          description = "PostStart is called immediately after a container is created. If the handler fails,\nthe container is terminated and restarted according to its restart policy.\nOther management of the container blocks until the hook completes.\nMore info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePostStart"
            )
          );
        };
        "preStop" = mkOption {
          description = "PreStop is called immediately before a container is terminated due to an\nAPI request or management event such as liveness/startup probe failure,\npreemption, resource contention, etc. The handler is not called if the\ncontainer crashes or exits. The Pod's termination grace period countdown begins before the\nPreStop hook is executed. Regardless of the outcome of the handler, the\ncontainer will eventually terminate within the Pod's termination grace\nperiod (unless delayed by finalizers). Other management of the container blocks until the hook completes\nor until the termination grace period is reached.\nMore info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePreStop")
          );
        };
        "stopSignal" = mkOption {
          description = "StopSignal defines which signal will be sent to a container when it is being stopped.\nIf not specified, the default is defined by the container runtime in use.\nStopSignal can only be set for Pods with a non-empty .spec.os.name";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "postStart" = mkOverride 1002 null;
        "preStop" = mkOverride 1002 null;
        "stopSignal" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePostStart" = {

      options = {
        "exec" = mkOption {
          description = "Exec specifies a command to execute in the container.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePostStartExec"
            )
          );
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies an HTTP GET request to perform.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePostStartHttpGet"
            )
          );
        };
        "sleep" = mkOption {
          description = "Sleep represents a duration that the container should sleep.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePostStartSleep"
            )
          );
        };
        "tcpSocket" = mkOption {
          description = "Deprecated. TCPSocket is NOT supported as a LifecycleHandler and kept\nfor backward compatibility. There is no validation of this field and\nlifecycle hooks will fail at runtime when it is specified.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePostStartTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePostStartExec" = {

      options = {
        "command" = mkOption {
          description = "Command is the command line to execute inside the container, the working directory for the\ncommand  is root ('/') in the container's filesystem. The command is simply exec'd, it is\nnot run inside a shell, so traditional shell instructions ('|', etc) won't work. To use\na shell, you need to explicitly call out to that shell.\nExit status of 0 is treated as live/healthy and non-zero is unhealthy.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePostStartHttpGet" = {

      options = {
        "host" = mkOption {
          description = "Host name to connect to, defaults to the pod IP. You probably want to set\n\"Host\" in httpHeaders instead.";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "Custom headers to set in the request. HTTP allows repeated headers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePostStartHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "Path to access on the HTTP server.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Name or number of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "Scheme to use for connecting to the host.\nDefaults to HTTP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePostStartHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "The header field name.\nThis will be canonicalized upon output, so case-variant names will be understood as the same header.";
          type = types.str;
        };
        "value" = mkOption {
          description = "The header field value";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePostStartSleep" = {

      options = {
        "seconds" = mkOption {
          description = "Seconds is the number of seconds to sleep.";
          type = types.int;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePostStartTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "Optional: Host name to connect to, defaults to the pod IP.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Number or name of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePreStop" = {

      options = {
        "exec" = mkOption {
          description = "Exec specifies a command to execute in the container.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePreStopExec"
            )
          );
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies an HTTP GET request to perform.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePreStopHttpGet"
            )
          );
        };
        "sleep" = mkOption {
          description = "Sleep represents a duration that the container should sleep.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePreStopSleep"
            )
          );
        };
        "tcpSocket" = mkOption {
          description = "Deprecated. TCPSocket is NOT supported as a LifecycleHandler and kept\nfor backward compatibility. There is no validation of this field and\nlifecycle hooks will fail at runtime when it is specified.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePreStopTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePreStopExec" = {

      options = {
        "command" = mkOption {
          description = "Command is the command line to execute inside the container, the working directory for the\ncommand  is root ('/') in the container's filesystem. The command is simply exec'd, it is\nnot run inside a shell, so traditional shell instructions ('|', etc) won't work. To use\na shell, you need to explicitly call out to that shell.\nExit status of 0 is treated as live/healthy and non-zero is unhealthy.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePreStopHttpGet" = {

      options = {
        "host" = mkOption {
          description = "Host name to connect to, defaults to the pod IP. You probably want to set\n\"Host\" in httpHeaders instead.";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "Custom headers to set in the request. HTTP allows repeated headers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePreStopHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "Path to access on the HTTP server.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Name or number of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "Scheme to use for connecting to the host.\nDefaults to HTTP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePreStopHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "The header field name.\nThis will be canonicalized upon output, so case-variant names will be understood as the same header.";
          type = types.str;
        };
        "value" = mkOption {
          description = "The header field value";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePreStopSleep" = {

      options = {
        "seconds" = mkOption {
          description = "Seconds is the number of seconds to sleep.";
          type = types.int;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLifecyclePreStopTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "Optional: Host name to connect to, defaults to the pod IP.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Number or name of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLivenessProbe" = {

      options = {
        "exec" = mkOption {
          description = "Exec specifies a command to execute in the container.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLivenessProbeExec")
          );
        };
        "failureThreshold" = mkOption {
          description = "Minimum consecutive failures for the probe to be considered failed after having succeeded.\nDefaults to 3. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "GRPC specifies a GRPC HealthCheckRequest.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLivenessProbeGrpc")
          );
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies an HTTP GET request to perform.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLivenessProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "Number of seconds after the container has started before liveness probes are initiated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "How often (in seconds) to perform the probe.\nDefault to 10 seconds. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "Minimum consecutive successes for the probe to be considered successful after having failed.\nDefaults to 1. Must be 1 for liveness and startup. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "TCPSocket specifies a connection to a TCP port.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLivenessProbeTcpSocket"
            )
          );
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
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLivenessProbeExec" = {

      options = {
        "command" = mkOption {
          description = "Command is the command line to execute inside the container, the working directory for the\ncommand  is root ('/') in the container's filesystem. The command is simply exec'd, it is\nnot run inside a shell, so traditional shell instructions ('|', etc) won't work. To use\na shell, you need to explicitly call out to that shell.\nExit status of 0 is treated as live/healthy and non-zero is unhealthy.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLivenessProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "Port number of the gRPC service. Number must be in the range 1 to 65535.";
          type = types.int;
        };
        "service" = mkOption {
          description = "Service is the name of the service to place in the gRPC HealthCheckRequest\n(see https://github.com/grpc/grpc/blob/master/doc/health-checking.md).\n\nIf this is not specified, the default behavior is defined by gRPC.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLivenessProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "Host name to connect to, defaults to the pod IP. You probably want to set\n\"Host\" in httpHeaders instead.";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "Custom headers to set in the request. HTTP allows repeated headers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLivenessProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "Path to access on the HTTP server.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Name or number of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "Scheme to use for connecting to the host.\nDefaults to HTTP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLivenessProbeHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "The header field name.\nThis will be canonicalized upon output, so case-variant names will be understood as the same header.";
          type = types.str;
        };
        "value" = mkOption {
          description = "The header field value";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersLivenessProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "Optional: Host name to connect to, defaults to the pod IP.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Number or name of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersPorts" = {

      options = {
        "containerPort" = mkOption {
          description = "Number of port to expose on the pod's IP address.\nThis must be a valid port number, 0 < x < 65536.";
          type = types.int;
        };
        "hostIP" = mkOption {
          description = "What host IP to bind the external port to.";
          type = (types.nullOr types.str);
        };
        "hostPort" = mkOption {
          description = "Number of port to expose on the host.\nIf specified, this must be a valid port number, 0 < x < 65536.\nIf HostNetwork is specified, this must match ContainerPort.\nMost containers do not need this.";
          type = (types.nullOr types.int);
        };
        "name" = mkOption {
          description = "If specified, this must be an IANA_SVC_NAME and unique within the pod. Each\nnamed port in a pod must have a unique name. Name for the port that can be\nreferred to by services.";
          type = (types.nullOr types.str);
        };
        "protocol" = mkOption {
          description = "Protocol for port. Must be UDP, TCP, or SCTP.\nDefaults to \"TCP\".";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "hostIP" = mkOverride 1002 null;
        "hostPort" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersReadinessProbe" = {

      options = {
        "exec" = mkOption {
          description = "Exec specifies a command to execute in the container.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersReadinessProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "Minimum consecutive failures for the probe to be considered failed after having succeeded.\nDefaults to 3. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "GRPC specifies a GRPC HealthCheckRequest.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersReadinessProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies an HTTP GET request to perform.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersReadinessProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "Number of seconds after the container has started before liveness probes are initiated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "How often (in seconds) to perform the probe.\nDefault to 10 seconds. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "Minimum consecutive successes for the probe to be considered successful after having failed.\nDefaults to 1. Must be 1 for liveness and startup. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "TCPSocket specifies a connection to a TCP port.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersReadinessProbeTcpSocket"
            )
          );
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
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersReadinessProbeExec" = {

      options = {
        "command" = mkOption {
          description = "Command is the command line to execute inside the container, the working directory for the\ncommand  is root ('/') in the container's filesystem. The command is simply exec'd, it is\nnot run inside a shell, so traditional shell instructions ('|', etc) won't work. To use\na shell, you need to explicitly call out to that shell.\nExit status of 0 is treated as live/healthy and non-zero is unhealthy.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersReadinessProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "Port number of the gRPC service. Number must be in the range 1 to 65535.";
          type = types.int;
        };
        "service" = mkOption {
          description = "Service is the name of the service to place in the gRPC HealthCheckRequest\n(see https://github.com/grpc/grpc/blob/master/doc/health-checking.md).\n\nIf this is not specified, the default behavior is defined by gRPC.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersReadinessProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "Host name to connect to, defaults to the pod IP. You probably want to set\n\"Host\" in httpHeaders instead.";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "Custom headers to set in the request. HTTP allows repeated headers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersReadinessProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "Path to access on the HTTP server.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Name or number of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "Scheme to use for connecting to the host.\nDefaults to HTTP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersReadinessProbeHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "The header field name.\nThis will be canonicalized upon output, so case-variant names will be understood as the same header.";
          type = types.str;
        };
        "value" = mkOption {
          description = "The header field value";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersReadinessProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "Optional: Host name to connect to, defaults to the pod IP.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Number or name of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersResizePolicy" = {

      options = {
        "resourceName" = mkOption {
          description = "Name of the resource to which this resource resize policy applies.\nSupported values: cpu, memory.";
          type = types.str;
        };
        "restartPolicy" = mkOption {
          description = "Restart policy to apply when specified resource is resized.\nIf not specified, it defaults to NotRequired.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersResources" = {

      options = {
        "claims" = mkOption {
          description = "Claims lists the names of resources, defined in spec.resourceClaims,\nthat are used by this container.\n\nThis field depends on the\nDynamicResourceAllocation feature gate.\n\nThis field is immutable. It can only be set for containers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersResourcesClaims"
                "name"
                [ "name" ]
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersResourcesClaims" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersRestartPolicyRules" = {

      options = {
        "action" = mkOption {
          description = "Specifies the action taken on a container exit if the requirements\nare satisfied. The only possible value is \"Restart\" to restart the\ncontainer.";
          type = types.str;
        };
        "exitCodes" = mkOption {
          description = "Represents the exit codes to check on container exits.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersRestartPolicyRulesExitCodes"
            )
          );
        };
      };

      config = {
        "exitCodes" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersRestartPolicyRulesExitCodes" = {

      options = {
        "operator" = mkOption {
          description = "Represents the relationship between the container exit code(s) and the\nspecified values. Possible values are:\n- In: the requirement is satisfied if the container exit code is in the\n  set of specified values.\n- NotIn: the requirement is satisfied if the container exit code is\n  not in the set of specified values.";
          type = types.str;
        };
        "values" = mkOption {
          description = "Specifies the set of values to check for container exit codes.\nAt most 255 elements are allowed.";
          type = (types.nullOr (types.listOf types.int));
        };
      };

      config = {
        "values" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersSecurityContext" = {

      options = {
        "allowPrivilegeEscalation" = mkOption {
          description = "AllowPrivilegeEscalation controls whether a process can gain more\nprivileges than its parent process. This bool directly controls if\nthe no_new_privs flag will be set on the container process.\nAllowPrivilegeEscalation is true always when the container is:\n1) run as Privileged\n2) has CAP_SYS_ADMIN\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr types.bool);
        };
        "appArmorProfile" = mkOption {
          description = "appArmorProfile is the AppArmor options to use by this container. If set, this profile\noverrides the pod's appArmorProfile.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersSecurityContextAppArmorProfile"
            )
          );
        };
        "capabilities" = mkOption {
          description = "The capabilities to add/drop when running containers.\nDefaults to the default set of capabilities granted by the container runtime.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersSecurityContextCapabilities"
            )
          );
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
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersSecurityContextSeLinuxOptions"
            )
          );
        };
        "seccompProfile" = mkOption {
          description = "The seccomp options to use by this container. If seccomp options are\nprovided at both the pod & container level, the container options\noverride the pod options.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersSecurityContextSeccompProfile"
            )
          );
        };
        "windowsOptions" = mkOption {
          description = "The Windows specific settings applied to all containers.\nIf unspecified, the options from the PodSecurityContext will be used.\nIf set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.\nNote that this field cannot be set when spec.os.name is linux.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersSecurityContextWindowsOptions"
            )
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersSecurityContextAppArmorProfile" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersSecurityContextCapabilities" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersSecurityContextSeLinuxOptions" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersSecurityContextSeccompProfile" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersSecurityContextWindowsOptions" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersStartupProbe" = {

      options = {
        "exec" = mkOption {
          description = "Exec specifies a command to execute in the container.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersStartupProbeExec")
          );
        };
        "failureThreshold" = mkOption {
          description = "Minimum consecutive failures for the probe to be considered failed after having succeeded.\nDefaults to 3. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "GRPC specifies a GRPC HealthCheckRequest.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersStartupProbeGrpc")
          );
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies an HTTP GET request to perform.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersStartupProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "Number of seconds after the container has started before liveness probes are initiated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "How often (in seconds) to perform the probe.\nDefault to 10 seconds. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "Minimum consecutive successes for the probe to be considered successful after having failed.\nDefaults to 1. Must be 1 for liveness and startup. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "TCPSocket specifies a connection to a TCP port.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersStartupProbeTcpSocket"
            )
          );
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
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersStartupProbeExec" = {

      options = {
        "command" = mkOption {
          description = "Command is the command line to execute inside the container, the working directory for the\ncommand  is root ('/') in the container's filesystem. The command is simply exec'd, it is\nnot run inside a shell, so traditional shell instructions ('|', etc) won't work. To use\na shell, you need to explicitly call out to that shell.\nExit status of 0 is treated as live/healthy and non-zero is unhealthy.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersStartupProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "Port number of the gRPC service. Number must be in the range 1 to 65535.";
          type = types.int;
        };
        "service" = mkOption {
          description = "Service is the name of the service to place in the gRPC HealthCheckRequest\n(see https://github.com/grpc/grpc/blob/master/doc/health-checking.md).\n\nIf this is not specified, the default behavior is defined by gRPC.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersStartupProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "Host name to connect to, defaults to the pod IP. You probably want to set\n\"Host\" in httpHeaders instead.";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "Custom headers to set in the request. HTTP allows repeated headers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersStartupProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "Path to access on the HTTP server.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Name or number of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "Scheme to use for connecting to the host.\nDefaults to HTTP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersStartupProbeHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "The header field name.\nThis will be canonicalized upon output, so case-variant names will be understood as the same header.";
          type = types.str;
        };
        "value" = mkOption {
          description = "The header field value";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersStartupProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "Optional: Host name to connect to, defaults to the pod IP.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Number or name of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersVolumeDevices" = {

      options = {
        "devicePath" = mkOption {
          description = "devicePath is the path inside of the container that the device will be mapped to.";
          type = types.str;
        };
        "name" = mkOption {
          description = "name must match the name of a persistentVolumeClaim in the pod";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecContainersVolumeMounts" = {

      options = {
        "mountPath" = mkOption {
          description = "Path within the container at which the volume should be mounted.  Must\nnot contain ':'.";
          type = types.str;
        };
        "mountPropagation" = mkOption {
          description = "mountPropagation determines how mounts are propagated from the host\nto container and the other way around.\nWhen not set, MountPropagationNone is used.\nThis field is beta in 1.10.\nWhen RecursiveReadOnly is set to IfPossible or to Enabled, MountPropagation must be None or unspecified\n(which defaults to None).";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "This must match the Name of a Volume.";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "Mounted read-only if true, read-write otherwise (false or unspecified).\nDefaults to false.";
          type = (types.nullOr types.bool);
        };
        "recursiveReadOnly" = mkOption {
          description = "RecursiveReadOnly specifies whether read-only mounts should be handled\nrecursively.\n\nIf ReadOnly is false, this field has no meaning and must be unspecified.\n\nIf ReadOnly is true, and this field is set to Disabled, the mount is not made\nrecursively read-only.  If this field is set to IfPossible, the mount is made\nrecursively read-only, if it is supported by the container runtime.  If this\nfield is set to Enabled, the mount is made recursively read-only if it is\nsupported by the container runtime, otherwise the pod will not be started and\nan error will be generated to indicate the reason.\n\nIf this field is set to IfPossible or Enabled, MountPropagation must be set to\nNone (or be unspecified, which defaults to None).\n\nIf this field is not specified, it is treated as an equivalent of Disabled.";
          type = (types.nullOr types.str);
        };
        "subPath" = mkOption {
          description = "Path within the volume from which the container's volume should be mounted.\nDefaults to \"\" (volume's root).";
          type = (types.nullOr types.str);
        };
        "subPathExpr" = mkOption {
          description = "Expanded path within the volume from which the container's volume should be mounted.\nBehaves similarly to SubPath but environment variable references $(VAR_NAME) are expanded using the container's environment.\nDefaults to \"\" (volume's root).\nSubPathExpr and SubPath are mutually exclusive.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "mountPropagation" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "recursiveReadOnly" = mkOverride 1002 null;
        "subPath" = mkOverride 1002 null;
        "subPathExpr" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecDnsConfig" = {

      options = {
        "nameservers" = mkOption {
          description = "A list of DNS name server IP addresses.\nThis will be appended to the base nameservers generated from DNSPolicy.\nDuplicated nameservers will be removed.";
          type = (types.nullOr (types.listOf types.str));
        };
        "options" = mkOption {
          description = "A list of DNS resolver options.\nThis will be merged with the base options generated from DNSPolicy.\nDuplicated entries will be removed. Resolution options given in Options\nwill override those that appear in the base DNSPolicy.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecDnsConfigOptions"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "searches" = mkOption {
          description = "A list of DNS search domains for host-name lookup.\nThis will be appended to the base search paths generated from DNSPolicy.\nDuplicated search paths will be removed.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "nameservers" = mkOverride 1002 null;
        "options" = mkOverride 1002 null;
        "searches" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecDnsConfigOptions" = {

      options = {
        "name" = mkOption {
          description = "Name is this DNS resolver option's name.\nRequired.";
          type = (types.nullOr types.str);
        };
        "value" = mkOption {
          description = "Value is this DNS resolver option's value.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "value" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainers" = {

      options = {
        "args" = mkOption {
          description = "Arguments to the entrypoint.\nThe image's CMD is used if this is not provided.\nVariable references $(VAR_NAME) are expanded using the container's environment. If a variable\ncannot be resolved, the reference in the input string will be unchanged. Double $$ are reduced\nto a single $, which allows for escaping the $(VAR_NAME) syntax: i.e. \"$$(VAR_NAME)\" will\nproduce the string literal \"$(VAR_NAME)\". Escaped references will never be expanded, regardless\nof whether the variable exists or not. Cannot be updated.\nMore info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell";
          type = (types.nullOr (types.listOf types.str));
        };
        "command" = mkOption {
          description = "Entrypoint array. Not executed within a shell.\nThe image's ENTRYPOINT is used if this is not provided.\nVariable references $(VAR_NAME) are expanded using the container's environment. If a variable\ncannot be resolved, the reference in the input string will be unchanged. Double $$ are reduced\nto a single $, which allows for escaping the $(VAR_NAME) syntax: i.e. \"$$(VAR_NAME)\" will\nproduce the string literal \"$(VAR_NAME)\". Escaped references will never be expanded, regardless\nof whether the variable exists or not. Cannot be updated.\nMore info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell";
          type = (types.nullOr (types.listOf types.str));
        };
        "env" = mkOption {
          description = "List of environment variables to set in the container.\nCannot be updated.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnv"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "envFrom" = mkOption {
          description = "List of sources to populate environment variables in the container.\nThe keys defined within a source may consist of any printable ASCII characters except '='.\nWhen a key exists in multiple\nsources, the value associated with the last source will take precedence.\nValues defined by an Env with a duplicate key will take precedence.\nCannot be updated.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvFrom")
            )
          );
        };
        "image" = mkOption {
          description = "Container image name.\nMore info: https://kubernetes.io/docs/concepts/containers/images";
          type = (types.nullOr types.str);
        };
        "imagePullPolicy" = mkOption {
          description = "Image pull policy.\nOne of Always, Never, IfNotPresent.\nDefaults to Always if :latest tag is specified, or IfNotPresent otherwise.\nCannot be updated.\nMore info: https://kubernetes.io/docs/concepts/containers/images#updating-images";
          type = (types.nullOr types.str);
        };
        "lifecycle" = mkOption {
          description = "Lifecycle is not allowed for ephemeral containers.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecycle"
            )
          );
        };
        "livenessProbe" = mkOption {
          description = "Probes are not allowed for ephemeral containers.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLivenessProbe"
            )
          );
        };
        "name" = mkOption {
          description = "Name of the ephemeral container specified as a DNS_LABEL.\nThis name must be unique among all containers, init containers and ephemeral containers.";
          type = types.str;
        };
        "ports" = mkOption {
          description = "Ports are not allowed for ephemeral containers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersPorts"
                "name"
                [
                  "containerPort"
                  "protocol"
                ]
            )
          );
          apply = attrsToList;
        };
        "readinessProbe" = mkOption {
          description = "Probes are not allowed for ephemeral containers.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersReadinessProbe"
            )
          );
        };
        "resizePolicy" = mkOption {
          description = "Resources resize policy for the container.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersResizePolicy"
              )
            )
          );
        };
        "resources" = mkOption {
          description = "Resources are not allowed for ephemeral containers. Ephemeral containers use spare resources\nalready allocated to the pod.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersResources"
            )
          );
        };
        "restartPolicy" = mkOption {
          description = "Restart policy for the container to manage the restart behavior of each\ncontainer within a pod.\nYou cannot set this field on ephemeral containers.";
          type = (types.nullOr types.str);
        };
        "restartPolicyRules" = mkOption {
          description = "Represents a list of rules to be checked to determine if the\ncontainer should be restarted on exit. You cannot set this field on\nephemeral containers.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersRestartPolicyRules"
              )
            )
          );
        };
        "securityContext" = mkOption {
          description = "Optional: SecurityContext defines the security options the ephemeral container should be run with.\nIf set, the fields of SecurityContext override the equivalent fields of PodSecurityContext.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersSecurityContext"
            )
          );
        };
        "startupProbe" = mkOption {
          description = "Probes are not allowed for ephemeral containers.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersStartupProbe"
            )
          );
        };
        "stdin" = mkOption {
          description = "Whether this container should allocate a buffer for stdin in the container runtime. If this\nis not set, reads from stdin in the container will always result in EOF.\nDefault is false.";
          type = (types.nullOr types.bool);
        };
        "stdinOnce" = mkOption {
          description = "Whether the container runtime should close the stdin channel after it has been opened by\na single attach. When stdin is true the stdin stream will remain open across multiple attach\nsessions. If stdinOnce is set to true, stdin is opened on container start, is empty until the\nfirst client attaches to stdin, and then remains open and accepts data until the client disconnects,\nat which time stdin is closed and remains closed until the container is restarted. If this\nflag is false, a container processes that reads from stdin will never receive an EOF.\nDefault is false";
          type = (types.nullOr types.bool);
        };
        "targetContainerName" = mkOption {
          description = "If set, the name of the container from PodSpec that this ephemeral container targets.\nThe ephemeral container will be run in the namespaces (IPC, PID, etc) of this container.\nIf not set then the ephemeral container uses the namespaces configured in the Pod spec.\n\nThe container runtime must implement support for this feature. If the runtime does not\nsupport namespace targeting then the result of setting this field is undefined.";
          type = (types.nullOr types.str);
        };
        "terminationMessagePath" = mkOption {
          description = "Optional: Path at which the file to which the container's termination message\nwill be written is mounted into the container's filesystem.\nMessage written is intended to be brief final status, such as an assertion failure message.\nWill be truncated by the node if greater than 4096 bytes. The total message length across\nall containers will be limited to 12kb.\nDefaults to /dev/termination-log.\nCannot be updated.";
          type = (types.nullOr types.str);
        };
        "terminationMessagePolicy" = mkOption {
          description = "Indicate how the termination message should be populated. File will use the contents of\nterminationMessagePath to populate the container status message on both success and failure.\nFallbackToLogsOnError will use the last chunk of container log output if the termination\nmessage file is empty and the container exited with an error.\nThe log output is limited to 2048 bytes or 80 lines, whichever is smaller.\nDefaults to File.\nCannot be updated.";
          type = (types.nullOr types.str);
        };
        "tty" = mkOption {
          description = "Whether this container should allocate a TTY for itself, also requires 'stdin' to be true.\nDefault is false.";
          type = (types.nullOr types.bool);
        };
        "volumeDevices" = mkOption {
          description = "volumeDevices is the list of block devices to be used by the container.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersVolumeDevices"
                "name"
                [ "devicePath" ]
            )
          );
          apply = attrsToList;
        };
        "volumeMounts" = mkOption {
          description = "Pod volumes to mount into the container's filesystem. Subpath mounts are not allowed for ephemeral containers.\nCannot be updated.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersVolumeMounts"
                "name"
                [ "mountPath" ]
            )
          );
          apply = attrsToList;
        };
        "workingDir" = mkOption {
          description = "Container's working directory.\nIf not specified, the container runtime's default will be used, which\nmight be configured in the container image.\nCannot be updated.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "args" = mkOverride 1002 null;
        "command" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "envFrom" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "imagePullPolicy" = mkOverride 1002 null;
        "lifecycle" = mkOverride 1002 null;
        "livenessProbe" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
        "readinessProbe" = mkOverride 1002 null;
        "resizePolicy" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "restartPolicy" = mkOverride 1002 null;
        "restartPolicyRules" = mkOverride 1002 null;
        "securityContext" = mkOverride 1002 null;
        "startupProbe" = mkOverride 1002 null;
        "stdin" = mkOverride 1002 null;
        "stdinOnce" = mkOverride 1002 null;
        "targetContainerName" = mkOverride 1002 null;
        "terminationMessagePath" = mkOverride 1002 null;
        "terminationMessagePolicy" = mkOverride 1002 null;
        "tty" = mkOverride 1002 null;
        "volumeDevices" = mkOverride 1002 null;
        "volumeMounts" = mkOverride 1002 null;
        "workingDir" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnv" = {

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
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvValueFrom"
            )
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvFrom" = {

      options = {
        "configMapRef" = mkOption {
          description = "The ConfigMap to select from";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvFromConfigMapRef"
            )
          );
        };
        "prefix" = mkOption {
          description = "Optional text to prepend to the name of each environment variable.\nMay consist of any printable ASCII characters except '='.";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description = "The Secret to select from";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvFromSecretRef"
            )
          );
        };
      };

      config = {
        "configMapRef" = mkOverride 1002 null;
        "prefix" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvFromConfigMapRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvFromSecretRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "Selects a key of a ConfigMap.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "Selects a field of the pod: supports metadata.name, metadata.namespace, `metadata.labels['<KEY>']`, `metadata.annotations['<KEY>']`,\nspec.nodeName, spec.serviceAccountName, status.hostIP, status.podIP, status.podIPs.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvValueFromFieldRef"
            )
          );
        };
        "fileKeyRef" = mkOption {
          description = "FileKeyRef selects a key of the env file.\nRequires the EnvFiles feature gate to be enabled.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvValueFromFileKeyRef"
            )
          );
        };
        "resourceFieldRef" = mkOption {
          description = "Selects a resource of the container: only resources limits and requests\n(limits.cpu, limits.memory, limits.ephemeral-storage, requests.cpu, requests.memory and requests.ephemeral-storage) are currently supported.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "Selects a key of a secret in the pod's namespace";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvValueFromSecretKeyRef"
            )
          );
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvValueFromConfigMapKeyRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvValueFromFieldRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvValueFromFileKeyRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvValueFromResourceFieldRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersEnvValueFromSecretKeyRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecycle" = {

      options = {
        "postStart" = mkOption {
          description = "PostStart is called immediately after a container is created. If the handler fails,\nthe container is terminated and restarted according to its restart policy.\nOther management of the container blocks until the hook completes.\nMore info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePostStart"
            )
          );
        };
        "preStop" = mkOption {
          description = "PreStop is called immediately before a container is terminated due to an\nAPI request or management event such as liveness/startup probe failure,\npreemption, resource contention, etc. The handler is not called if the\ncontainer crashes or exits. The Pod's termination grace period countdown begins before the\nPreStop hook is executed. Regardless of the outcome of the handler, the\ncontainer will eventually terminate within the Pod's termination grace\nperiod (unless delayed by finalizers). Other management of the container blocks until the hook completes\nor until the termination grace period is reached.\nMore info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePreStop"
            )
          );
        };
        "stopSignal" = mkOption {
          description = "StopSignal defines which signal will be sent to a container when it is being stopped.\nIf not specified, the default is defined by the container runtime in use.\nStopSignal can only be set for Pods with a non-empty .spec.os.name";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "postStart" = mkOverride 1002 null;
        "preStop" = mkOverride 1002 null;
        "stopSignal" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePostStart" = {

      options = {
        "exec" = mkOption {
          description = "Exec specifies a command to execute in the container.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePostStartExec"
            )
          );
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies an HTTP GET request to perform.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePostStartHttpGet"
            )
          );
        };
        "sleep" = mkOption {
          description = "Sleep represents a duration that the container should sleep.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePostStartSleep"
            )
          );
        };
        "tcpSocket" = mkOption {
          description = "Deprecated. TCPSocket is NOT supported as a LifecycleHandler and kept\nfor backward compatibility. There is no validation of this field and\nlifecycle hooks will fail at runtime when it is specified.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePostStartTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePostStartExec" = {

      options = {
        "command" = mkOption {
          description = "Command is the command line to execute inside the container, the working directory for the\ncommand  is root ('/') in the container's filesystem. The command is simply exec'd, it is\nnot run inside a shell, so traditional shell instructions ('|', etc) won't work. To use\na shell, you need to explicitly call out to that shell.\nExit status of 0 is treated as live/healthy and non-zero is unhealthy.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePostStartHttpGet" = {

      options = {
        "host" = mkOption {
          description = "Host name to connect to, defaults to the pod IP. You probably want to set\n\"Host\" in httpHeaders instead.";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "Custom headers to set in the request. HTTP allows repeated headers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePostStartHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "Path to access on the HTTP server.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Name or number of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "Scheme to use for connecting to the host.\nDefaults to HTTP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePostStartHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "The header field name.\nThis will be canonicalized upon output, so case-variant names will be understood as the same header.";
            type = types.str;
          };
          "value" = mkOption {
            description = "The header field value";
            type = types.str;
          };
        };

        config = { };

      };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePostStartSleep" = {

      options = {
        "seconds" = mkOption {
          description = "Seconds is the number of seconds to sleep.";
          type = types.int;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePostStartTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "Optional: Host name to connect to, defaults to the pod IP.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Number or name of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePreStop" = {

      options = {
        "exec" = mkOption {
          description = "Exec specifies a command to execute in the container.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePreStopExec"
            )
          );
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies an HTTP GET request to perform.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePreStopHttpGet"
            )
          );
        };
        "sleep" = mkOption {
          description = "Sleep represents a duration that the container should sleep.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePreStopSleep"
            )
          );
        };
        "tcpSocket" = mkOption {
          description = "Deprecated. TCPSocket is NOT supported as a LifecycleHandler and kept\nfor backward compatibility. There is no validation of this field and\nlifecycle hooks will fail at runtime when it is specified.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePreStopTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePreStopExec" = {

      options = {
        "command" = mkOption {
          description = "Command is the command line to execute inside the container, the working directory for the\ncommand  is root ('/') in the container's filesystem. The command is simply exec'd, it is\nnot run inside a shell, so traditional shell instructions ('|', etc) won't work. To use\na shell, you need to explicitly call out to that shell.\nExit status of 0 is treated as live/healthy and non-zero is unhealthy.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePreStopHttpGet" = {

      options = {
        "host" = mkOption {
          description = "Host name to connect to, defaults to the pod IP. You probably want to set\n\"Host\" in httpHeaders instead.";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "Custom headers to set in the request. HTTP allows repeated headers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePreStopHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "Path to access on the HTTP server.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Name or number of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "Scheme to use for connecting to the host.\nDefaults to HTTP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePreStopHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "The header field name.\nThis will be canonicalized upon output, so case-variant names will be understood as the same header.";
            type = types.str;
          };
          "value" = mkOption {
            description = "The header field value";
            type = types.str;
          };
        };

        config = { };

      };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePreStopSleep" = {

      options = {
        "seconds" = mkOption {
          description = "Seconds is the number of seconds to sleep.";
          type = types.int;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLifecyclePreStopTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "Optional: Host name to connect to, defaults to the pod IP.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Number or name of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLivenessProbe" = {

      options = {
        "exec" = mkOption {
          description = "Exec specifies a command to execute in the container.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLivenessProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "Minimum consecutive failures for the probe to be considered failed after having succeeded.\nDefaults to 3. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "GRPC specifies a GRPC HealthCheckRequest.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLivenessProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies an HTTP GET request to perform.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLivenessProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "Number of seconds after the container has started before liveness probes are initiated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "How often (in seconds) to perform the probe.\nDefault to 10 seconds. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "Minimum consecutive successes for the probe to be considered successful after having failed.\nDefaults to 1. Must be 1 for liveness and startup. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "TCPSocket specifies a connection to a TCP port.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLivenessProbeTcpSocket"
            )
          );
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
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLivenessProbeExec" = {

      options = {
        "command" = mkOption {
          description = "Command is the command line to execute inside the container, the working directory for the\ncommand  is root ('/') in the container's filesystem. The command is simply exec'd, it is\nnot run inside a shell, so traditional shell instructions ('|', etc) won't work. To use\na shell, you need to explicitly call out to that shell.\nExit status of 0 is treated as live/healthy and non-zero is unhealthy.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLivenessProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "Port number of the gRPC service. Number must be in the range 1 to 65535.";
          type = types.int;
        };
        "service" = mkOption {
          description = "Service is the name of the service to place in the gRPC HealthCheckRequest\n(see https://github.com/grpc/grpc/blob/master/doc/health-checking.md).\n\nIf this is not specified, the default behavior is defined by gRPC.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLivenessProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "Host name to connect to, defaults to the pod IP. You probably want to set\n\"Host\" in httpHeaders instead.";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "Custom headers to set in the request. HTTP allows repeated headers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLivenessProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "Path to access on the HTTP server.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Name or number of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "Scheme to use for connecting to the host.\nDefaults to HTTP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLivenessProbeHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "The header field name.\nThis will be canonicalized upon output, so case-variant names will be understood as the same header.";
          type = types.str;
        };
        "value" = mkOption {
          description = "The header field value";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersLivenessProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "Optional: Host name to connect to, defaults to the pod IP.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Number or name of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersPorts" = {

      options = {
        "containerPort" = mkOption {
          description = "Number of port to expose on the pod's IP address.\nThis must be a valid port number, 0 < x < 65536.";
          type = types.int;
        };
        "hostIP" = mkOption {
          description = "What host IP to bind the external port to.";
          type = (types.nullOr types.str);
        };
        "hostPort" = mkOption {
          description = "Number of port to expose on the host.\nIf specified, this must be a valid port number, 0 < x < 65536.\nIf HostNetwork is specified, this must match ContainerPort.\nMost containers do not need this.";
          type = (types.nullOr types.int);
        };
        "name" = mkOption {
          description = "If specified, this must be an IANA_SVC_NAME and unique within the pod. Each\nnamed port in a pod must have a unique name. Name for the port that can be\nreferred to by services.";
          type = (types.nullOr types.str);
        };
        "protocol" = mkOption {
          description = "Protocol for port. Must be UDP, TCP, or SCTP.\nDefaults to \"TCP\".";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "hostIP" = mkOverride 1002 null;
        "hostPort" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersReadinessProbe" = {

      options = {
        "exec" = mkOption {
          description = "Exec specifies a command to execute in the container.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersReadinessProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "Minimum consecutive failures for the probe to be considered failed after having succeeded.\nDefaults to 3. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "GRPC specifies a GRPC HealthCheckRequest.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersReadinessProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies an HTTP GET request to perform.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersReadinessProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "Number of seconds after the container has started before liveness probes are initiated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "How often (in seconds) to perform the probe.\nDefault to 10 seconds. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "Minimum consecutive successes for the probe to be considered successful after having failed.\nDefaults to 1. Must be 1 for liveness and startup. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "TCPSocket specifies a connection to a TCP port.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersReadinessProbeTcpSocket"
            )
          );
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
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersReadinessProbeExec" = {

      options = {
        "command" = mkOption {
          description = "Command is the command line to execute inside the container, the working directory for the\ncommand  is root ('/') in the container's filesystem. The command is simply exec'd, it is\nnot run inside a shell, so traditional shell instructions ('|', etc) won't work. To use\na shell, you need to explicitly call out to that shell.\nExit status of 0 is treated as live/healthy and non-zero is unhealthy.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersReadinessProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "Port number of the gRPC service. Number must be in the range 1 to 65535.";
          type = types.int;
        };
        "service" = mkOption {
          description = "Service is the name of the service to place in the gRPC HealthCheckRequest\n(see https://github.com/grpc/grpc/blob/master/doc/health-checking.md).\n\nIf this is not specified, the default behavior is defined by gRPC.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersReadinessProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "Host name to connect to, defaults to the pod IP. You probably want to set\n\"Host\" in httpHeaders instead.";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "Custom headers to set in the request. HTTP allows repeated headers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersReadinessProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "Path to access on the HTTP server.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Name or number of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "Scheme to use for connecting to the host.\nDefaults to HTTP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersReadinessProbeHttpGetHttpHeaders" =
      {

        options = {
          "name" = mkOption {
            description = "The header field name.\nThis will be canonicalized upon output, so case-variant names will be understood as the same header.";
            type = types.str;
          };
          "value" = mkOption {
            description = "The header field value";
            type = types.str;
          };
        };

        config = { };

      };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersReadinessProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "Optional: Host name to connect to, defaults to the pod IP.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Number or name of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersResizePolicy" = {

      options = {
        "resourceName" = mkOption {
          description = "Name of the resource to which this resource resize policy applies.\nSupported values: cpu, memory.";
          type = types.str;
        };
        "restartPolicy" = mkOption {
          description = "Restart policy to apply when specified resource is resized.\nIf not specified, it defaults to NotRequired.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersResources" = {

      options = {
        "claims" = mkOption {
          description = "Claims lists the names of resources, defined in spec.resourceClaims,\nthat are used by this container.\n\nThis field depends on the\nDynamicResourceAllocation feature gate.\n\nThis field is immutable. It can only be set for containers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersResourcesClaims"
                "name"
                [ "name" ]
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersResourcesClaims" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersRestartPolicyRules" = {

      options = {
        "action" = mkOption {
          description = "Specifies the action taken on a container exit if the requirements\nare satisfied. The only possible value is \"Restart\" to restart the\ncontainer.";
          type = types.str;
        };
        "exitCodes" = mkOption {
          description = "Represents the exit codes to check on container exits.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersRestartPolicyRulesExitCodes"
            )
          );
        };
      };

      config = {
        "exitCodes" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersRestartPolicyRulesExitCodes" = {

      options = {
        "operator" = mkOption {
          description = "Represents the relationship between the container exit code(s) and the\nspecified values. Possible values are:\n- In: the requirement is satisfied if the container exit code is in the\n  set of specified values.\n- NotIn: the requirement is satisfied if the container exit code is\n  not in the set of specified values.";
          type = types.str;
        };
        "values" = mkOption {
          description = "Specifies the set of values to check for container exit codes.\nAt most 255 elements are allowed.";
          type = (types.nullOr (types.listOf types.int));
        };
      };

      config = {
        "values" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersSecurityContext" = {

      options = {
        "allowPrivilegeEscalation" = mkOption {
          description = "AllowPrivilegeEscalation controls whether a process can gain more\nprivileges than its parent process. This bool directly controls if\nthe no_new_privs flag will be set on the container process.\nAllowPrivilegeEscalation is true always when the container is:\n1) run as Privileged\n2) has CAP_SYS_ADMIN\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr types.bool);
        };
        "appArmorProfile" = mkOption {
          description = "appArmorProfile is the AppArmor options to use by this container. If set, this profile\noverrides the pod's appArmorProfile.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersSecurityContextAppArmorProfile"
            )
          );
        };
        "capabilities" = mkOption {
          description = "The capabilities to add/drop when running containers.\nDefaults to the default set of capabilities granted by the container runtime.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersSecurityContextCapabilities"
            )
          );
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
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersSecurityContextSeLinuxOptions"
            )
          );
        };
        "seccompProfile" = mkOption {
          description = "The seccomp options to use by this container. If seccomp options are\nprovided at both the pod & container level, the container options\noverride the pod options.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersSecurityContextSeccompProfile"
            )
          );
        };
        "windowsOptions" = mkOption {
          description = "The Windows specific settings applied to all containers.\nIf unspecified, the options from the PodSecurityContext will be used.\nIf set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.\nNote that this field cannot be set when spec.os.name is linux.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersSecurityContextWindowsOptions"
            )
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersSecurityContextAppArmorProfile" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersSecurityContextCapabilities" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersSecurityContextSeLinuxOptions" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersSecurityContextSeccompProfile" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersSecurityContextWindowsOptions" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersStartupProbe" = {

      options = {
        "exec" = mkOption {
          description = "Exec specifies a command to execute in the container.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersStartupProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "Minimum consecutive failures for the probe to be considered failed after having succeeded.\nDefaults to 3. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "GRPC specifies a GRPC HealthCheckRequest.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersStartupProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies an HTTP GET request to perform.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersStartupProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "Number of seconds after the container has started before liveness probes are initiated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "How often (in seconds) to perform the probe.\nDefault to 10 seconds. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "Minimum consecutive successes for the probe to be considered successful after having failed.\nDefaults to 1. Must be 1 for liveness and startup. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "TCPSocket specifies a connection to a TCP port.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersStartupProbeTcpSocket"
            )
          );
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
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersStartupProbeExec" = {

      options = {
        "command" = mkOption {
          description = "Command is the command line to execute inside the container, the working directory for the\ncommand  is root ('/') in the container's filesystem. The command is simply exec'd, it is\nnot run inside a shell, so traditional shell instructions ('|', etc) won't work. To use\na shell, you need to explicitly call out to that shell.\nExit status of 0 is treated as live/healthy and non-zero is unhealthy.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersStartupProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "Port number of the gRPC service. Number must be in the range 1 to 65535.";
          type = types.int;
        };
        "service" = mkOption {
          description = "Service is the name of the service to place in the gRPC HealthCheckRequest\n(see https://github.com/grpc/grpc/blob/master/doc/health-checking.md).\n\nIf this is not specified, the default behavior is defined by gRPC.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersStartupProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "Host name to connect to, defaults to the pod IP. You probably want to set\n\"Host\" in httpHeaders instead.";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "Custom headers to set in the request. HTTP allows repeated headers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersStartupProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "Path to access on the HTTP server.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Name or number of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "Scheme to use for connecting to the host.\nDefaults to HTTP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersStartupProbeHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "The header field name.\nThis will be canonicalized upon output, so case-variant names will be understood as the same header.";
          type = types.str;
        };
        "value" = mkOption {
          description = "The header field value";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersStartupProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "Optional: Host name to connect to, defaults to the pod IP.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Number or name of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersVolumeDevices" = {

      options = {
        "devicePath" = mkOption {
          description = "devicePath is the path inside of the container that the device will be mapped to.";
          type = types.str;
        };
        "name" = mkOption {
          description = "name must match the name of a persistentVolumeClaim in the pod";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecEphemeralContainersVolumeMounts" = {

      options = {
        "mountPath" = mkOption {
          description = "Path within the container at which the volume should be mounted.  Must\nnot contain ':'.";
          type = types.str;
        };
        "mountPropagation" = mkOption {
          description = "mountPropagation determines how mounts are propagated from the host\nto container and the other way around.\nWhen not set, MountPropagationNone is used.\nThis field is beta in 1.10.\nWhen RecursiveReadOnly is set to IfPossible or to Enabled, MountPropagation must be None or unspecified\n(which defaults to None).";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "This must match the Name of a Volume.";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "Mounted read-only if true, read-write otherwise (false or unspecified).\nDefaults to false.";
          type = (types.nullOr types.bool);
        };
        "recursiveReadOnly" = mkOption {
          description = "RecursiveReadOnly specifies whether read-only mounts should be handled\nrecursively.\n\nIf ReadOnly is false, this field has no meaning and must be unspecified.\n\nIf ReadOnly is true, and this field is set to Disabled, the mount is not made\nrecursively read-only.  If this field is set to IfPossible, the mount is made\nrecursively read-only, if it is supported by the container runtime.  If this\nfield is set to Enabled, the mount is made recursively read-only if it is\nsupported by the container runtime, otherwise the pod will not be started and\nan error will be generated to indicate the reason.\n\nIf this field is set to IfPossible or Enabled, MountPropagation must be set to\nNone (or be unspecified, which defaults to None).\n\nIf this field is not specified, it is treated as an equivalent of Disabled.";
          type = (types.nullOr types.str);
        };
        "subPath" = mkOption {
          description = "Path within the volume from which the container's volume should be mounted.\nDefaults to \"\" (volume's root).";
          type = (types.nullOr types.str);
        };
        "subPathExpr" = mkOption {
          description = "Expanded path within the volume from which the container's volume should be mounted.\nBehaves similarly to SubPath but environment variable references $(VAR_NAME) are expanded using the container's environment.\nDefaults to \"\" (volume's root).\nSubPathExpr and SubPath are mutually exclusive.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "mountPropagation" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "recursiveReadOnly" = mkOverride 1002 null;
        "subPath" = mkOverride 1002 null;
        "subPathExpr" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecHostAliases" = {

      options = {
        "hostnames" = mkOption {
          description = "Hostnames for the above IP address.";
          type = (types.nullOr (types.listOf types.str));
        };
        "ip" = mkOption {
          description = "IP address of the host file entry.";
          type = types.str;
        };
      };

      config = {
        "hostnames" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecImagePullSecrets" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainers" = {

      options = {
        "args" = mkOption {
          description = "Arguments to the entrypoint.\nThe container image's CMD is used if this is not provided.\nVariable references $(VAR_NAME) are expanded using the container's environment. If a variable\ncannot be resolved, the reference in the input string will be unchanged. Double $$ are reduced\nto a single $, which allows for escaping the $(VAR_NAME) syntax: i.e. \"$$(VAR_NAME)\" will\nproduce the string literal \"$(VAR_NAME)\". Escaped references will never be expanded, regardless\nof whether the variable exists or not. Cannot be updated.\nMore info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell";
          type = (types.nullOr (types.listOf types.str));
        };
        "command" = mkOption {
          description = "Entrypoint array. Not executed within a shell.\nThe container image's ENTRYPOINT is used if this is not provided.\nVariable references $(VAR_NAME) are expanded using the container's environment. If a variable\ncannot be resolved, the reference in the input string will be unchanged. Double $$ are reduced\nto a single $, which allows for escaping the $(VAR_NAME) syntax: i.e. \"$$(VAR_NAME)\" will\nproduce the string literal \"$(VAR_NAME)\". Escaped references will never be expanded, regardless\nof whether the variable exists or not. Cannot be updated.\nMore info: https://kubernetes.io/docs/tasks/inject-data-application/define-command-argument-container/#running-a-command-in-a-shell";
          type = (types.nullOr (types.listOf types.str));
        };
        "env" = mkOption {
          description = "List of environment variables to set in the container.\nCannot be updated.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnv"
                "name"
                [ "name" ]
            )
          );
          apply = attrsToList;
        };
        "envFrom" = mkOption {
          description = "List of sources to populate environment variables in the container.\nThe keys defined within a source may consist of any printable ASCII characters except '='.\nWhen a key exists in multiple\nsources, the value associated with the last source will take precedence.\nValues defined by an Env with a duplicate key will take precedence.\nCannot be updated.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvFrom")
            )
          );
        };
        "image" = mkOption {
          description = "Container image name.\nMore info: https://kubernetes.io/docs/concepts/containers/images\nThis field is optional to allow higher level config management to default or override\ncontainer images in workload controllers like Deployments and StatefulSets.";
          type = (types.nullOr types.str);
        };
        "imagePullPolicy" = mkOption {
          description = "Image pull policy.\nOne of Always, Never, IfNotPresent.\nDefaults to Always if :latest tag is specified, or IfNotPresent otherwise.\nCannot be updated.\nMore info: https://kubernetes.io/docs/concepts/containers/images#updating-images";
          type = (types.nullOr types.str);
        };
        "lifecycle" = mkOption {
          description = "Actions that the management system should take in response to container lifecycle events.\nCannot be updated.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecycle")
          );
        };
        "livenessProbe" = mkOption {
          description = "Periodic probe of container liveness.\nContainer will be restarted if the probe fails.\nCannot be updated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLivenessProbe")
          );
        };
        "name" = mkOption {
          description = "Name of the container specified as a DNS_LABEL.\nEach container in a pod must have a unique name (DNS_LABEL).\nCannot be updated.";
          type = types.str;
        };
        "ports" = mkOption {
          description = "List of ports to expose from the container. Not specifying a port here\nDOES NOT prevent that port from being exposed. Any port which is\nlistening on the default \"0.0.0.0\" address inside a container will be\naccessible from the network.\nModifying this array with strategic merge patch may corrupt the data.\nFor more information See https://github.com/kubernetes/kubernetes/issues/108255.\nCannot be updated.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersPorts"
                "name"
                [
                  "containerPort"
                  "protocol"
                ]
            )
          );
          apply = attrsToList;
        };
        "readinessProbe" = mkOption {
          description = "Periodic probe of container service readiness.\nContainer will be removed from service endpoints if the probe fails.\nCannot be updated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersReadinessProbe"
            )
          );
        };
        "resizePolicy" = mkOption {
          description = "Resources resize policy for the container.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersResizePolicy")
            )
          );
        };
        "resources" = mkOption {
          description = "Compute Resources required by this container.\nCannot be updated.\nMore info: https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersResources")
          );
        };
        "restartPolicy" = mkOption {
          description = "RestartPolicy defines the restart behavior of individual containers in a pod.\nThis overrides the pod-level restart policy. When this field is not specified,\nthe restart behavior is defined by the Pod's restart policy and the container type.\nAdditionally, setting the RestartPolicy as \"Always\" for the init container will\nhave the following effect:\nthis init container will be continually restarted on\nexit until all regular containers have terminated. Once all regular\ncontainers have completed, all init containers with restartPolicy \"Always\"\nwill be shut down. This lifecycle differs from normal init containers and\nis often referred to as a \"sidecar\" container. Although this init\ncontainer still starts in the init container sequence, it does not wait\nfor the container to complete before proceeding to the next init\ncontainer. Instead, the next init container starts immediately after this\ninit container is started, or after any startupProbe has successfully\ncompleted.";
          type = (types.nullOr types.str);
        };
        "restartPolicyRules" = mkOption {
          description = "Represents a list of rules to be checked to determine if the\ncontainer should be restarted on exit. The rules are evaluated in\norder. Once a rule matches a container exit condition, the remaining\nrules are ignored. If no rule matches the container exit condition,\nthe Container-level restart policy determines the whether the container\nis restarted or not. Constraints on the rules:\n- At most 20 rules are allowed.\n- Rules can have the same action.\n- Identical rules are not forbidden in validations.\nWhen rules are specified, container MUST set RestartPolicy explicitly\neven it if matches the Pod's RestartPolicy.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersRestartPolicyRules"
              )
            )
          );
        };
        "securityContext" = mkOption {
          description = "SecurityContext defines the security options the container should be run with.\nIf set, the fields of SecurityContext override the equivalent fields of PodSecurityContext.\nMore info: https://kubernetes.io/docs/tasks/configure-pod-container/security-context/";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersSecurityContext"
            )
          );
        };
        "startupProbe" = mkOption {
          description = "StartupProbe indicates that the Pod has successfully initialized.\nIf specified, no other probes are executed until this completes successfully.\nIf this probe fails, the Pod will be restarted, just as if the livenessProbe failed.\nThis can be used to provide different probe parameters at the beginning of a Pod's lifecycle,\nwhen it might take a long time to load data or warm a cache, than during steady-state operation.\nThis cannot be updated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersStartupProbe")
          );
        };
        "stdin" = mkOption {
          description = "Whether this container should allocate a buffer for stdin in the container runtime. If this\nis not set, reads from stdin in the container will always result in EOF.\nDefault is false.";
          type = (types.nullOr types.bool);
        };
        "stdinOnce" = mkOption {
          description = "Whether the container runtime should close the stdin channel after it has been opened by\na single attach. When stdin is true the stdin stream will remain open across multiple attach\nsessions. If stdinOnce is set to true, stdin is opened on container start, is empty until the\nfirst client attaches to stdin, and then remains open and accepts data until the client disconnects,\nat which time stdin is closed and remains closed until the container is restarted. If this\nflag is false, a container processes that reads from stdin will never receive an EOF.\nDefault is false";
          type = (types.nullOr types.bool);
        };
        "terminationMessagePath" = mkOption {
          description = "Optional: Path at which the file to which the container's termination message\nwill be written is mounted into the container's filesystem.\nMessage written is intended to be brief final status, such as an assertion failure message.\nWill be truncated by the node if greater than 4096 bytes. The total message length across\nall containers will be limited to 12kb.\nDefaults to /dev/termination-log.\nCannot be updated.";
          type = (types.nullOr types.str);
        };
        "terminationMessagePolicy" = mkOption {
          description = "Indicate how the termination message should be populated. File will use the contents of\nterminationMessagePath to populate the container status message on both success and failure.\nFallbackToLogsOnError will use the last chunk of container log output if the termination\nmessage file is empty and the container exited with an error.\nThe log output is limited to 2048 bytes or 80 lines, whichever is smaller.\nDefaults to File.\nCannot be updated.";
          type = (types.nullOr types.str);
        };
        "tty" = mkOption {
          description = "Whether this container should allocate a TTY for itself, also requires 'stdin' to be true.\nDefault is false.";
          type = (types.nullOr types.bool);
        };
        "volumeDevices" = mkOption {
          description = "volumeDevices is the list of block devices to be used by the container.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersVolumeDevices"
                "name"
                [ "devicePath" ]
            )
          );
          apply = attrsToList;
        };
        "volumeMounts" = mkOption {
          description = "Pod volumes to mount into the container's filesystem.\nCannot be updated.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersVolumeMounts"
                "name"
                [ "mountPath" ]
            )
          );
          apply = attrsToList;
        };
        "workingDir" = mkOption {
          description = "Container's working directory.\nIf not specified, the container runtime's default will be used, which\nmight be configured in the container image.\nCannot be updated.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "args" = mkOverride 1002 null;
        "command" = mkOverride 1002 null;
        "env" = mkOverride 1002 null;
        "envFrom" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "imagePullPolicy" = mkOverride 1002 null;
        "lifecycle" = mkOverride 1002 null;
        "livenessProbe" = mkOverride 1002 null;
        "ports" = mkOverride 1002 null;
        "readinessProbe" = mkOverride 1002 null;
        "resizePolicy" = mkOverride 1002 null;
        "resources" = mkOverride 1002 null;
        "restartPolicy" = mkOverride 1002 null;
        "restartPolicyRules" = mkOverride 1002 null;
        "securityContext" = mkOverride 1002 null;
        "startupProbe" = mkOverride 1002 null;
        "stdin" = mkOverride 1002 null;
        "stdinOnce" = mkOverride 1002 null;
        "terminationMessagePath" = mkOverride 1002 null;
        "terminationMessagePolicy" = mkOverride 1002 null;
        "tty" = mkOverride 1002 null;
        "volumeDevices" = mkOverride 1002 null;
        "volumeMounts" = mkOverride 1002 null;
        "workingDir" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnv" = {

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
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvValueFrom")
          );
        };
      };

      config = {
        "value" = mkOverride 1002 null;
        "valueFrom" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvFrom" = {

      options = {
        "configMapRef" = mkOption {
          description = "The ConfigMap to select from";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvFromConfigMapRef"
            )
          );
        };
        "prefix" = mkOption {
          description = "Optional text to prepend to the name of each environment variable.\nMay consist of any printable ASCII characters except '='.";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description = "The Secret to select from";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvFromSecretRef"
            )
          );
        };
      };

      config = {
        "configMapRef" = mkOverride 1002 null;
        "prefix" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvFromConfigMapRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvFromSecretRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvValueFrom" = {

      options = {
        "configMapKeyRef" = mkOption {
          description = "Selects a key of a ConfigMap.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvValueFromConfigMapKeyRef"
            )
          );
        };
        "fieldRef" = mkOption {
          description = "Selects a field of the pod: supports metadata.name, metadata.namespace, `metadata.labels['<KEY>']`, `metadata.annotations['<KEY>']`,\nspec.nodeName, spec.serviceAccountName, status.hostIP, status.podIP, status.podIPs.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvValueFromFieldRef"
            )
          );
        };
        "fileKeyRef" = mkOption {
          description = "FileKeyRef selects a key of the env file.\nRequires the EnvFiles feature gate to be enabled.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvValueFromFileKeyRef"
            )
          );
        };
        "resourceFieldRef" = mkOption {
          description = "Selects a resource of the container: only resources limits and requests\n(limits.cpu, limits.memory, limits.ephemeral-storage, requests.cpu, requests.memory and requests.ephemeral-storage) are currently supported.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvValueFromResourceFieldRef"
            )
          );
        };
        "secretKeyRef" = mkOption {
          description = "Selects a key of a secret in the pod's namespace";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvValueFromSecretKeyRef"
            )
          );
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvValueFromConfigMapKeyRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvValueFromFieldRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvValueFromFileKeyRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvValueFromResourceFieldRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersEnvValueFromSecretKeyRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecycle" = {

      options = {
        "postStart" = mkOption {
          description = "PostStart is called immediately after a container is created. If the handler fails,\nthe container is terminated and restarted according to its restart policy.\nOther management of the container blocks until the hook completes.\nMore info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePostStart"
            )
          );
        };
        "preStop" = mkOption {
          description = "PreStop is called immediately before a container is terminated due to an\nAPI request or management event such as liveness/startup probe failure,\npreemption, resource contention, etc. The handler is not called if the\ncontainer crashes or exits. The Pod's termination grace period countdown begins before the\nPreStop hook is executed. Regardless of the outcome of the handler, the\ncontainer will eventually terminate within the Pod's termination grace\nperiod (unless delayed by finalizers). Other management of the container blocks until the hook completes\nor until the termination grace period is reached.\nMore info: https://kubernetes.io/docs/concepts/containers/container-lifecycle-hooks/#container-hooks";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePreStop"
            )
          );
        };
        "stopSignal" = mkOption {
          description = "StopSignal defines which signal will be sent to a container when it is being stopped.\nIf not specified, the default is defined by the container runtime in use.\nStopSignal can only be set for Pods with a non-empty .spec.os.name";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "postStart" = mkOverride 1002 null;
        "preStop" = mkOverride 1002 null;
        "stopSignal" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePostStart" = {

      options = {
        "exec" = mkOption {
          description = "Exec specifies a command to execute in the container.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePostStartExec"
            )
          );
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies an HTTP GET request to perform.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePostStartHttpGet"
            )
          );
        };
        "sleep" = mkOption {
          description = "Sleep represents a duration that the container should sleep.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePostStartSleep"
            )
          );
        };
        "tcpSocket" = mkOption {
          description = "Deprecated. TCPSocket is NOT supported as a LifecycleHandler and kept\nfor backward compatibility. There is no validation of this field and\nlifecycle hooks will fail at runtime when it is specified.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePostStartTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePostStartExec" = {

      options = {
        "command" = mkOption {
          description = "Command is the command line to execute inside the container, the working directory for the\ncommand  is root ('/') in the container's filesystem. The command is simply exec'd, it is\nnot run inside a shell, so traditional shell instructions ('|', etc) won't work. To use\na shell, you need to explicitly call out to that shell.\nExit status of 0 is treated as live/healthy and non-zero is unhealthy.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePostStartHttpGet" = {

      options = {
        "host" = mkOption {
          description = "Host name to connect to, defaults to the pod IP. You probably want to set\n\"Host\" in httpHeaders instead.";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "Custom headers to set in the request. HTTP allows repeated headers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePostStartHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "Path to access on the HTTP server.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Name or number of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "Scheme to use for connecting to the host.\nDefaults to HTTP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePostStartHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "The header field name.\nThis will be canonicalized upon output, so case-variant names will be understood as the same header.";
          type = types.str;
        };
        "value" = mkOption {
          description = "The header field value";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePostStartSleep" = {

      options = {
        "seconds" = mkOption {
          description = "Seconds is the number of seconds to sleep.";
          type = types.int;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePostStartTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "Optional: Host name to connect to, defaults to the pod IP.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Number or name of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePreStop" = {

      options = {
        "exec" = mkOption {
          description = "Exec specifies a command to execute in the container.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePreStopExec"
            )
          );
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies an HTTP GET request to perform.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePreStopHttpGet"
            )
          );
        };
        "sleep" = mkOption {
          description = "Sleep represents a duration that the container should sleep.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePreStopSleep"
            )
          );
        };
        "tcpSocket" = mkOption {
          description = "Deprecated. TCPSocket is NOT supported as a LifecycleHandler and kept\nfor backward compatibility. There is no validation of this field and\nlifecycle hooks will fail at runtime when it is specified.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePreStopTcpSocket"
            )
          );
        };
      };

      config = {
        "exec" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "sleep" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePreStopExec" = {

      options = {
        "command" = mkOption {
          description = "Command is the command line to execute inside the container, the working directory for the\ncommand  is root ('/') in the container's filesystem. The command is simply exec'd, it is\nnot run inside a shell, so traditional shell instructions ('|', etc) won't work. To use\na shell, you need to explicitly call out to that shell.\nExit status of 0 is treated as live/healthy and non-zero is unhealthy.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePreStopHttpGet" = {

      options = {
        "host" = mkOption {
          description = "Host name to connect to, defaults to the pod IP. You probably want to set\n\"Host\" in httpHeaders instead.";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "Custom headers to set in the request. HTTP allows repeated headers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePreStopHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "Path to access on the HTTP server.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Name or number of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "Scheme to use for connecting to the host.\nDefaults to HTTP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePreStopHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "The header field name.\nThis will be canonicalized upon output, so case-variant names will be understood as the same header.";
          type = types.str;
        };
        "value" = mkOption {
          description = "The header field value";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePreStopSleep" = {

      options = {
        "seconds" = mkOption {
          description = "Seconds is the number of seconds to sleep.";
          type = types.int;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLifecyclePreStopTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "Optional: Host name to connect to, defaults to the pod IP.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Number or name of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLivenessProbe" = {

      options = {
        "exec" = mkOption {
          description = "Exec specifies a command to execute in the container.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLivenessProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "Minimum consecutive failures for the probe to be considered failed after having succeeded.\nDefaults to 3. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "GRPC specifies a GRPC HealthCheckRequest.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLivenessProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies an HTTP GET request to perform.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLivenessProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "Number of seconds after the container has started before liveness probes are initiated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "How often (in seconds) to perform the probe.\nDefault to 10 seconds. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "Minimum consecutive successes for the probe to be considered successful after having failed.\nDefaults to 1. Must be 1 for liveness and startup. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "TCPSocket specifies a connection to a TCP port.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLivenessProbeTcpSocket"
            )
          );
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
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLivenessProbeExec" = {

      options = {
        "command" = mkOption {
          description = "Command is the command line to execute inside the container, the working directory for the\ncommand  is root ('/') in the container's filesystem. The command is simply exec'd, it is\nnot run inside a shell, so traditional shell instructions ('|', etc) won't work. To use\na shell, you need to explicitly call out to that shell.\nExit status of 0 is treated as live/healthy and non-zero is unhealthy.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLivenessProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "Port number of the gRPC service. Number must be in the range 1 to 65535.";
          type = types.int;
        };
        "service" = mkOption {
          description = "Service is the name of the service to place in the gRPC HealthCheckRequest\n(see https://github.com/grpc/grpc/blob/master/doc/health-checking.md).\n\nIf this is not specified, the default behavior is defined by gRPC.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLivenessProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "Host name to connect to, defaults to the pod IP. You probably want to set\n\"Host\" in httpHeaders instead.";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "Custom headers to set in the request. HTTP allows repeated headers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLivenessProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "Path to access on the HTTP server.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Name or number of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "Scheme to use for connecting to the host.\nDefaults to HTTP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLivenessProbeHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "The header field name.\nThis will be canonicalized upon output, so case-variant names will be understood as the same header.";
          type = types.str;
        };
        "value" = mkOption {
          description = "The header field value";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersLivenessProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "Optional: Host name to connect to, defaults to the pod IP.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Number or name of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersPorts" = {

      options = {
        "containerPort" = mkOption {
          description = "Number of port to expose on the pod's IP address.\nThis must be a valid port number, 0 < x < 65536.";
          type = types.int;
        };
        "hostIP" = mkOption {
          description = "What host IP to bind the external port to.";
          type = (types.nullOr types.str);
        };
        "hostPort" = mkOption {
          description = "Number of port to expose on the host.\nIf specified, this must be a valid port number, 0 < x < 65536.\nIf HostNetwork is specified, this must match ContainerPort.\nMost containers do not need this.";
          type = (types.nullOr types.int);
        };
        "name" = mkOption {
          description = "If specified, this must be an IANA_SVC_NAME and unique within the pod. Each\nnamed port in a pod must have a unique name. Name for the port that can be\nreferred to by services.";
          type = (types.nullOr types.str);
        };
        "protocol" = mkOption {
          description = "Protocol for port. Must be UDP, TCP, or SCTP.\nDefaults to \"TCP\".";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "hostIP" = mkOverride 1002 null;
        "hostPort" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "protocol" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersReadinessProbe" = {

      options = {
        "exec" = mkOption {
          description = "Exec specifies a command to execute in the container.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersReadinessProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "Minimum consecutive failures for the probe to be considered failed after having succeeded.\nDefaults to 3. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "GRPC specifies a GRPC HealthCheckRequest.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersReadinessProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies an HTTP GET request to perform.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersReadinessProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "Number of seconds after the container has started before liveness probes are initiated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "How often (in seconds) to perform the probe.\nDefault to 10 seconds. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "Minimum consecutive successes for the probe to be considered successful after having failed.\nDefaults to 1. Must be 1 for liveness and startup. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "TCPSocket specifies a connection to a TCP port.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersReadinessProbeTcpSocket"
            )
          );
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
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersReadinessProbeExec" = {

      options = {
        "command" = mkOption {
          description = "Command is the command line to execute inside the container, the working directory for the\ncommand  is root ('/') in the container's filesystem. The command is simply exec'd, it is\nnot run inside a shell, so traditional shell instructions ('|', etc) won't work. To use\na shell, you need to explicitly call out to that shell.\nExit status of 0 is treated as live/healthy and non-zero is unhealthy.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersReadinessProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "Port number of the gRPC service. Number must be in the range 1 to 65535.";
          type = types.int;
        };
        "service" = mkOption {
          description = "Service is the name of the service to place in the gRPC HealthCheckRequest\n(see https://github.com/grpc/grpc/blob/master/doc/health-checking.md).\n\nIf this is not specified, the default behavior is defined by gRPC.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersReadinessProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "Host name to connect to, defaults to the pod IP. You probably want to set\n\"Host\" in httpHeaders instead.";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "Custom headers to set in the request. HTTP allows repeated headers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersReadinessProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "Path to access on the HTTP server.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Name or number of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "Scheme to use for connecting to the host.\nDefaults to HTTP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersReadinessProbeHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "The header field name.\nThis will be canonicalized upon output, so case-variant names will be understood as the same header.";
          type = types.str;
        };
        "value" = mkOption {
          description = "The header field value";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersReadinessProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "Optional: Host name to connect to, defaults to the pod IP.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Number or name of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersResizePolicy" = {

      options = {
        "resourceName" = mkOption {
          description = "Name of the resource to which this resource resize policy applies.\nSupported values: cpu, memory.";
          type = types.str;
        };
        "restartPolicy" = mkOption {
          description = "Restart policy to apply when specified resource is resized.\nIf not specified, it defaults to NotRequired.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersResources" = {

      options = {
        "claims" = mkOption {
          description = "Claims lists the names of resources, defined in spec.resourceClaims,\nthat are used by this container.\n\nThis field depends on the\nDynamicResourceAllocation feature gate.\n\nThis field is immutable. It can only be set for containers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersResourcesClaims"
                "name"
                [ "name" ]
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersResourcesClaims" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersRestartPolicyRules" = {

      options = {
        "action" = mkOption {
          description = "Specifies the action taken on a container exit if the requirements\nare satisfied. The only possible value is \"Restart\" to restart the\ncontainer.";
          type = types.str;
        };
        "exitCodes" = mkOption {
          description = "Represents the exit codes to check on container exits.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersRestartPolicyRulesExitCodes"
            )
          );
        };
      };

      config = {
        "exitCodes" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersRestartPolicyRulesExitCodes" = {

      options = {
        "operator" = mkOption {
          description = "Represents the relationship between the container exit code(s) and the\nspecified values. Possible values are:\n- In: the requirement is satisfied if the container exit code is in the\n  set of specified values.\n- NotIn: the requirement is satisfied if the container exit code is\n  not in the set of specified values.";
          type = types.str;
        };
        "values" = mkOption {
          description = "Specifies the set of values to check for container exit codes.\nAt most 255 elements are allowed.";
          type = (types.nullOr (types.listOf types.int));
        };
      };

      config = {
        "values" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersSecurityContext" = {

      options = {
        "allowPrivilegeEscalation" = mkOption {
          description = "AllowPrivilegeEscalation controls whether a process can gain more\nprivileges than its parent process. This bool directly controls if\nthe no_new_privs flag will be set on the container process.\nAllowPrivilegeEscalation is true always when the container is:\n1) run as Privileged\n2) has CAP_SYS_ADMIN\nNote that this field cannot be set when spec.os.name is windows.";
          type = (types.nullOr types.bool);
        };
        "appArmorProfile" = mkOption {
          description = "appArmorProfile is the AppArmor options to use by this container. If set, this profile\noverrides the pod's appArmorProfile.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersSecurityContextAppArmorProfile"
            )
          );
        };
        "capabilities" = mkOption {
          description = "The capabilities to add/drop when running containers.\nDefaults to the default set of capabilities granted by the container runtime.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersSecurityContextCapabilities"
            )
          );
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
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersSecurityContextSeLinuxOptions"
            )
          );
        };
        "seccompProfile" = mkOption {
          description = "The seccomp options to use by this container. If seccomp options are\nprovided at both the pod & container level, the container options\noverride the pod options.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersSecurityContextSeccompProfile"
            )
          );
        };
        "windowsOptions" = mkOption {
          description = "The Windows specific settings applied to all containers.\nIf unspecified, the options from the PodSecurityContext will be used.\nIf set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.\nNote that this field cannot be set when spec.os.name is linux.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersSecurityContextWindowsOptions"
            )
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersSecurityContextAppArmorProfile" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersSecurityContextCapabilities" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersSecurityContextSeLinuxOptions" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersSecurityContextSeccompProfile" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersSecurityContextWindowsOptions" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersStartupProbe" = {

      options = {
        "exec" = mkOption {
          description = "Exec specifies a command to execute in the container.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersStartupProbeExec"
            )
          );
        };
        "failureThreshold" = mkOption {
          description = "Minimum consecutive failures for the probe to be considered failed after having succeeded.\nDefaults to 3. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "grpc" = mkOption {
          description = "GRPC specifies a GRPC HealthCheckRequest.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersStartupProbeGrpc"
            )
          );
        };
        "httpGet" = mkOption {
          description = "HTTPGet specifies an HTTP GET request to perform.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersStartupProbeHttpGet"
            )
          );
        };
        "initialDelaySeconds" = mkOption {
          description = "Number of seconds after the container has started before liveness probes are initiated.\nMore info: https://kubernetes.io/docs/concepts/workloads/pods/pod-lifecycle#container-probes";
          type = (types.nullOr types.int);
        };
        "periodSeconds" = mkOption {
          description = "How often (in seconds) to perform the probe.\nDefault to 10 seconds. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "successThreshold" = mkOption {
          description = "Minimum consecutive successes for the probe to be considered successful after having failed.\nDefaults to 1. Must be 1 for liveness and startup. Minimum value is 1.";
          type = (types.nullOr types.int);
        };
        "tcpSocket" = mkOption {
          description = "TCPSocket specifies a connection to a TCP port.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersStartupProbeTcpSocket"
            )
          );
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
        "exec" = mkOverride 1002 null;
        "failureThreshold" = mkOverride 1002 null;
        "grpc" = mkOverride 1002 null;
        "httpGet" = mkOverride 1002 null;
        "initialDelaySeconds" = mkOverride 1002 null;
        "periodSeconds" = mkOverride 1002 null;
        "successThreshold" = mkOverride 1002 null;
        "tcpSocket" = mkOverride 1002 null;
        "terminationGracePeriodSeconds" = mkOverride 1002 null;
        "timeoutSeconds" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersStartupProbeExec" = {

      options = {
        "command" = mkOption {
          description = "Command is the command line to execute inside the container, the working directory for the\ncommand  is root ('/') in the container's filesystem. The command is simply exec'd, it is\nnot run inside a shell, so traditional shell instructions ('|', etc) won't work. To use\na shell, you need to explicitly call out to that shell.\nExit status of 0 is treated as live/healthy and non-zero is unhealthy.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "command" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersStartupProbeGrpc" = {

      options = {
        "port" = mkOption {
          description = "Port number of the gRPC service. Number must be in the range 1 to 65535.";
          type = types.int;
        };
        "service" = mkOption {
          description = "Service is the name of the service to place in the gRPC HealthCheckRequest\n(see https://github.com/grpc/grpc/blob/master/doc/health-checking.md).\n\nIf this is not specified, the default behavior is defined by gRPC.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "service" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersStartupProbeHttpGet" = {

      options = {
        "host" = mkOption {
          description = "Host name to connect to, defaults to the pod IP. You probably want to set\n\"Host\" in httpHeaders instead.";
          type = (types.nullOr types.str);
        };
        "httpHeaders" = mkOption {
          description = "Custom headers to set in the request. HTTP allows repeated headers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersStartupProbeHttpGetHttpHeaders"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "path" = mkOption {
          description = "Path to access on the HTTP server.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Name or number of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
        "scheme" = mkOption {
          description = "Scheme to use for connecting to the host.\nDefaults to HTTP.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
        "httpHeaders" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersStartupProbeHttpGetHttpHeaders" = {

      options = {
        "name" = mkOption {
          description = "The header field name.\nThis will be canonicalized upon output, so case-variant names will be understood as the same header.";
          type = types.str;
        };
        "value" = mkOption {
          description = "The header field value";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersStartupProbeTcpSocket" = {

      options = {
        "host" = mkOption {
          description = "Optional: Host name to connect to, defaults to the pod IP.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Number or name of the port to access on the container.\nNumber must be in the range 1 to 65535.\nName must be an IANA_SVC_NAME.";
          type = (types.either types.int types.str);
        };
      };

      config = {
        "host" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersVolumeDevices" = {

      options = {
        "devicePath" = mkOption {
          description = "devicePath is the path inside of the container that the device will be mapped to.";
          type = types.str;
        };
        "name" = mkOption {
          description = "name must match the name of a persistentVolumeClaim in the pod";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecInitContainersVolumeMounts" = {

      options = {
        "mountPath" = mkOption {
          description = "Path within the container at which the volume should be mounted.  Must\nnot contain ':'.";
          type = types.str;
        };
        "mountPropagation" = mkOption {
          description = "mountPropagation determines how mounts are propagated from the host\nto container and the other way around.\nWhen not set, MountPropagationNone is used.\nThis field is beta in 1.10.\nWhen RecursiveReadOnly is set to IfPossible or to Enabled, MountPropagation must be None or unspecified\n(which defaults to None).";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "This must match the Name of a Volume.";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "Mounted read-only if true, read-write otherwise (false or unspecified).\nDefaults to false.";
          type = (types.nullOr types.bool);
        };
        "recursiveReadOnly" = mkOption {
          description = "RecursiveReadOnly specifies whether read-only mounts should be handled\nrecursively.\n\nIf ReadOnly is false, this field has no meaning and must be unspecified.\n\nIf ReadOnly is true, and this field is set to Disabled, the mount is not made\nrecursively read-only.  If this field is set to IfPossible, the mount is made\nrecursively read-only, if it is supported by the container runtime.  If this\nfield is set to Enabled, the mount is made recursively read-only if it is\nsupported by the container runtime, otherwise the pod will not be started and\nan error will be generated to indicate the reason.\n\nIf this field is set to IfPossible or Enabled, MountPropagation must be set to\nNone (or be unspecified, which defaults to None).\n\nIf this field is not specified, it is treated as an equivalent of Disabled.";
          type = (types.nullOr types.str);
        };
        "subPath" = mkOption {
          description = "Path within the volume from which the container's volume should be mounted.\nDefaults to \"\" (volume's root).";
          type = (types.nullOr types.str);
        };
        "subPathExpr" = mkOption {
          description = "Expanded path within the volume from which the container's volume should be mounted.\nBehaves similarly to SubPath but environment variable references $(VAR_NAME) are expanded using the container's environment.\nDefaults to \"\" (volume's root).\nSubPathExpr and SubPath are mutually exclusive.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "mountPropagation" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "recursiveReadOnly" = mkOverride 1002 null;
        "subPath" = mkOverride 1002 null;
        "subPathExpr" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecOs" = {

      options = {
        "name" = mkOption {
          description = "Name is the name of the operating system. The currently supported values are linux and windows.\nAdditional value may be defined in future and can be one of:\nhttps://github.com/opencontainers/runtime-spec/blob/master/config.md#platform-specific-configuration\nClients should expect to handle additional values and treat unrecognized values in this field as os: null";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecReadinessGates" = {

      options = {
        "conditionType" = mkOption {
          description = "ConditionType refers to a condition in the pod's condition list with matching type.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecResourceClaims" = {

      options = {
        "name" = mkOption {
          description = "Name uniquely identifies this resource claim inside the pod.\nThis must be a DNS_LABEL.";
          type = types.str;
        };
        "resourceClaimName" = mkOption {
          description = "ResourceClaimName is the name of a ResourceClaim object in the same\nnamespace as this pod.\n\nExactly one of ResourceClaimName and ResourceClaimTemplateName must\nbe set.";
          type = (types.nullOr types.str);
        };
        "resourceClaimTemplateName" = mkOption {
          description = "ResourceClaimTemplateName is the name of a ResourceClaimTemplate\nobject in the same namespace as this pod.\n\nThe template will be used to create a new ResourceClaim, which will\nbe bound to this pod. When this pod is deleted, the ResourceClaim\nwill also be deleted. The pod name and resource name, along with a\ngenerated component, will be used to form a unique name for the\nResourceClaim, which will be recorded in pod.status.resourceClaimStatuses.\n\nThis field is immutable and no changes will be made to the\ncorresponding ResourceClaim by the control plane after creating the\nResourceClaim.\n\nExactly one of ResourceClaimName and ResourceClaimTemplateName must\nbe set.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "resourceClaimName" = mkOverride 1002 null;
        "resourceClaimTemplateName" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecResources" = {

      options = {
        "claims" = mkOption {
          description = "Claims lists the names of resources, defined in spec.resourceClaims,\nthat are used by this container.\n\nThis field depends on the\nDynamicResourceAllocation feature gate.\n\nThis field is immutable. It can only be set for containers.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecResourcesClaims"
                "name"
                [ "name" ]
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecResourcesClaims" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecSchedulingGates" = {

      options = {
        "name" = mkOption {
          description = "Name of the scheduling gate.\nEach scheduling gate must have a unique name field.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecSecurityContext" = {

      options = {
        "appArmorProfile" = mkOption {
          description = "appArmorProfile is the AppArmor options to use by the containers in this pod.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecSecurityContextAppArmorProfile"
            )
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
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecSecurityContextSeLinuxOptions"
            )
          );
        };
        "seccompProfile" = mkOption {
          description = "The seccomp options to use by the containers in this pod.\nNote that this field cannot be set when spec.os.name is windows.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecSecurityContextSeccompProfile"
            )
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
              coerceAttrsOfSubmodulesToListByKey
                "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecSecurityContextSysctls"
                "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "windowsOptions" = mkOption {
          description = "The Windows specific settings applied to all containers.\nIf unspecified, the options within a container's SecurityContext will be used.\nIf set in both SecurityContext and PodSecurityContext, the value specified in SecurityContext takes precedence.\nNote that this field cannot be set when spec.os.name is linux.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecSecurityContextWindowsOptions"
            )
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecSecurityContextAppArmorProfile" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecSecurityContextSeLinuxOptions" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecSecurityContextSeccompProfile" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecSecurityContextSysctls" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecSecurityContextWindowsOptions" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecTolerations" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecTopologySpreadConstraints" = {

      options = {
        "labelSelector" = mkOption {
          description = "LabelSelector is used to find matching pods.\nPods that match this label selector are counted to determine the number of pods\nin their corresponding topology domain.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecTopologySpreadConstraintsLabelSelector"
            )
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecTopologySpreadConstraintsLabelSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecTopologySpreadConstraintsLabelSelectorMatchExpressions"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecTopologySpreadConstraintsLabelSelectorMatchExpressions" =
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumes" = {

      options = {
        "awsElasticBlockStore" = mkOption {
          description = "awsElasticBlockStore represents an AWS Disk resource that is attached to a\nkubelet's host machine and then exposed to the pod.\nDeprecated: AWSElasticBlockStore is deprecated. All operations for the in-tree\nawsElasticBlockStore type are redirected to the ebs.csi.aws.com CSI driver.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesAwsElasticBlockStore")
          );
        };
        "azureDisk" = mkOption {
          description = "azureDisk represents an Azure Data Disk mount on the host and bind mount to the pod.\nDeprecated: AzureDisk is deprecated. All operations for the in-tree azureDisk type\nare redirected to the disk.csi.azure.com CSI driver.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesAzureDisk"));
        };
        "azureFile" = mkOption {
          description = "azureFile represents an Azure File Service mount on the host and bind mount to the pod.\nDeprecated: AzureFile is deprecated. All operations for the in-tree azureFile type\nare redirected to the file.csi.azure.com CSI driver.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesAzureFile"));
        };
        "cephfs" = mkOption {
          description = "cephFS represents a Ceph FS mount on the host that shares a pod's lifetime.\nDeprecated: CephFS is deprecated and the in-tree cephfs type is no longer supported.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesCephfs"));
        };
        "cinder" = mkOption {
          description = "cinder represents a cinder volume attached and mounted on kubelets host machine.\nDeprecated: Cinder is deprecated. All operations for the in-tree cinder type\nare redirected to the cinder.csi.openstack.org CSI driver.\nMore info: https://examples.k8s.io/mysql-cinder-pd/README.md";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesCinder"));
        };
        "configMap" = mkOption {
          description = "configMap represents a configMap that should populate this volume";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesConfigMap"));
        };
        "csi" = mkOption {
          description = "csi (Container Storage Interface) represents ephemeral storage that is handled by certain external CSI drivers.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesCsi"));
        };
        "downwardAPI" = mkOption {
          description = "downwardAPI represents downward API about the pod that should populate this volume";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesDownwardAPI")
          );
        };
        "emptyDir" = mkOption {
          description = "emptyDir represents a temporary directory that shares a pod's lifetime.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#emptydir";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEmptyDir"));
        };
        "ephemeral" = mkOption {
          description = "ephemeral represents a volume that is handled by a cluster storage driver.\nThe volume's lifecycle is tied to the pod that defines it - it will be created before the pod starts,\nand deleted when the pod is removed.\n\nUse this if:\na) the volume is only needed while the pod runs,\nb) features of normal volumes like restoring from snapshot or capacity\n   tracking are needed,\nc) the storage driver is specified through a storage class, and\nd) the storage driver supports dynamic volume provisioning through\n   a PersistentVolumeClaim (see EphemeralVolumeSource for more\n   information on the connection between this volume type\n   and PersistentVolumeClaim).\n\nUse PersistentVolumeClaim or one of the vendor-specific\nAPIs for volumes that persist for longer than the lifecycle\nof an individual pod.\n\nUse CSI for light-weight local ephemeral volumes if the CSI driver is meant to\nbe used that way - see the documentation of the driver for\nmore information.\n\nA pod can use both types of ephemeral volumes and\npersistent volumes at the same time.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEphemeral"));
        };
        "fc" = mkOption {
          description = "fc represents a Fibre Channel resource that is attached to a kubelet's host machine and then exposed to the pod.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesFc"));
        };
        "flexVolume" = mkOption {
          description = "flexVolume represents a generic volume resource that is\nprovisioned/attached using an exec based plugin.\nDeprecated: FlexVolume is deprecated. Consider using a CSIDriver instead.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesFlexVolume"));
        };
        "flocker" = mkOption {
          description = "flocker represents a Flocker volume attached to a kubelet's host machine. This depends on the Flocker control service being running.\nDeprecated: Flocker is deprecated and the in-tree flocker type is no longer supported.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesFlocker"));
        };
        "gcePersistentDisk" = mkOption {
          description = "gcePersistentDisk represents a GCE Disk resource that is attached to a\nkubelet's host machine and then exposed to the pod.\nDeprecated: GCEPersistentDisk is deprecated. All operations for the in-tree\ngcePersistentDisk type are redirected to the pd.csi.storage.gke.io CSI driver.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesGcePersistentDisk")
          );
        };
        "gitRepo" = mkOption {
          description = "gitRepo represents a git repository at a particular revision.\nDeprecated: GitRepo is deprecated. To provision a container with a git repo, mount an\nEmptyDir into an InitContainer that clones the repo using git, then mount the EmptyDir\ninto the Pod's container.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesGitRepo"));
        };
        "glusterfs" = mkOption {
          description = "glusterfs represents a Glusterfs mount on the host that shares a pod's lifetime.\nDeprecated: Glusterfs is deprecated and the in-tree glusterfs type is no longer supported.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesGlusterfs"));
        };
        "hostPath" = mkOption {
          description = "hostPath represents a pre-existing file or directory on the host\nmachine that is directly exposed to the container. This is generally\nused for system agents or other privileged things that are allowed\nto see the host machine. Most containers will NOT need this.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesHostPath"));
        };
        "image" = mkOption {
          description = "image represents an OCI object (a container image or artifact) pulled and mounted on the kubelet's host machine.\nThe volume is resolved at pod startup depending on which PullPolicy value is provided:\n\n- Always: the kubelet always attempts to pull the reference. Container creation will fail If the pull fails.\n- Never: the kubelet never pulls the reference and only uses a local image or artifact. Container creation will fail if the reference isn't present.\n- IfNotPresent: the kubelet pulls if the reference isn't already present on disk. Container creation will fail if the reference isn't present and the pull fails.\n\nThe volume gets re-resolved if the pod gets deleted and recreated, which means that new remote content will become available on pod recreation.\nA failure to resolve or pull the image during pod startup will block containers from starting and may add significant latency. Failures will be retried using normal volume backoff and will be reported on the pod reason and message.\nThe types of objects that may be mounted by this volume are defined by the container runtime implementation on a host machine and at minimum must include all valid types supported by the container image field.\nThe OCI object gets mounted in a single directory (spec.containers[*].volumeMounts.mountPath) by merging the manifest layers in the same way as for container images.\nThe volume will be mounted read-only (ro) and non-executable files (noexec).\nSub path mounts for containers are not supported (spec.containers[*].volumeMounts.subpath) before 1.33.\nThe field spec.securityContext.fsGroupChangePolicy has no effect on this volume type.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesImage"));
        };
        "iscsi" = mkOption {
          description = "iscsi represents an ISCSI Disk resource that is attached to a\nkubelet's host machine and then exposed to the pod.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes/#iscsi";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesIscsi"));
        };
        "name" = mkOption {
          description = "name of the volume.\nMust be a DNS_LABEL and unique within the pod.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = types.str;
        };
        "nfs" = mkOption {
          description = "nfs represents an NFS mount on the host that shares a pod's lifetime\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#nfs";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesNfs"));
        };
        "persistentVolumeClaim" = mkOption {
          description = "persistentVolumeClaimVolumeSource represents a reference to a\nPersistentVolumeClaim in the same namespace.\nMore info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesPersistentVolumeClaim"
            )
          );
        };
        "photonPersistentDisk" = mkOption {
          description = "photonPersistentDisk represents a PhotonController persistent disk attached and mounted on kubelets host machine.\nDeprecated: PhotonPersistentDisk is deprecated and the in-tree photonPersistentDisk type is no longer supported.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesPhotonPersistentDisk")
          );
        };
        "portworxVolume" = mkOption {
          description = "portworxVolume represents a portworx volume attached and mounted on kubelets host machine.\nDeprecated: PortworxVolume is deprecated. All operations for the in-tree portworxVolume type\nare redirected to the pxd.portworx.com CSI driver when the CSIMigrationPortworx feature-gate\nis on.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesPortworxVolume")
          );
        };
        "projected" = mkOption {
          description = "projected items for all in one resources secrets, configmaps, and downward API";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjected"));
        };
        "quobyte" = mkOption {
          description = "quobyte represents a Quobyte mount on the host that shares a pod's lifetime.\nDeprecated: Quobyte is deprecated and the in-tree quobyte type is no longer supported.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesQuobyte"));
        };
        "rbd" = mkOption {
          description = "rbd represents a Rados Block Device mount on the host that shares a pod's lifetime.\nDeprecated: RBD is deprecated and the in-tree rbd type is no longer supported.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesRbd"));
        };
        "scaleIO" = mkOption {
          description = "scaleIO represents a ScaleIO persistent volume attached and mounted on Kubernetes nodes.\nDeprecated: ScaleIO is deprecated and the in-tree scaleIO type is no longer supported.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesScaleIO"));
        };
        "secret" = mkOption {
          description = "secret represents a secret that should populate this volume.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#secret";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesSecret"));
        };
        "storageos" = mkOption {
          description = "storageOS represents a StorageOS volume attached and mounted on Kubernetes nodes.\nDeprecated: StorageOS is deprecated and the in-tree storageos type is no longer supported.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesStorageos"));
        };
        "vsphereVolume" = mkOption {
          description = "vsphereVolume represents a vSphere volume attached and mounted on kubelets host machine.\nDeprecated: VsphereVolume is deprecated. All operations for the in-tree vsphereVolume type\nare redirected to the csi.vsphere.vmware.com CSI driver.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesVsphereVolume")
          );
        };
      };

      config = {
        "awsElasticBlockStore" = mkOverride 1002 null;
        "azureDisk" = mkOverride 1002 null;
        "azureFile" = mkOverride 1002 null;
        "cephfs" = mkOverride 1002 null;
        "cinder" = mkOverride 1002 null;
        "configMap" = mkOverride 1002 null;
        "csi" = mkOverride 1002 null;
        "downwardAPI" = mkOverride 1002 null;
        "emptyDir" = mkOverride 1002 null;
        "ephemeral" = mkOverride 1002 null;
        "fc" = mkOverride 1002 null;
        "flexVolume" = mkOverride 1002 null;
        "flocker" = mkOverride 1002 null;
        "gcePersistentDisk" = mkOverride 1002 null;
        "gitRepo" = mkOverride 1002 null;
        "glusterfs" = mkOverride 1002 null;
        "hostPath" = mkOverride 1002 null;
        "image" = mkOverride 1002 null;
        "iscsi" = mkOverride 1002 null;
        "nfs" = mkOverride 1002 null;
        "persistentVolumeClaim" = mkOverride 1002 null;
        "photonPersistentDisk" = mkOverride 1002 null;
        "portworxVolume" = mkOverride 1002 null;
        "projected" = mkOverride 1002 null;
        "quobyte" = mkOverride 1002 null;
        "rbd" = mkOverride 1002 null;
        "scaleIO" = mkOverride 1002 null;
        "secret" = mkOverride 1002 null;
        "storageos" = mkOverride 1002 null;
        "vsphereVolume" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesAwsElasticBlockStore" = {

      options = {
        "fsType" = mkOption {
          description = "fsType is the filesystem type of the volume that you want to mount.\nTip: Ensure that the filesystem type is supported by the host operating system.\nExamples: \"ext4\", \"xfs\", \"ntfs\". Implicitly inferred to be \"ext4\" if unspecified.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore";
          type = (types.nullOr types.str);
        };
        "partition" = mkOption {
          description = "partition is the partition in the volume that you want to mount.\nIf omitted, the default is to mount by volume name.\nExamples: For volume /dev/sda1, you specify the partition as \"1\".\nSimilarly, the volume partition for /dev/sda is \"0\" (or you can leave the property empty).";
          type = (types.nullOr types.int);
        };
        "readOnly" = mkOption {
          description = "readOnly value true will force the readOnly setting in VolumeMounts.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore";
          type = (types.nullOr types.bool);
        };
        "volumeID" = mkOption {
          description = "volumeID is unique ID of the persistent disk resource in AWS (Amazon EBS volume).\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#awselasticblockstore";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "partition" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesAzureDisk" = {

      options = {
        "cachingMode" = mkOption {
          description = "cachingMode is the Host Caching mode: None, Read Only, Read Write.";
          type = (types.nullOr types.str);
        };
        "diskName" = mkOption {
          description = "diskName is the Name of the data disk in the blob storage";
          type = types.str;
        };
        "diskURI" = mkOption {
          description = "diskURI is the URI of data disk in the blob storage";
          type = types.str;
        };
        "fsType" = mkOption {
          description = "fsType is Filesystem type to mount.\nMust be a filesystem type supported by the host operating system.\nEx. \"ext4\", \"xfs\", \"ntfs\". Implicitly inferred to be \"ext4\" if unspecified.";
          type = (types.nullOr types.str);
        };
        "kind" = mkOption {
          description = "kind expected values are Shared: multiple blob disks per storage account  Dedicated: single blob disk per storage account  Managed: azure managed data disk (only in managed availability set). defaults to shared";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "readOnly Defaults to false (read/write). ReadOnly here will force\nthe ReadOnly setting in VolumeMounts.";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "cachingMode" = mkOverride 1002 null;
        "fsType" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesAzureFile" = {

      options = {
        "readOnly" = mkOption {
          description = "readOnly defaults to false (read/write). ReadOnly here will force\nthe ReadOnly setting in VolumeMounts.";
          type = (types.nullOr types.bool);
        };
        "secretName" = mkOption {
          description = "secretName is the  name of secret that contains Azure Storage Account Name and Key";
          type = types.str;
        };
        "shareName" = mkOption {
          description = "shareName is the azure share Name";
          type = types.str;
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesCephfs" = {

      options = {
        "monitors" = mkOption {
          description = "monitors is Required: Monitors is a collection of Ceph monitors\nMore info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it";
          type = (types.listOf types.str);
        };
        "path" = mkOption {
          description = "path is Optional: Used as the mounted root, rather than the full Ceph tree, default is /";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "readOnly is Optional: Defaults to false (read/write). ReadOnly here will force\nthe ReadOnly setting in VolumeMounts.\nMore info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it";
          type = (types.nullOr types.bool);
        };
        "secretFile" = mkOption {
          description = "secretFile is Optional: SecretFile is the path to key ring for User, default is /etc/ceph/user.secret\nMore info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it";
          type = (types.nullOr types.str);
        };
        "secretRef" = mkOption {
          description = "secretRef is Optional: SecretRef is reference to the authentication secret for User, default is empty.\nMore info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesCephfsSecretRef")
          );
        };
        "user" = mkOption {
          description = "user is optional: User is the rados user name, default is admin\nMore info: https://examples.k8s.io/volumes/cephfs/README.md#how-to-use-it";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "path" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretFile" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesCephfsSecretRef" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesCinder" = {

      options = {
        "fsType" = mkOption {
          description = "fsType is the filesystem type to mount.\nMust be a filesystem type supported by the host operating system.\nExamples: \"ext4\", \"xfs\", \"ntfs\". Implicitly inferred to be \"ext4\" if unspecified.\nMore info: https://examples.k8s.io/mysql-cinder-pd/README.md";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "readOnly defaults to false (read/write). ReadOnly here will force\nthe ReadOnly setting in VolumeMounts.\nMore info: https://examples.k8s.io/mysql-cinder-pd/README.md";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "secretRef is optional: points to a secret object containing parameters used to connect\nto OpenStack.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesCinderSecretRef")
          );
        };
        "volumeID" = mkOption {
          description = "volumeID used to identify the volume in cinder.\nMore info: https://examples.k8s.io/mysql-cinder-pd/README.md";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesCinderSecretRef" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesConfigMap" = {

      options = {
        "defaultMode" = mkOption {
          description = "defaultMode is optional: mode bits used to set permissions on created files by default.\nMust be an octal value between 0000 and 0777 or a decimal value between 0 and 511.\nYAML accepts both octal and decimal values, JSON requires decimal values for mode bits.\nDefaults to 0644.\nDirectories within the path are not affected by this setting.\nThis might be in conflict with other options that affect the file\nmode, like fsGroup, and the result can be other mode bits set.";
          type = (types.nullOr types.int);
        };
        "items" = mkOption {
          description = "items if unspecified, each key-value pair in the Data field of the referenced\nConfigMap will be projected into the volume as a file whose name is the\nkey and content is the value. If specified, the listed keys will be\nprojected into the specified paths, and unlisted keys will not be\npresent. If a key is specified which is not present in the ConfigMap,\nthe volume setup will error unless it is marked optional. Paths must be\nrelative and may not contain the '..' path or start with '..'.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesConfigMapItems")
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
        "defaultMode" = mkOverride 1002 null;
        "items" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesConfigMapItems" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesCsi" = {

      options = {
        "driver" = mkOption {
          description = "driver is the name of the CSI driver that handles this volume.\nConsult with your admin for the correct name as registered in the cluster.";
          type = types.str;
        };
        "fsType" = mkOption {
          description = "fsType to mount. Ex. \"ext4\", \"xfs\", \"ntfs\".\nIf not provided, the empty value is passed to the associated CSI driver\nwhich will determine the default filesystem to apply.";
          type = (types.nullOr types.str);
        };
        "nodePublishSecretRef" = mkOption {
          description = "nodePublishSecretRef is a reference to the secret object containing\nsensitive information to pass to the CSI driver to complete the CSI\nNodePublishVolume and NodeUnpublishVolume calls.\nThis field is optional, and  may be empty if no secret is required. If the\nsecret object contains more than one secret, all secret references are passed.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesCsiNodePublishSecretRef"
            )
          );
        };
        "readOnly" = mkOption {
          description = "readOnly specifies a read-only configuration for the volume.\nDefaults to false (read/write).";
          type = (types.nullOr types.bool);
        };
        "volumeAttributes" = mkOption {
          description = "volumeAttributes stores driver-specific properties that are passed to the CSI\ndriver. Consult your driver's documentation for supported values.";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "nodePublishSecretRef" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "volumeAttributes" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesCsiNodePublishSecretRef" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesDownwardAPI" = {

      options = {
        "defaultMode" = mkOption {
          description = "Optional: mode bits to use on created files by default. Must be a\nOptional: mode bits used to set permissions on created files by default.\nMust be an octal value between 0000 and 0777 or a decimal value between 0 and 511.\nYAML accepts both octal and decimal values, JSON requires decimal values for mode bits.\nDefaults to 0644.\nDirectories within the path are not affected by this setting.\nThis might be in conflict with other options that affect the file\nmode, like fsGroup, and the result can be other mode bits set.";
          type = (types.nullOr types.int);
        };
        "items" = mkOption {
          description = "Items is a list of downward API volume file";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesDownwardAPIItems")
            )
          );
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "items" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesDownwardAPIItems" = {

      options = {
        "fieldRef" = mkOption {
          description = "Required: Selects a field of the pod: only annotations, labels, name, namespace and uid are supported.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesDownwardAPIItemsFieldRef"
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
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesDownwardAPIItemsResourceFieldRef"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesDownwardAPIItemsFieldRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesDownwardAPIItemsResourceFieldRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEmptyDir" = {

      options = {
        "medium" = mkOption {
          description = "medium represents what type of storage medium should back this directory.\nThe default is \"\" which means to use the node's default medium.\nMust be an empty string (default) or Memory.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#emptydir";
          type = (types.nullOr types.str);
        };
        "sizeLimit" = mkOption {
          description = "sizeLimit is the total amount of local storage required for this EmptyDir volume.\nThe size limit is also applicable for memory medium.\nThe maximum usage on memory medium EmptyDir would be the minimum value between\nthe SizeLimit specified here and the sum of memory limits of all containers in a pod.\nThe default is nil which means that the limit is undefined.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#emptydir";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "medium" = mkOverride 1002 null;
        "sizeLimit" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEphemeral" = {

      options = {
        "volumeClaimTemplate" = mkOption {
          description = "Will be used to create a stand-alone PVC to provision the volume.\nThe pod in which this EphemeralVolumeSource is embedded will be the\nowner of the PVC, i.e. the PVC will be deleted together with the\npod.  The name of the PVC will be `<pod name>-<volume name>` where\n`<volume name>` is the name from the `PodSpec.Volumes` array\nentry. Pod validation will reject the pod if the concatenated name\nis not valid for a PVC (for example, too long).\n\nAn existing PVC with that name that is not owned by the pod\nwill *not* be used for the pod to avoid using an unrelated\nvolume by mistake. Starting the pod is then blocked until\nthe unrelated PVC is removed. If such a pre-created PVC is\nmeant to be used by the pod, the PVC has to updated with an\nowner reference to the pod once the pod exists. Normally\nthis should not be necessary, but it may be useful when\nmanually reconstructing a broken cluster.\n\nThis field is read-only and no changes will be made by Kubernetes\nto the PVC after it has been created.\n\nRequired, must not be nil.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEphemeralVolumeClaimTemplate"
            )
          );
        };
      };

      config = {
        "volumeClaimTemplate" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEphemeralVolumeClaimTemplate" = {

      options = {
        "metadata" = mkOption {
          description = "May contain labels and annotations that will be copied into the PVC\nwhen creating it. No other fields are allowed and will be rejected during\nvalidation.";
          type = (types.nullOr types.attrs);
        };
        "spec" = mkOption {
          description = "The specification for the PersistentVolumeClaim. The entire content is\ncopied unchanged into the PVC that gets created from this\ntemplate. The same fields as in a PersistentVolumeClaim\nare also valid here.";
          type = (
            submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEphemeralVolumeClaimTemplateSpec"
          );
        };
      };

      config = {
        "metadata" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEphemeralVolumeClaimTemplateSpec" = {

      options = {
        "accessModes" = mkOption {
          description = "accessModes contains the desired access modes the volume should have.\nMore info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#access-modes-1";
          type = (types.nullOr (types.listOf types.str));
        };
        "dataSource" = mkOption {
          description = "dataSource field can be used to specify either:\n* An existing VolumeSnapshot object (snapshot.storage.k8s.io/VolumeSnapshot)\n* An existing PVC (PersistentVolumeClaim)\nIf the provisioner or an external controller can support the specified data source,\nit will create a new volume based on the contents of the specified data source.\nWhen the AnyVolumeDataSource feature gate is enabled, dataSource contents will be copied to dataSourceRef,\nand dataSourceRef contents will be copied to dataSource when dataSourceRef.namespace is not specified.\nIf the namespace is specified, then dataSourceRef will not be copied to dataSource.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEphemeralVolumeClaimTemplateSpecDataSource"
            )
          );
        };
        "dataSourceRef" = mkOption {
          description = "dataSourceRef specifies the object from which to populate the volume with data, if a non-empty\nvolume is desired. This may be any object from a non-empty API group (non\ncore object) or a PersistentVolumeClaim object.\nWhen this field is specified, volume binding will only succeed if the type of\nthe specified object matches some installed volume populator or dynamic\nprovisioner.\nThis field will replace the functionality of the dataSource field and as such\nif both fields are non-empty, they must have the same value. For backwards\ncompatibility, when namespace isn't specified in dataSourceRef,\nboth fields (dataSource and dataSourceRef) will be set to the same\nvalue automatically if one of them is empty and the other is non-empty.\nWhen namespace is specified in dataSourceRef,\ndataSource isn't set to the same value and must be empty.\nThere are three important differences between dataSource and dataSourceRef:\n* While dataSource only allows two specific types of objects, dataSourceRef\n  allows any non-core object, as well as PersistentVolumeClaim objects.\n* While dataSource ignores disallowed values (dropping them), dataSourceRef\n  preserves all values, and generates an error if a disallowed value is\n  specified.\n* While dataSource only allows local objects, dataSourceRef allows objects\n  in any namespaces.\n(Beta) Using this field requires the AnyVolumeDataSource feature gate to be enabled.\n(Alpha) Using the namespace field of dataSourceRef requires the CrossNamespaceVolumeDataSource feature gate to be enabled.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEphemeralVolumeClaimTemplateSpecDataSourceRef"
            )
          );
        };
        "resources" = mkOption {
          description = "resources represents the minimum resources the volume should have.\nIf RecoverVolumeExpansionFailure feature is enabled users are allowed to specify resource requirements\nthat are lower than previous value but must still be higher than capacity recorded in the\nstatus field of the claim.\nMore info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#resources";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEphemeralVolumeClaimTemplateSpecResources"
            )
          );
        };
        "selector" = mkOption {
          description = "selector is a label query over volumes to consider for binding.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEphemeralVolumeClaimTemplateSpecSelector"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEphemeralVolumeClaimTemplateSpecDataSource" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEphemeralVolumeClaimTemplateSpecDataSourceRef" =
      {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEphemeralVolumeClaimTemplateSpecResources" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEphemeralVolumeClaimTemplateSpecSelector" = {

      options = {
        "matchExpressions" = mkOption {
          description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEphemeralVolumeClaimTemplateSpecSelectorMatchExpressions"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesEphemeralVolumeClaimTemplateSpecSelectorMatchExpressions" =
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesFc" = {

      options = {
        "fsType" = mkOption {
          description = "fsType is the filesystem type to mount.\nMust be a filesystem type supported by the host operating system.\nEx. \"ext4\", \"xfs\", \"ntfs\". Implicitly inferred to be \"ext4\" if unspecified.";
          type = (types.nullOr types.str);
        };
        "lun" = mkOption {
          description = "lun is Optional: FC target lun number";
          type = (types.nullOr types.int);
        };
        "readOnly" = mkOption {
          description = "readOnly is Optional: Defaults to false (read/write). ReadOnly here will force\nthe ReadOnly setting in VolumeMounts.";
          type = (types.nullOr types.bool);
        };
        "targetWWNs" = mkOption {
          description = "targetWWNs is Optional: FC target worldwide names (WWNs)";
          type = (types.nullOr (types.listOf types.str));
        };
        "wwids" = mkOption {
          description = "wwids Optional: FC volume world wide identifiers (wwids)\nEither wwids or combination of targetWWNs and lun must be set, but not both simultaneously.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "lun" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "targetWWNs" = mkOverride 1002 null;
        "wwids" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesFlexVolume" = {

      options = {
        "driver" = mkOption {
          description = "driver is the name of the driver to use for this volume.";
          type = types.str;
        };
        "fsType" = mkOption {
          description = "fsType is the filesystem type to mount.\nMust be a filesystem type supported by the host operating system.\nEx. \"ext4\", \"xfs\", \"ntfs\". The default filesystem depends on FlexVolume script.";
          type = (types.nullOr types.str);
        };
        "options" = mkOption {
          description = "options is Optional: this field holds extra command options if any.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "readOnly" = mkOption {
          description = "readOnly is Optional: defaults to false (read/write). ReadOnly here will force\nthe ReadOnly setting in VolumeMounts.";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "secretRef is Optional: secretRef is reference to the secret object containing\nsensitive information to pass to the plugin scripts. This may be\nempty if no secret object is specified. If the secret object\ncontains more than one secret, all secrets are passed to the plugin\nscripts.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesFlexVolumeSecretRef")
          );
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "options" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesFlexVolumeSecretRef" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesFlocker" = {

      options = {
        "datasetName" = mkOption {
          description = "datasetName is Name of the dataset stored as metadata -> name on the dataset for Flocker\nshould be considered as deprecated";
          type = (types.nullOr types.str);
        };
        "datasetUUID" = mkOption {
          description = "datasetUUID is the UUID of the dataset. This is unique identifier of a Flocker dataset";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "datasetName" = mkOverride 1002 null;
        "datasetUUID" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesGcePersistentDisk" = {

      options = {
        "fsType" = mkOption {
          description = "fsType is filesystem type of the volume that you want to mount.\nTip: Ensure that the filesystem type is supported by the host operating system.\nExamples: \"ext4\", \"xfs\", \"ntfs\". Implicitly inferred to be \"ext4\" if unspecified.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk";
          type = (types.nullOr types.str);
        };
        "partition" = mkOption {
          description = "partition is the partition in the volume that you want to mount.\nIf omitted, the default is to mount by volume name.\nExamples: For volume /dev/sda1, you specify the partition as \"1\".\nSimilarly, the volume partition for /dev/sda is \"0\" (or you can leave the property empty).\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk";
          type = (types.nullOr types.int);
        };
        "pdName" = mkOption {
          description = "pdName is unique name of the PD resource in GCE. Used to identify the disk in GCE.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "readOnly here will force the ReadOnly setting in VolumeMounts.\nDefaults to false.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#gcepersistentdisk";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "partition" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesGitRepo" = {

      options = {
        "directory" = mkOption {
          description = "directory is the target directory name.\nMust not contain or start with '..'.  If '.' is supplied, the volume directory will be the\ngit repository.  Otherwise, if specified, the volume will contain the git repository in\nthe subdirectory with the given name.";
          type = (types.nullOr types.str);
        };
        "repository" = mkOption {
          description = "repository is the URL";
          type = types.str;
        };
        "revision" = mkOption {
          description = "revision is the commit hash for the specified revision.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "directory" = mkOverride 1002 null;
        "revision" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesGlusterfs" = {

      options = {
        "endpoints" = mkOption {
          description = "endpoints is the endpoint name that details Glusterfs topology.";
          type = types.str;
        };
        "path" = mkOption {
          description = "path is the Glusterfs volume path.\nMore info: https://examples.k8s.io/volumes/glusterfs/README.md#create-a-pod";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "readOnly here will force the Glusterfs volume to be mounted with read-only permissions.\nDefaults to false.\nMore info: https://examples.k8s.io/volumes/glusterfs/README.md#create-a-pod";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesHostPath" = {

      options = {
        "path" = mkOption {
          description = "path of the directory on the host.\nIf the path is a symlink, it will follow the link to the real path.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath";
          type = types.str;
        };
        "type" = mkOption {
          description = "type for HostPath Volume\nDefaults to \"\"\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#hostpath";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "type" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesImage" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesIscsi" = {

      options = {
        "chapAuthDiscovery" = mkOption {
          description = "chapAuthDiscovery defines whether support iSCSI Discovery CHAP authentication";
          type = (types.nullOr types.bool);
        };
        "chapAuthSession" = mkOption {
          description = "chapAuthSession defines whether support iSCSI Session CHAP authentication";
          type = (types.nullOr types.bool);
        };
        "fsType" = mkOption {
          description = "fsType is the filesystem type of the volume that you want to mount.\nTip: Ensure that the filesystem type is supported by the host operating system.\nExamples: \"ext4\", \"xfs\", \"ntfs\". Implicitly inferred to be \"ext4\" if unspecified.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#iscsi";
          type = (types.nullOr types.str);
        };
        "initiatorName" = mkOption {
          description = "initiatorName is the custom iSCSI Initiator Name.\nIf initiatorName is specified with iscsiInterface simultaneously, new iSCSI interface\n<target portal>:<volume name> will be created for the connection.";
          type = (types.nullOr types.str);
        };
        "iqn" = mkOption {
          description = "iqn is the target iSCSI Qualified Name.";
          type = types.str;
        };
        "iscsiInterface" = mkOption {
          description = "iscsiInterface is the interface Name that uses an iSCSI transport.\nDefaults to 'default' (tcp).";
          type = (types.nullOr types.str);
        };
        "lun" = mkOption {
          description = "lun represents iSCSI Target Lun number.";
          type = types.int;
        };
        "portals" = mkOption {
          description = "portals is the iSCSI Target Portal List. The portal is either an IP or ip_addr:port if the port\nis other than default (typically TCP ports 860 and 3260).";
          type = (types.nullOr (types.listOf types.str));
        };
        "readOnly" = mkOption {
          description = "readOnly here will force the ReadOnly setting in VolumeMounts.\nDefaults to false.";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "secretRef is the CHAP Secret for iSCSI target and initiator authentication";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesIscsiSecretRef")
          );
        };
        "targetPortal" = mkOption {
          description = "targetPortal is iSCSI Target Portal. The Portal is either an IP or ip_addr:port if the port\nis other than default (typically TCP ports 860 and 3260).";
          type = types.str;
        };
      };

      config = {
        "chapAuthDiscovery" = mkOverride 1002 null;
        "chapAuthSession" = mkOverride 1002 null;
        "fsType" = mkOverride 1002 null;
        "initiatorName" = mkOverride 1002 null;
        "iscsiInterface" = mkOverride 1002 null;
        "portals" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesIscsiSecretRef" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesNfs" = {

      options = {
        "path" = mkOption {
          description = "path that is exported by the NFS server.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#nfs";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "readOnly here will force the NFS export to be mounted with read-only permissions.\nDefaults to false.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#nfs";
          type = (types.nullOr types.bool);
        };
        "server" = mkOption {
          description = "server is the hostname or IP address of the NFS server.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#nfs";
          type = types.str;
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesPersistentVolumeClaim" = {

      options = {
        "claimName" = mkOption {
          description = "claimName is the name of a PersistentVolumeClaim in the same namespace as the pod using this volume.\nMore info: https://kubernetes.io/docs/concepts/storage/persistent-volumes#persistentvolumeclaims";
          type = types.str;
        };
        "readOnly" = mkOption {
          description = "readOnly Will force the ReadOnly setting in VolumeMounts.\nDefault false.";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "readOnly" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesPhotonPersistentDisk" = {

      options = {
        "fsType" = mkOption {
          description = "fsType is the filesystem type to mount.\nMust be a filesystem type supported by the host operating system.\nEx. \"ext4\", \"xfs\", \"ntfs\". Implicitly inferred to be \"ext4\" if unspecified.";
          type = (types.nullOr types.str);
        };
        "pdID" = mkOption {
          description = "pdID is the ID that identifies Photon Controller persistent disk";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesPortworxVolume" = {

      options = {
        "fsType" = mkOption {
          description = "fSType represents the filesystem type to mount\nMust be a filesystem type supported by the host operating system.\nEx. \"ext4\", \"xfs\". Implicitly inferred to be \"ext4\" if unspecified.";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "readOnly defaults to false (read/write). ReadOnly here will force\nthe ReadOnly setting in VolumeMounts.";
          type = (types.nullOr types.bool);
        };
        "volumeID" = mkOption {
          description = "volumeID uniquely identifies a Portworx volume";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjected" = {

      options = {
        "defaultMode" = mkOption {
          description = "defaultMode are the mode bits used to set permissions on created files by default.\nMust be an octal value between 0000 and 0777 or a decimal value between 0 and 511.\nYAML accepts both octal and decimal values, JSON requires decimal values for mode bits.\nDirectories within the path are not affected by this setting.\nThis might be in conflict with other options that affect the file\nmode, like fsGroup, and the result can be other mode bits set.";
          type = (types.nullOr types.int);
        };
        "sources" = mkOption {
          description = "sources is the list of volume projections. Each entry in this list\nhandles one source.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSources")
            )
          );
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "sources" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSources" = {

      options = {
        "clusterTrustBundle" = mkOption {
          description = "ClusterTrustBundle allows a pod to access the `.spec.trustBundle` field\nof ClusterTrustBundle objects in an auto-updating file.\n\nAlpha, gated by the ClusterTrustBundleProjection feature gate.\n\nClusterTrustBundle objects can either be selected by name, or by the\ncombination of signer name and a label selector.\n\nKubelet performs aggressive normalization of the PEM contents written\ninto the pod filesystem.  Esoteric PEM features such as inter-block\ncomments and block headers are stripped.  Certificates are deduplicated.\nThe ordering of certificates within the file is arbitrary, and Kubelet\nmay change the order over time.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesClusterTrustBundle"
            )
          );
        };
        "configMap" = mkOption {
          description = "configMap information about the configMap data to project";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesConfigMap"
            )
          );
        };
        "downwardAPI" = mkOption {
          description = "downwardAPI information about the downwardAPI data to project";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesDownwardAPI"
            )
          );
        };
        "podCertificate" = mkOption {
          description = "Projects an auto-rotating credential bundle (private key and certificate\nchain) that the pod can use either as a TLS client or server.\n\nKubelet generates a private key and uses it to send a\nPodCertificateRequest to the named signer.  Once the signer approves the\nrequest and issues a certificate chain, Kubelet writes the key and\ncertificate chain to the pod filesystem.  The pod does not start until\ncertificates have been issued for each podCertificate projected volume\nsource in its spec.\n\nKubelet will begin trying to rotate the certificate at the time indicated\nby the signer using the PodCertificateRequest.Status.BeginRefreshAt\ntimestamp.\n\nKubelet can write a single file, indicated by the credentialBundlePath\nfield, or separate files, indicated by the keyPath and\ncertificateChainPath fields.\n\nThe credential bundle is a single file in PEM format.  The first PEM\nentry is the private key (in PKCS#8 format), and the remaining PEM\nentries are the certificate chain issued by the signer (typically,\nsigners will return their certificate chain in leaf-to-root order).\n\nPrefer using the credential bundle format, since your application code\ncan read it atomically.  If you use keyPath and certificateChainPath,\nyour application must make two separate file reads. If these coincide\nwith a certificate rotation, it is possible that the private key and leaf\ncertificate you read may not correspond to each other.  Your application\nwill need to check for this condition, and re-read until they are\nconsistent.\n\nThe named signer controls chooses the format of the certificate it\nissues; consult the signer implementation's documentation to learn how to\nuse the certificates it issues.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesPodCertificate"
            )
          );
        };
        "secret" = mkOption {
          description = "secret information about the secret data to project";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesSecret"
            )
          );
        };
        "serviceAccountToken" = mkOption {
          description = "serviceAccountToken is information about the serviceAccountToken data to project";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesServiceAccountToken"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesClusterTrustBundle" = {

      options = {
        "labelSelector" = mkOption {
          description = "Select all ClusterTrustBundles that match this label selector.  Only has\neffect if signerName is set.  Mutually-exclusive with name.  If unset,\ninterpreted as \"match nothing\".  If set but empty, interpreted as \"match\neverything\".";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesClusterTrustBundleLabelSelector"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesClusterTrustBundleLabelSelector" =
      {

        options = {
          "matchExpressions" = mkOption {
            description = "matchExpressions is a list of label selector requirements. The requirements are ANDed.";
            type = (
              types.nullOr (
                types.listOf (
                  submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesClusterTrustBundleLabelSelectorMatchExpressions"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesClusterTrustBundleLabelSelectorMatchExpressions" =
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesConfigMap" = {

      options = {
        "items" = mkOption {
          description = "items if unspecified, each key-value pair in the Data field of the referenced\nConfigMap will be projected into the volume as a file whose name is the\nkey and content is the value. If specified, the listed keys will be\nprojected into the specified paths, and unlisted keys will not be\npresent. If a key is specified which is not present in the ConfigMap,\nthe volume setup will error unless it is marked optional. Paths must be\nrelative and may not contain the '..' path or start with '..'.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesConfigMapItems"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesConfigMapItems" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesDownwardAPI" = {

      options = {
        "items" = mkOption {
          description = "Items is a list of DownwardAPIVolume file";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesDownwardAPIItems"
              )
            )
          );
        };
      };

      config = {
        "items" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesDownwardAPIItems" = {

      options = {
        "fieldRef" = mkOption {
          description = "Required: Selects a field of the pod: only annotations, labels, name, namespace and uid are supported.";
          type = (
            types.nullOr (
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesDownwardAPIItemsFieldRef"
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
              submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesDownwardAPIItemsResourceFieldRef"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesDownwardAPIItemsFieldRef" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesDownwardAPIItemsResourceFieldRef" =
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesPodCertificate" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesSecret" = {

      options = {
        "items" = mkOption {
          description = "items if unspecified, each key-value pair in the Data field of the referenced\nSecret will be projected into the volume as a file whose name is the\nkey and content is the value. If specified, the listed keys will be\nprojected into the specified paths, and unlisted keys will not be\npresent. If a key is specified which is not present in the Secret,\nthe volume setup will error unless it is marked optional. Paths must be\nrelative and may not contain the '..' path or start with '..'.";
          type = (
            types.nullOr (
              types.listOf (
                submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesSecretItems"
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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesSecretItems" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesProjectedSourcesServiceAccountToken" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesQuobyte" = {

      options = {
        "group" = mkOption {
          description = "group to map volume access to\nDefault is no group";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "readOnly here will force the Quobyte volume to be mounted with read-only permissions.\nDefaults to false.";
          type = (types.nullOr types.bool);
        };
        "registry" = mkOption {
          description = "registry represents a single or multiple Quobyte Registry services\nspecified as a string as host:port pair (multiple entries are separated with commas)\nwhich acts as the central registry for volumes";
          type = types.str;
        };
        "tenant" = mkOption {
          description = "tenant owning the given Quobyte volume in the Backend\nUsed with dynamically provisioned Quobyte volumes, value is set by the plugin";
          type = (types.nullOr types.str);
        };
        "user" = mkOption {
          description = "user to map volume access to\nDefaults to serivceaccount user";
          type = (types.nullOr types.str);
        };
        "volume" = mkOption {
          description = "volume is a string that references an already created Quobyte volume by name.";
          type = types.str;
        };
      };

      config = {
        "group" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "tenant" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesRbd" = {

      options = {
        "fsType" = mkOption {
          description = "fsType is the filesystem type of the volume that you want to mount.\nTip: Ensure that the filesystem type is supported by the host operating system.\nExamples: \"ext4\", \"xfs\", \"ntfs\". Implicitly inferred to be \"ext4\" if unspecified.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#rbd";
          type = (types.nullOr types.str);
        };
        "image" = mkOption {
          description = "image is the rados image name.\nMore info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it";
          type = types.str;
        };
        "keyring" = mkOption {
          description = "keyring is the path to key ring for RBDUser.\nDefault is /etc/ceph/keyring.\nMore info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it";
          type = (types.nullOr types.str);
        };
        "monitors" = mkOption {
          description = "monitors is a collection of Ceph monitors.\nMore info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it";
          type = (types.listOf types.str);
        };
        "pool" = mkOption {
          description = "pool is the rados pool name.\nDefault is rbd.\nMore info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "readOnly here will force the ReadOnly setting in VolumeMounts.\nDefaults to false.\nMore info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "secretRef is name of the authentication secret for RBDUser. If provided\noverrides keyring.\nDefault is nil.\nMore info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesRbdSecretRef")
          );
        };
        "user" = mkOption {
          description = "user is the rados user name.\nDefault is admin.\nMore info: https://examples.k8s.io/volumes/rbd/README.md#how-to-use-it";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "keyring" = mkOverride 1002 null;
        "pool" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
        "user" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesRbdSecretRef" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesScaleIO" = {

      options = {
        "fsType" = mkOption {
          description = "fsType is the filesystem type to mount.\nMust be a filesystem type supported by the host operating system.\nEx. \"ext4\", \"xfs\", \"ntfs\".\nDefault is \"xfs\".";
          type = (types.nullOr types.str);
        };
        "gateway" = mkOption {
          description = "gateway is the host address of the ScaleIO API Gateway.";
          type = types.str;
        };
        "protectionDomain" = mkOption {
          description = "protectionDomain is the name of the ScaleIO Protection Domain for the configured storage.";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "readOnly Defaults to false (read/write). ReadOnly here will force\nthe ReadOnly setting in VolumeMounts.";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "secretRef references to the secret for ScaleIO user and other\nsensitive information. If this is not provided, Login operation will fail.";
          type = (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesScaleIOSecretRef");
        };
        "sslEnabled" = mkOption {
          description = "sslEnabled Flag enable/disable SSL communication with Gateway, default false";
          type = (types.nullOr types.bool);
        };
        "storageMode" = mkOption {
          description = "storageMode indicates whether the storage for a volume should be ThickProvisioned or ThinProvisioned.\nDefault is ThinProvisioned.";
          type = (types.nullOr types.str);
        };
        "storagePool" = mkOption {
          description = "storagePool is the ScaleIO Storage Pool associated with the protection domain.";
          type = (types.nullOr types.str);
        };
        "system" = mkOption {
          description = "system is the name of the storage system as configured in ScaleIO.";
          type = types.str;
        };
        "volumeName" = mkOption {
          description = "volumeName is the name of a volume already created in the ScaleIO system\nthat is associated with this volume source.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "protectionDomain" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "sslEnabled" = mkOverride 1002 null;
        "storageMode" = mkOverride 1002 null;
        "storagePool" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesScaleIOSecretRef" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesSecret" = {

      options = {
        "defaultMode" = mkOption {
          description = "defaultMode is Optional: mode bits used to set permissions on created files by default.\nMust be an octal value between 0000 and 0777 or a decimal value between 0 and 511.\nYAML accepts both octal and decimal values, JSON requires decimal values\nfor mode bits. Defaults to 0644.\nDirectories within the path are not affected by this setting.\nThis might be in conflict with other options that affect the file\nmode, like fsGroup, and the result can be other mode bits set.";
          type = (types.nullOr types.int);
        };
        "items" = mkOption {
          description = "items If unspecified, each key-value pair in the Data field of the referenced\nSecret will be projected into the volume as a file whose name is the\nkey and content is the value. If specified, the listed keys will be\nprojected into the specified paths, and unlisted keys will not be\npresent. If a key is specified which is not present in the Secret,\nthe volume setup will error unless it is marked optional. Paths must be\nrelative and may not contain the '..' path or start with '..'.";
          type = (
            types.nullOr (
              types.listOf (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesSecretItems")
            )
          );
        };
        "optional" = mkOption {
          description = "optional field specify whether the Secret or its keys must be defined";
          type = (types.nullOr types.bool);
        };
        "secretName" = mkOption {
          description = "secretName is the name of the secret in the pod's namespace to use.\nMore info: https://kubernetes.io/docs/concepts/storage/volumes#secret";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "defaultMode" = mkOverride 1002 null;
        "items" = mkOverride 1002 null;
        "optional" = mkOverride 1002 null;
        "secretName" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesSecretItems" = {

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
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesStorageos" = {

      options = {
        "fsType" = mkOption {
          description = "fsType is the filesystem type to mount.\nMust be a filesystem type supported by the host operating system.\nEx. \"ext4\", \"xfs\", \"ntfs\". Implicitly inferred to be \"ext4\" if unspecified.";
          type = (types.nullOr types.str);
        };
        "readOnly" = mkOption {
          description = "readOnly defaults to false (read/write). ReadOnly here will force\nthe ReadOnly setting in VolumeMounts.";
          type = (types.nullOr types.bool);
        };
        "secretRef" = mkOption {
          description = "secretRef specifies the secret to use for obtaining the StorageOS API\ncredentials.  If not specified, default values will be attempted.";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesStorageosSecretRef")
          );
        };
        "volumeName" = mkOption {
          description = "volumeName is the human-readable name of the StorageOS volume.  Volume\nnames are only unique within a namespace.";
          type = (types.nullOr types.str);
        };
        "volumeNamespace" = mkOption {
          description = "volumeNamespace specifies the scope of the volume within StorageOS.  If no\nnamespace is specified then the Pod's namespace will be used.  This allows the\nKubernetes name scoping to be mirrored within StorageOS for tighter integration.\nSet VolumeName to any name to override the default behaviour.\nSet to \"default\" if you are not using namespaces within StorageOS.\nNamespaces that do not pre-exist within StorageOS will be created.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "readOnly" = mkOverride 1002 null;
        "secretRef" = mkOverride 1002 null;
        "volumeName" = mkOverride 1002 null;
        "volumeNamespace" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesStorageosSecretRef" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerSpecTemplateSpecVolumesVsphereVolume" = {

      options = {
        "fsType" = mkOption {
          description = "fsType is filesystem type to mount.\nMust be a filesystem type supported by the host operating system.\nEx. \"ext4\", \"xfs\", \"ntfs\". Implicitly inferred to be \"ext4\" if unspecified.";
          type = (types.nullOr types.str);
        };
        "storagePolicyID" = mkOption {
          description = "storagePolicyID is the storage Policy Based Management (SPBM) profile ID associated with the StoragePolicyName.";
          type = (types.nullOr types.str);
        };
        "storagePolicyName" = mkOption {
          description = "storagePolicyName is the storage Policy Based Management (SPBM) profile name.";
          type = (types.nullOr types.str);
        };
        "volumePath" = mkOption {
          description = "volumePath is the path that identifies vSphere volume vmdk";
          type = types.str;
        };
      };

      config = {
        "fsType" = mkOverride 1002 null;
        "storagePolicyID" = mkOverride 1002 null;
        "storagePolicyName" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerStatus" = {

      options = {
        "instances" = mkOption {
          description = "The number of pods trying to be scheduled";
          type = (types.nullOr types.int);
        };
        "secrets" = mkOption {
          description = "The resource version of the config object";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerStatusSecrets"));
        };
      };

      config = {
        "instances" = mkOverride 1002 null;
        "secrets" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerStatusSecrets" = {

      options = {
        "clientCA" = mkOption {
          description = "The client CA secret version";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerStatusSecretsClientCA"));
        };
        "clientTLS" = mkOption {
          description = "The client TLS secret version";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerStatusSecretsClientTLS"));
        };
        "pgBouncerSecrets" = mkOption {
          description = "The version of the secrets used by PgBouncer";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerStatusSecretsPgBouncerSecrets"));
        };
        "serverCA" = mkOption {
          description = "The server CA secret version";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerStatusSecretsServerCA"));
        };
        "serverTLS" = mkOption {
          description = "The server TLS secret version";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerStatusSecretsServerTLS"));
        };
      };

      config = {
        "clientCA" = mkOverride 1002 null;
        "clientTLS" = mkOverride 1002 null;
        "pgBouncerSecrets" = mkOverride 1002 null;
        "serverCA" = mkOverride 1002 null;
        "serverTLS" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerStatusSecretsClientCA" = {

      options = {
        "name" = mkOption {
          description = "The name of the secret";
          type = (types.nullOr types.str);
        };
        "version" = mkOption {
          description = "The ResourceVersion of the secret";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "version" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerStatusSecretsClientTLS" = {

      options = {
        "name" = mkOption {
          description = "The name of the secret";
          type = (types.nullOr types.str);
        };
        "version" = mkOption {
          description = "The ResourceVersion of the secret";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "version" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerStatusSecretsPgBouncerSecrets" = {

      options = {
        "authQuery" = mkOption {
          description = "The auth query secret version";
          type = (
            types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PoolerStatusSecretsPgBouncerSecretsAuthQuery")
          );
        };
      };

      config = {
        "authQuery" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerStatusSecretsPgBouncerSecretsAuthQuery" = {

      options = {
        "name" = mkOption {
          description = "The name of the secret";
          type = (types.nullOr types.str);
        };
        "version" = mkOption {
          description = "The ResourceVersion of the secret";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "version" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerStatusSecretsServerCA" = {

      options = {
        "name" = mkOption {
          description = "The name of the secret";
          type = (types.nullOr types.str);
        };
        "version" = mkOption {
          description = "The ResourceVersion of the secret";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "version" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PoolerStatusSecretsServerTLS" = {

      options = {
        "name" = mkOption {
          description = "The name of the secret";
          type = (types.nullOr types.str);
        };
        "version" = mkOption {
          description = "The ResourceVersion of the secret";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
        "version" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.Publication" = {

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
          description = "PublicationSpec defines the desired state of Publication";
          type = (submoduleOf "postgresql.cnpg.io.v1.PublicationSpec");
        };
        "status" = mkOption {
          description = "PublicationStatus defines the observed state of Publication";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PublicationStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PublicationSpec" = {

      options = {
        "cluster" = mkOption {
          description = "The name of the PostgreSQL cluster that identifies the \"publisher\"";
          type = (submoduleOf "postgresql.cnpg.io.v1.PublicationSpecCluster");
        };
        "dbname" = mkOption {
          description = "The name of the database where the publication will be installed in\nthe \"publisher\" cluster";
          type = types.str;
        };
        "name" = mkOption {
          description = "The name of the publication inside PostgreSQL";
          type = types.str;
        };
        "parameters" = mkOption {
          description = "Publication parameters part of the `WITH` clause as expected by\nPostgreSQL `CREATE PUBLICATION` command";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "publicationReclaimPolicy" = mkOption {
          description = "The policy for end-of-life maintenance of this publication";
          type = (types.nullOr types.str);
        };
        "target" = mkOption {
          description = "Target of the publication as expected by PostgreSQL `CREATE PUBLICATION` command";
          type = (submoduleOf "postgresql.cnpg.io.v1.PublicationSpecTarget");
        };
      };

      config = {
        "parameters" = mkOverride 1002 null;
        "publicationReclaimPolicy" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PublicationSpecCluster" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PublicationSpecTarget" = {

      options = {
        "allTables" = mkOption {
          description = "Marks the publication as one that replicates changes for all tables\nin the database, including tables created in the future.\nCorresponding to `FOR ALL TABLES` in PostgreSQL.";
          type = (types.nullOr types.bool);
        };
        "objects" = mkOption {
          description = "Just the following schema objects";
          type = (
            types.nullOr (types.listOf (submoduleOf "postgresql.cnpg.io.v1.PublicationSpecTargetObjects"))
          );
        };
      };

      config = {
        "allTables" = mkOverride 1002 null;
        "objects" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PublicationSpecTargetObjects" = {

      options = {
        "table" = mkOption {
          description = "Specifies a list of tables to add to the publication. Corresponding\nto `FOR TABLE` in PostgreSQL.";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.PublicationSpecTargetObjectsTable"));
        };
        "tablesInSchema" = mkOption {
          description = "Marks the publication as one that replicates changes for all tables\nin the specified list of schemas, including tables created in the\nfuture. Corresponding to `FOR TABLES IN SCHEMA` in PostgreSQL.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "table" = mkOverride 1002 null;
        "tablesInSchema" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PublicationSpecTargetObjectsTable" = {

      options = {
        "columns" = mkOption {
          description = "The columns to publish";
          type = (types.nullOr (types.listOf types.str));
        };
        "name" = mkOption {
          description = "The table name";
          type = types.str;
        };
        "only" = mkOption {
          description = "Whether to limit to the table only or include all its descendants";
          type = (types.nullOr types.bool);
        };
        "schema" = mkOption {
          description = "The schema name";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "columns" = mkOverride 1002 null;
        "only" = mkOverride 1002 null;
        "schema" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.PublicationStatus" = {

      options = {
        "applied" = mkOption {
          description = "Applied is true if the publication was reconciled correctly";
          type = (types.nullOr types.bool);
        };
        "message" = mkOption {
          description = "Message is the reconciliation output message";
          type = (types.nullOr types.str);
        };
        "observedGeneration" = mkOption {
          description = "A sequence number representing the latest\ndesired state that was synchronized";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "applied" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "observedGeneration" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ScheduledBackup" = {

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
          description = "Specification of the desired behavior of the ScheduledBackup.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status";
          type = (submoduleOf "postgresql.cnpg.io.v1.ScheduledBackupSpec");
        };
        "status" = mkOption {
          description = "Most recently observed status of the ScheduledBackup. This data may not be up\nto date. Populated by the system. Read-only.\nMore info: https://git.k8s.io/community/contributors/devel/sig-architecture/api-conventions.md#spec-and-status";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ScheduledBackupStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ScheduledBackupSpec" = {

      options = {
        "backupOwnerReference" = mkOption {
          description = "Indicates which ownerReference should be put inside the created backup resources.<br />\n- none: no owner reference for created backup objects (same behavior as before the field was introduced)<br />\n- self: sets the Scheduled backup object as owner of the backup<br />\n- cluster: set the cluster as owner of the backup<br />";
          type = (types.nullOr types.str);
        };
        "cluster" = mkOption {
          description = "The cluster to backup";
          type = (submoduleOf "postgresql.cnpg.io.v1.ScheduledBackupSpecCluster");
        };
        "immediate" = mkOption {
          description = "If the first backup has to be immediately start after creation or not";
          type = (types.nullOr types.bool);
        };
        "method" = mkOption {
          description = "The backup method to be used, possible options are `barmanObjectStore`,\n`volumeSnapshot` or `plugin`. Defaults to: `barmanObjectStore`.";
          type = (types.nullOr types.str);
        };
        "online" = mkOption {
          description = "Whether the default type of backup with volume snapshots is\nonline/hot (`true`, default) or offline/cold (`false`)\nOverrides the default setting specified in the cluster field '.spec.backup.volumeSnapshot.online'";
          type = (types.nullOr types.bool);
        };
        "onlineConfiguration" = mkOption {
          description = "Configuration parameters to control the online/hot backup with volume snapshots\nOverrides the default settings specified in the cluster '.backup.volumeSnapshot.onlineConfiguration' stanza";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ScheduledBackupSpecOnlineConfiguration"));
        };
        "pluginConfiguration" = mkOption {
          description = "Configuration parameters passed to the plugin managing this backup";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.ScheduledBackupSpecPluginConfiguration"));
        };
        "schedule" = mkOption {
          description = "The schedule does not follow the same format used in Kubernetes CronJobs\nas it includes an additional seconds specifier,\nsee https://pkg.go.dev/github.com/robfig/cron#hdr-CRON_Expression_Format";
          type = types.str;
        };
        "suspend" = mkOption {
          description = "If this backup is suspended or not";
          type = (types.nullOr types.bool);
        };
        "target" = mkOption {
          description = "The policy to decide which instance should perform this backup. If empty,\nit defaults to `cluster.spec.backup.target`.\nAvailable options are empty string, `primary` and `prefer-standby`.\n`primary` to have backups run always on primary instances,\n`prefer-standby` to have backups run preferably on the most updated\nstandby, if available.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "backupOwnerReference" = mkOverride 1002 null;
        "immediate" = mkOverride 1002 null;
        "method" = mkOverride 1002 null;
        "online" = mkOverride 1002 null;
        "onlineConfiguration" = mkOverride 1002 null;
        "pluginConfiguration" = mkOverride 1002 null;
        "suspend" = mkOverride 1002 null;
        "target" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ScheduledBackupSpecCluster" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.";
          type = types.str;
        };
      };

      config = { };

    };
    "postgresql.cnpg.io.v1.ScheduledBackupSpecOnlineConfiguration" = {

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
    "postgresql.cnpg.io.v1.ScheduledBackupSpecPluginConfiguration" = {

      options = {
        "name" = mkOption {
          description = "Name is the name of the plugin managing this backup";
          type = types.str;
        };
        "parameters" = mkOption {
          description = "Parameters are the configuration parameters passed to the backup\nplugin for this backup";
          type = (types.nullOr (types.attrsOf types.str));
        };
      };

      config = {
        "parameters" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.ScheduledBackupStatus" = {

      options = {
        "lastCheckTime" = mkOption {
          description = "The latest time the schedule";
          type = (types.nullOr types.str);
        };
        "lastScheduleTime" = mkOption {
          description = "Information when was the last time that backup was successfully scheduled.";
          type = (types.nullOr types.str);
        };
        "nextScheduleTime" = mkOption {
          description = "Next time we will run a backup";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "lastCheckTime" = mkOverride 1002 null;
        "lastScheduleTime" = mkOverride 1002 null;
        "nextScheduleTime" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.Subscription" = {

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
          description = "SubscriptionSpec defines the desired state of Subscription";
          type = (submoduleOf "postgresql.cnpg.io.v1.SubscriptionSpec");
        };
        "status" = mkOption {
          description = "SubscriptionStatus defines the observed state of Subscription";
          type = (types.nullOr (submoduleOf "postgresql.cnpg.io.v1.SubscriptionStatus"));
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.SubscriptionSpec" = {

      options = {
        "cluster" = mkOption {
          description = "The name of the PostgreSQL cluster that identifies the \"subscriber\"";
          type = (submoduleOf "postgresql.cnpg.io.v1.SubscriptionSpecCluster");
        };
        "dbname" = mkOption {
          description = "The name of the database where the publication will be installed in\nthe \"subscriber\" cluster";
          type = types.str;
        };
        "externalClusterName" = mkOption {
          description = "The name of the external cluster with the publication (\"publisher\")";
          type = types.str;
        };
        "name" = mkOption {
          description = "The name of the subscription inside PostgreSQL";
          type = types.str;
        };
        "parameters" = mkOption {
          description = "Subscription parameters included in the `WITH` clause of the PostgreSQL\n`CREATE SUBSCRIPTION` command. Most parameters cannot be changed\nafter the subscription is created and will be ignored if modified\nlater, except for a limited set documented at:\nhttps://www.postgresql.org/docs/current/sql-altersubscription.html#SQL-ALTERSUBSCRIPTION-PARAMS-SET";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "publicationDBName" = mkOption {
          description = "The name of the database containing the publication on the external\ncluster. Defaults to the one in the external cluster definition.";
          type = (types.nullOr types.str);
        };
        "publicationName" = mkOption {
          description = "The name of the publication inside the PostgreSQL database in the\n\"publisher\"";
          type = types.str;
        };
        "subscriptionReclaimPolicy" = mkOption {
          description = "The policy for end-of-life maintenance of this subscription";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "parameters" = mkOverride 1002 null;
        "publicationDBName" = mkOverride 1002 null;
        "subscriptionReclaimPolicy" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.SubscriptionSpecCluster" = {

      options = {
        "name" = mkOption {
          description = "Name of the referent.\nThis field is effectively required, but due to backwards compatibility is\nallowed to be empty. Instances of this type with an empty value here are\nalmost certainly wrong.\nMore info: https://kubernetes.io/docs/concepts/overview/working-with-objects/names/#names";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "name" = mkOverride 1002 null;
      };

    };
    "postgresql.cnpg.io.v1.SubscriptionStatus" = {

      options = {
        "applied" = mkOption {
          description = "Applied is true if the subscription was reconciled correctly";
          type = (types.nullOr types.bool);
        };
        "message" = mkOption {
          description = "Message is the reconciliation output message";
          type = (types.nullOr types.str);
        };
        "observedGeneration" = mkOption {
          description = "A sequence number representing the latest\ndesired state that was synchronized";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "applied" = mkOverride 1002 null;
        "message" = mkOverride 1002 null;
        "observedGeneration" = mkOverride 1002 null;
      };

    };

  };
in
{
  # all resource versions
  options = {
    resources = {
      "postgresql.cnpg.io"."v1"."Backup" = mkOption {
        description = "A Backup resource is a request for a PostgreSQL backup by the user.";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.Backup" "backups" "Backup" "postgresql.cnpg.io" "v1"
          )
        );
        default = { };
      };
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
      "postgresql.cnpg.io"."v1"."ClusterImageCatalog" = mkOption {
        description = "ClusterImageCatalog is the Schema for the clusterimagecatalogs API";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.ClusterImageCatalog" "clusterimagecatalogs"
              "ClusterImageCatalog"
              "postgresql.cnpg.io"
              "v1"
          )
        );
        default = { };
      };
      "postgresql.cnpg.io"."v1"."Database" = mkOption {
        description = "Database is the Schema for the databases API";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.Database" "databases" "Database" "postgresql.cnpg.io"
              "v1"
          )
        );
        default = { };
      };
      "postgresql.cnpg.io"."v1"."FailoverQuorum" = mkOption {
        description = "FailoverQuorum contains the information about the current failover\nquorum status of a PG cluster. It is updated by the instance manager\nof the primary node and reset to zero by the operator to trigger\nan update.";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.FailoverQuorum" "failoverquorums" "FailoverQuorum"
              "postgresql.cnpg.io"
              "v1"
          )
        );
        default = { };
      };
      "postgresql.cnpg.io"."v1"."ImageCatalog" = mkOption {
        description = "ImageCatalog is the Schema for the imagecatalogs API";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.ImageCatalog" "imagecatalogs" "ImageCatalog"
              "postgresql.cnpg.io"
              "v1"
          )
        );
        default = { };
      };
      "postgresql.cnpg.io"."v1"."Pooler" = mkOption {
        description = "Pooler is the Schema for the poolers API";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.Pooler" "poolers" "Pooler" "postgresql.cnpg.io" "v1"
          )
        );
        default = { };
      };
      "postgresql.cnpg.io"."v1"."Publication" = mkOption {
        description = "Publication is the Schema for the publications API";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.Publication" "publications" "Publication"
              "postgresql.cnpg.io"
              "v1"
          )
        );
        default = { };
      };
      "postgresql.cnpg.io"."v1"."ScheduledBackup" = mkOption {
        description = "ScheduledBackup is the Schema for the scheduledbackups API";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.ScheduledBackup" "scheduledbackups" "ScheduledBackup"
              "postgresql.cnpg.io"
              "v1"
          )
        );
        default = { };
      };
      "postgresql.cnpg.io"."v1"."Subscription" = mkOption {
        description = "Subscription is the Schema for the subscriptions API";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.Subscription" "subscriptions" "Subscription"
              "postgresql.cnpg.io"
              "v1"
          )
        );
        default = { };
      };

    }
    // {
      "backups" = mkOption {
        description = "A Backup resource is a request for a PostgreSQL backup by the user.";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.Backup" "backups" "Backup" "postgresql.cnpg.io" "v1"
          )
        );
        default = { };
      };
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
      "clusterImageCatalogs" = mkOption {
        description = "ClusterImageCatalog is the Schema for the clusterimagecatalogs API";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.ClusterImageCatalog" "clusterimagecatalogs"
              "ClusterImageCatalog"
              "postgresql.cnpg.io"
              "v1"
          )
        );
        default = { };
      };
      "databases" = mkOption {
        description = "Database is the Schema for the databases API";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.Database" "databases" "Database" "postgresql.cnpg.io"
              "v1"
          )
        );
        default = { };
      };
      "failoverQuorums" = mkOption {
        description = "FailoverQuorum contains the information about the current failover\nquorum status of a PG cluster. It is updated by the instance manager\nof the primary node and reset to zero by the operator to trigger\nan update.";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.FailoverQuorum" "failoverquorums" "FailoverQuorum"
              "postgresql.cnpg.io"
              "v1"
          )
        );
        default = { };
      };
      "imageCatalogs" = mkOption {
        description = "ImageCatalog is the Schema for the imagecatalogs API";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.ImageCatalog" "imagecatalogs" "ImageCatalog"
              "postgresql.cnpg.io"
              "v1"
          )
        );
        default = { };
      };
      "poolers" = mkOption {
        description = "Pooler is the Schema for the poolers API";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.Pooler" "poolers" "Pooler" "postgresql.cnpg.io" "v1"
          )
        );
        default = { };
      };
      "publications" = mkOption {
        description = "Publication is the Schema for the publications API";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.Publication" "publications" "Publication"
              "postgresql.cnpg.io"
              "v1"
          )
        );
        default = { };
      };
      "scheduledBackups" = mkOption {
        description = "ScheduledBackup is the Schema for the scheduledbackups API";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.ScheduledBackup" "scheduledbackups" "ScheduledBackup"
              "postgresql.cnpg.io"
              "v1"
          )
        );
        default = { };
      };
      "subscriptions" = mkOption {
        description = "Subscription is the Schema for the subscriptions API";
        type = (
          types.attrsOf (
            submoduleForDefinition "postgresql.cnpg.io.v1.Subscription" "subscriptions" "Subscription"
              "postgresql.cnpg.io"
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
        name = "backups";
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "Backup";
        attrName = "backups";
      }
      {
        name = "clusters";
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "Cluster";
        attrName = "clusters";
      }
      {
        name = "clusterimagecatalogs";
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "ClusterImageCatalog";
        attrName = "clusterImageCatalogs";
      }
      {
        name = "databases";
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "Database";
        attrName = "databases";
      }
      {
        name = "failoverquorums";
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "FailoverQuorum";
        attrName = "failoverQuorums";
      }
      {
        name = "imagecatalogs";
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "ImageCatalog";
        attrName = "imageCatalogs";
      }
      {
        name = "poolers";
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "Pooler";
        attrName = "poolers";
      }
      {
        name = "publications";
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "Publication";
        attrName = "publications";
      }
      {
        name = "scheduledbackups";
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "ScheduledBackup";
        attrName = "scheduledBackups";
      }
      {
        name = "subscriptions";
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "Subscription";
        attrName = "subscriptions";
      }
    ];

    resources = {
      "postgresql.cnpg.io"."v1"."Backup" = mkAliasDefinitions options.resources."backups";
      "postgresql.cnpg.io"."v1"."Cluster" = mkAliasDefinitions options.resources."clusters";
      "postgresql.cnpg.io"."v1"."ClusterImageCatalog" =
        mkAliasDefinitions
          options.resources."clusterImageCatalogs";
      "postgresql.cnpg.io"."v1"."Database" = mkAliasDefinitions options.resources."databases";
      "postgresql.cnpg.io"."v1"."FailoverQuorum" = mkAliasDefinitions options.resources."failoverQuorums";
      "postgresql.cnpg.io"."v1"."ImageCatalog" = mkAliasDefinitions options.resources."imageCatalogs";
      "postgresql.cnpg.io"."v1"."Pooler" = mkAliasDefinitions options.resources."poolers";
      "postgresql.cnpg.io"."v1"."Publication" = mkAliasDefinitions options.resources."publications";
      "postgresql.cnpg.io"."v1"."ScheduledBackup" =
        mkAliasDefinitions
          options.resources."scheduledBackups";
      "postgresql.cnpg.io"."v1"."Subscription" = mkAliasDefinitions options.resources."subscriptions";

    };

    # make all namespaced resources default to the
    # application's namespace
    defaults = [
      {
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "Backup";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
      {
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "Cluster";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
      {
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "Database";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
      {
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "FailoverQuorum";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
      {
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "ImageCatalog";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
      {
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "Pooler";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
      {
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "Publication";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
      {
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "ScheduledBackup";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
      {
        group = "postgresql.cnpg.io";
        version = "v1";
        kind = "Subscription";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
    ];
  };
}
