# istio_version - Istio version.
# Type: ${string}
# Default: "1.18.2"
#istio_version = "1.18.2"

# istio_namespace - Istio namespace.
# Type: ${string}
# Default: "istio-system"
#istio_namespace = "istio-system"

# istio_base_values - Path to istio-base values file. Start it with / for absolute path or ./ to relative to root module.
# Type: ${string}
# Default: "base-values.yaml"
#istio_base_values = "base-values.yaml"

# istio_base_set - Value block with custom values to be merged with the values yaml.
# Type: ${list(object({'name': '${string}', 'value': '${string}'}))}
# Default: []
#istio_base_set = []

# istio_base_set_list - Value block with list of custom values to be merged with the values yaml.
# Type: ${list(object({'name': '${string}', 'value': '${list(any)}'}))}
# Default: []
#istio_base_set_list = []
