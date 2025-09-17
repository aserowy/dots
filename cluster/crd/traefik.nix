# This file was generated with nixidy CRD generator, do not edit.
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
    "traefik.io.v1alpha1.IngressRoute" = {

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
          description = "IngressRouteSpec defines the desired state of IngressRoute.";
          type = (submoduleOf "traefik.io.v1alpha1.IngressRouteSpec");
        };
      };

      config = {
        "apiVersion" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
      };

    };
    "traefik.io.v1alpha1.IngressRouteSpec" = {

      options = {
        "entryPoints" = mkOption {
          description = "EntryPoints defines the list of entry point names to bind to.\nEntry points have to be configured in the static configuration.\nMore info: https://doc.traefik.io/traefik/v3.5/routing/entrypoints/\nDefault: all.";
          type = (types.nullOr (types.listOf types.str));
        };
        "routes" = mkOption {
          description = "Routes defines the list of routes.";
          type = (types.listOf (submoduleOf "traefik.io.v1alpha1.IngressRouteSpecRoutes"));
        };
        "tls" = mkOption {
          description = "TLS defines the TLS configuration.\nMore info: https://doc.traefik.io/traefik/v3.5/routing/routers/#tls";
          type = (types.nullOr (submoduleOf "traefik.io.v1alpha1.IngressRouteSpecTls"));
        };
      };

      config = {
        "entryPoints" = mkOverride 1002 null;
        "tls" = mkOverride 1002 null;
      };

    };
    "traefik.io.v1alpha1.IngressRouteSpecRoutes" = {

      options = {
        "kind" = mkOption {
          description = "Kind defines the kind of the route.\nRule is the only supported kind.\nIf not defined, defaults to Rule.";
          type = (types.nullOr types.str);
        };
        "match" = mkOption {
          description = "Match defines the router's rule.\nMore info: https://doc.traefik.io/traefik/v3.5/routing/routers/#rule";
          type = types.str;
        };
        "middlewares" = mkOption {
          description = "Middlewares defines the list of references to Middleware resources.\nMore info: https://doc.traefik.io/traefik/v3.5/routing/providers/kubernetes-crd/#kind-middleware";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "traefik.io.v1alpha1.IngressRouteSpecRoutesMiddlewares" "name"
                [ ]
            )
          );
          apply = attrsToList;
        };
        "observability" = mkOption {
          description = "Observability defines the observability configuration for a router.\nMore info: https://doc.traefik.io/traefik/v3.5/routing/routers/#observability";
          type = (types.nullOr (submoduleOf "traefik.io.v1alpha1.IngressRouteSpecRoutesObservability"));
        };
        "priority" = mkOption {
          description = "Priority defines the router's priority.\nMore info: https://doc.traefik.io/traefik/v3.5/routing/routers/#priority";
          type = (types.nullOr types.int);
        };
        "services" = mkOption {
          description = "Services defines the list of Service.\nIt can contain any combination of TraefikService and/or reference to a Kubernetes Service.";
          type = (
            types.nullOr (
              coerceAttrsOfSubmodulesToListByKey "traefik.io.v1alpha1.IngressRouteSpecRoutesServices" "name" [ ]
            )
          );
          apply = attrsToList;
        };
        "syntax" = mkOption {
          description = "Syntax defines the router's rule syntax.\nMore info: https://doc.traefik.io/traefik/v3.5/routing/routers/#rulesyntax\nDeprecated: Please do not use this field and rewrite the router rules to use the v3 syntax.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "kind" = mkOverride 1002 null;
        "middlewares" = mkOverride 1002 null;
        "observability" = mkOverride 1002 null;
        "priority" = mkOverride 1002 null;
        "services" = mkOverride 1002 null;
        "syntax" = mkOverride 1002 null;
      };

    };
    "traefik.io.v1alpha1.IngressRouteSpecRoutesMiddlewares" = {

      options = {
        "name" = mkOption {
          description = "Name defines the name of the referenced Middleware resource.";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "Namespace defines the namespace of the referenced Middleware resource.";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "namespace" = mkOverride 1002 null;
      };

    };
    "traefik.io.v1alpha1.IngressRouteSpecRoutesObservability" = {

      options = {
        "accessLogs" = mkOption {
          description = "AccessLogs enables access logs for this router.";
          type = (types.nullOr types.bool);
        };
        "metrics" = mkOption {
          description = "Metrics enables metrics for this router.";
          type = (types.nullOr types.bool);
        };
        "traceVerbosity" = mkOption {
          description = "TraceVerbosity defines the verbosity level of the tracing for this router.";
          type = (types.nullOr types.str);
        };
        "tracing" = mkOption {
          description = "Tracing enables tracing for this router.";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "accessLogs" = mkOverride 1002 null;
        "metrics" = mkOverride 1002 null;
        "traceVerbosity" = mkOverride 1002 null;
        "tracing" = mkOverride 1002 null;
      };

    };
    "traefik.io.v1alpha1.IngressRouteSpecRoutesServices" = {

      options = {
        "healthCheck" = mkOption {
          description = "Healthcheck defines health checks for ExternalName services.";
          type = (types.nullOr (submoduleOf "traefik.io.v1alpha1.IngressRouteSpecRoutesServicesHealthCheck"));
        };
        "kind" = mkOption {
          description = "Kind defines the kind of the Service.";
          type = (types.nullOr types.str);
        };
        "name" = mkOption {
          description = "Name defines the name of the referenced Kubernetes Service or TraefikService.\nThe differentiation between the two is specified in the Kind field.";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "Namespace defines the namespace of the referenced Kubernetes Service or TraefikService.";
          type = (types.nullOr types.str);
        };
        "nativeLB" = mkOption {
          description = "NativeLB controls, when creating the load-balancer,\nwhether the LB's children are directly the pods IPs or if the only child is the Kubernetes Service clusterIP.\nThe Kubernetes Service itself does load-balance to the pods.\nBy default, NativeLB is false.";
          type = (types.nullOr types.bool);
        };
        "nodePortLB" = mkOption {
          description = "NodePortLB controls, when creating the load-balancer,\nwhether the LB's children are directly the nodes internal IPs using the nodePort when the service type is NodePort.\nIt allows services to be reachable when Traefik runs externally from the Kubernetes cluster but within the same network of the nodes.\nBy default, NodePortLB is false.";
          type = (types.nullOr types.bool);
        };
        "passHostHeader" = mkOption {
          description = "PassHostHeader defines whether the client Host header is forwarded to the upstream Kubernetes Service.\nBy default, passHostHeader is true.";
          type = (types.nullOr types.bool);
        };
        "port" = mkOption {
          description = "Port defines the port of a Kubernetes Service.\nThis can be a reference to a named port.";
          type = (types.nullOr (types.either types.int types.str));
        };
        "responseForwarding" = mkOption {
          description = "ResponseForwarding defines how Traefik forwards the response from the upstream Kubernetes Service to the client.";
          type = (
            types.nullOr (submoduleOf "traefik.io.v1alpha1.IngressRouteSpecRoutesServicesResponseForwarding")
          );
        };
        "scheme" = mkOption {
          description = "Scheme defines the scheme to use for the request to the upstream Kubernetes Service.\nIt defaults to https when Kubernetes Service port is 443, http otherwise.";
          type = (types.nullOr types.str);
        };
        "serversTransport" = mkOption {
          description = "ServersTransport defines the name of ServersTransport resource to use.\nIt allows to configure the transport between Traefik and your servers.\nCan only be used on a Kubernetes Service.";
          type = (types.nullOr types.str);
        };
        "sticky" = mkOption {
          description = "Sticky defines the sticky sessions configuration.\nMore info: https://doc.traefik.io/traefik/v3.5/routing/services/#sticky-sessions";
          type = (types.nullOr (submoduleOf "traefik.io.v1alpha1.IngressRouteSpecRoutesServicesSticky"));
        };
        "strategy" = mkOption {
          description = "Strategy defines the load balancing strategy between the servers.\nSupported values are: wrr (Weighed round-robin) and p2c (Power of two choices).\nRoundRobin value is deprecated and supported for backward compatibility.";
          type = (types.nullOr types.str);
        };
        "weight" = mkOption {
          description = "Weight defines the weight and should only be specified when Name references a TraefikService object\n(and to be precise, one that embeds a Weighted Round Robin).";
          type = (types.nullOr types.int);
        };
      };

      config = {
        "healthCheck" = mkOverride 1002 null;
        "kind" = mkOverride 1002 null;
        "namespace" = mkOverride 1002 null;
        "nativeLB" = mkOverride 1002 null;
        "nodePortLB" = mkOverride 1002 null;
        "passHostHeader" = mkOverride 1002 null;
        "port" = mkOverride 1002 null;
        "responseForwarding" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
        "serversTransport" = mkOverride 1002 null;
        "sticky" = mkOverride 1002 null;
        "strategy" = mkOverride 1002 null;
        "weight" = mkOverride 1002 null;
      };

    };
    "traefik.io.v1alpha1.IngressRouteSpecRoutesServicesHealthCheck" = {

      options = {
        "followRedirects" = mkOption {
          description = "FollowRedirects defines whether redirects should be followed during the health check calls.\nDefault: true";
          type = (types.nullOr types.bool);
        };
        "headers" = mkOption {
          description = "Headers defines custom headers to be sent to the health check endpoint.";
          type = (types.nullOr (types.attrsOf types.str));
        };
        "hostname" = mkOption {
          description = "Hostname defines the value of hostname in the Host header of the health check request.";
          type = (types.nullOr types.str);
        };
        "interval" = mkOption {
          description = "Interval defines the frequency of the health check calls for healthy targets.\nDefault: 30s";
          type = (types.nullOr (types.either types.int types.str));
        };
        "method" = mkOption {
          description = "Method defines the healthcheck method.";
          type = (types.nullOr types.str);
        };
        "mode" = mkOption {
          description = "Mode defines the health check mode.\nIf defined to grpc, will use the gRPC health check protocol to probe the server.\nDefault: http";
          type = (types.nullOr types.str);
        };
        "path" = mkOption {
          description = "Path defines the server URL path for the health check endpoint.";
          type = (types.nullOr types.str);
        };
        "port" = mkOption {
          description = "Port defines the server URL port for the health check endpoint.";
          type = (types.nullOr types.int);
        };
        "scheme" = mkOption {
          description = "Scheme replaces the server URL scheme for the health check endpoint.";
          type = (types.nullOr types.str);
        };
        "status" = mkOption {
          description = "Status defines the expected HTTP status code of the response to the health check request.";
          type = (types.nullOr types.int);
        };
        "timeout" = mkOption {
          description = "Timeout defines the maximum duration Traefik will wait for a health check request before considering the server unhealthy.\nDefault: 5s";
          type = (types.nullOr (types.either types.int types.str));
        };
        "unhealthyInterval" = mkOption {
          description = "UnhealthyInterval defines the frequency of the health check calls for unhealthy targets.\nWhen UnhealthyInterval is not defined, it defaults to the Interval value.\nDefault: 30s";
          type = (types.nullOr (types.either types.int types.str));
        };
      };

      config = {
        "followRedirects" = mkOverride 1002 null;
        "headers" = mkOverride 1002 null;
        "hostname" = mkOverride 1002 null;
        "interval" = mkOverride 1002 null;
        "method" = mkOverride 1002 null;
        "mode" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "port" = mkOverride 1002 null;
        "scheme" = mkOverride 1002 null;
        "status" = mkOverride 1002 null;
        "timeout" = mkOverride 1002 null;
        "unhealthyInterval" = mkOverride 1002 null;
      };

    };
    "traefik.io.v1alpha1.IngressRouteSpecRoutesServicesResponseForwarding" = {

      options = {
        "flushInterval" = mkOption {
          description = "FlushInterval defines the interval, in milliseconds, in between flushes to the client while copying the response body.\nA negative value means to flush immediately after each write to the client.\nThis configuration is ignored when ReverseProxy recognizes a response as a streaming response;\nfor such responses, writes are flushed to the client immediately.\nDefault: 100ms";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "flushInterval" = mkOverride 1002 null;
      };

    };
    "traefik.io.v1alpha1.IngressRouteSpecRoutesServicesSticky" = {

      options = {
        "cookie" = mkOption {
          description = "Cookie defines the sticky cookie configuration.";
          type = (
            types.nullOr (submoduleOf "traefik.io.v1alpha1.IngressRouteSpecRoutesServicesStickyCookie")
          );
        };
      };

      config = {
        "cookie" = mkOverride 1002 null;
      };

    };
    "traefik.io.v1alpha1.IngressRouteSpecRoutesServicesStickyCookie" = {

      options = {
        "domain" = mkOption {
          description = "Domain defines the host to which the cookie will be sent.\nMore info: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie#domaindomain-value";
          type = (types.nullOr types.str);
        };
        "httpOnly" = mkOption {
          description = "HTTPOnly defines whether the cookie can be accessed by client-side APIs, such as JavaScript.";
          type = (types.nullOr types.bool);
        };
        "maxAge" = mkOption {
          description = "MaxAge defines the number of seconds until the cookie expires.\nWhen set to a negative number, the cookie expires immediately.\nWhen set to zero, the cookie never expires.";
          type = (types.nullOr types.int);
        };
        "name" = mkOption {
          description = "Name defines the Cookie name.";
          type = (types.nullOr types.str);
        };
        "path" = mkOption {
          description = "Path defines the path that must exist in the requested URL for the browser to send the Cookie header.\nWhen not provided the cookie will be sent on every request to the domain.\nMore info: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie#pathpath-value";
          type = (types.nullOr types.str);
        };
        "sameSite" = mkOption {
          description = "SameSite defines the same site policy.\nMore info: https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/Set-Cookie/SameSite";
          type = (types.nullOr types.str);
        };
        "secure" = mkOption {
          description = "Secure defines whether the cookie can only be transmitted over an encrypted connection (i.e. HTTPS).";
          type = (types.nullOr types.bool);
        };
      };

      config = {
        "domain" = mkOverride 1002 null;
        "httpOnly" = mkOverride 1002 null;
        "maxAge" = mkOverride 1002 null;
        "name" = mkOverride 1002 null;
        "path" = mkOverride 1002 null;
        "sameSite" = mkOverride 1002 null;
        "secure" = mkOverride 1002 null;
      };

    };
    "traefik.io.v1alpha1.IngressRouteSpecTls" = {

      options = {
        "certResolver" = mkOption {
          description = "CertResolver defines the name of the certificate resolver to use.\nCert resolvers have to be configured in the static configuration.\nMore info: https://doc.traefik.io/traefik/v3.5/https/acme/#certificate-resolvers";
          type = (types.nullOr types.str);
        };
        "domains" = mkOption {
          description = "Domains defines the list of domains that will be used to issue certificates.\nMore info: https://doc.traefik.io/traefik/v3.5/routing/routers/#domains";
          type = (types.nullOr (types.listOf (submoduleOf "traefik.io.v1alpha1.IngressRouteSpecTlsDomains")));
        };
        "options" = mkOption {
          description = "Options defines the reference to a TLSOption, that specifies the parameters of the TLS connection.\nIf not defined, the `default` TLSOption is used.\nMore info: https://doc.traefik.io/traefik/v3.5/https/tls/#tls-options";
          type = (types.nullOr (submoduleOf "traefik.io.v1alpha1.IngressRouteSpecTlsOptions"));
        };
        "secretName" = mkOption {
          description = "SecretName is the name of the referenced Kubernetes Secret to specify the certificate details.";
          type = (types.nullOr types.str);
        };
        "store" = mkOption {
          description = "Store defines the reference to the TLSStore, that will be used to store certificates.\nPlease note that only `default` TLSStore can be used.";
          type = (types.nullOr (submoduleOf "traefik.io.v1alpha1.IngressRouteSpecTlsStore"));
        };
      };

      config = {
        "certResolver" = mkOverride 1002 null;
        "domains" = mkOverride 1002 null;
        "options" = mkOverride 1002 null;
        "secretName" = mkOverride 1002 null;
        "store" = mkOverride 1002 null;
      };

    };
    "traefik.io.v1alpha1.IngressRouteSpecTlsDomains" = {

      options = {
        "main" = mkOption {
          description = "Main defines the main domain name.";
          type = (types.nullOr types.str);
        };
        "sans" = mkOption {
          description = "SANs defines the subject alternative domain names.";
          type = (types.nullOr (types.listOf types.str));
        };
      };

      config = {
        "main" = mkOverride 1002 null;
        "sans" = mkOverride 1002 null;
      };

    };
    "traefik.io.v1alpha1.IngressRouteSpecTlsOptions" = {

      options = {
        "name" = mkOption {
          description = "Name defines the name of the referenced TLSOption.\nMore info: https://doc.traefik.io/traefik/v3.5/routing/providers/kubernetes-crd/#kind-tlsoption";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "Namespace defines the namespace of the referenced TLSOption.\nMore info: https://doc.traefik.io/traefik/v3.5/routing/providers/kubernetes-crd/#kind-tlsoption";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "namespace" = mkOverride 1002 null;
      };

    };
    "traefik.io.v1alpha1.IngressRouteSpecTlsStore" = {

      options = {
        "name" = mkOption {
          description = "Name defines the name of the referenced TLSStore.\nMore info: https://doc.traefik.io/traefik/v3.5/routing/providers/kubernetes-crd/#kind-tlsstore";
          type = types.str;
        };
        "namespace" = mkOption {
          description = "Namespace defines the namespace of the referenced TLSStore.\nMore info: https://doc.traefik.io/traefik/v3.5/routing/providers/kubernetes-crd/#kind-tlsstore";
          type = (types.nullOr types.str);
        };
      };

      config = {
        "namespace" = mkOverride 1002 null;
      };

    };

  };
in
{
  # all resource versions
  options = {
    resources = {
      "traefik.io"."v1alpha1"."IngressRoute" = mkOption {
        description = "IngressRoute is the CRD implementation of a Traefik HTTP Router.";
        type = (
          types.attrsOf (
            submoduleForDefinition "traefik.io.v1alpha1.IngressRoute" "ingressroutes" "IngressRoute"
              "traefik.io"
              "v1alpha1"
          )
        );
        default = { };
      };

    }
    // {
      "ingressRoutes" = mkOption {
        description = "IngressRoute is the CRD implementation of a Traefik HTTP Router.";
        type = (
          types.attrsOf (
            submoduleForDefinition "traefik.io.v1alpha1.IngressRoute" "ingressroutes" "IngressRoute"
              "traefik.io"
              "v1alpha1"
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
        name = "ingressroutes";
        group = "traefik.io";
        version = "v1alpha1";
        kind = "IngressRoute";
        attrName = "ingressRoutes";
      }
    ];

    resources = {
      "traefik.io"."v1alpha1"."IngressRoute" = mkAliasDefinitions options.resources."ingressRoutes";

    };

    # make all namespaced resources default to the
    # application's namespace
    defaults = [
      {
        group = "traefik.io";
        version = "v1alpha1";
        kind = "IngressRoute";
        default.metadata.namespace = lib.mkDefault config.namespace;
      }
    ];
  };
}
