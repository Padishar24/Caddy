ARG CADDY_VERSION=2.10.0
FROM caddy:${CADDY_VERSION}-builder-alpine AS builder

COPY . .

# Add Sablier source code
ADD https://github.com/sablierapp/sablier.git /sablier

# Run xcaddy build with both plugins
RUN xcaddy build \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/sablierapp/sablier/plugins/caddy=/sablier/plugins/caddy

# RUN xcaddy build \
#     --with github.com/sablierapp/sablier/plugins/caddy=. \
#     --with github.com/caddy-dns/cloudflare

FROM caddy:${CADDY_VERSION}-alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy