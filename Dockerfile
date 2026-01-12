FROM caddy:builder-alpine AS builder

# Install Go toolchain helpers if needed (usually present in builder)
# The cloudflare plugin version will be taken from go.mod at build time
# We'll pass it explicitly via build arg or resolve it with `go list` from a copied go.mod

# Copy go.mod/go.sum in a temp workspace to resolve the plugin version
WORKDIR /work
COPY go.mod ./

# Resolve the exact version of the plugin from go.mod.
# If go.sum is present, you can run `go mod download` to prefetch modules.
# We'll output the version to an env file to reuse later.
RUN go mod download || true \
 && echo "CLOUDFLARE_PLUGIN_VERSION=$(go list -m -f '{{.Version}}' github.com/caddy-dns/cloudflare)" | tee /tmp/plugin.env

COPY . .

# Build caddy with the resolved plugin version
RUN . /tmp/plugin.env \
 && xcaddy build \
    --with github.com/caddy-dns/cloudflare@${CLOUDFLARE_PLUGIN_VERSION} \
    --with github.com/sablierapp/sablier-caddy-plugin@v1.0.1 # x-release-please-version

FROM caddy:alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy
