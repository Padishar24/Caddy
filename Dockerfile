FROM caddy:builder-alpine AS builder

COPY . .

# Add Sablier source code
ADD https://github.com/sablierapp/sablier.git /sablier

# Run xcaddy build with both plugins
RUN xcaddy build \
    --with github.com/lucaslorentz/caddy-docker-proxy/v2 \
    --with github.com/caddy-dns/cloudflare \
    --with github.com/sablierapp/sablier/plugins/caddy=/sablier/plugins/caddy

# RUN xcaddy build \
#     --with github.com/sablierapp/sablier/plugins/caddy=. \
#     --with github.com/caddy-dns/cloudflare

FROM caddy:alpine

COPY --from=builder /usr/bin/caddy /usr/bin/caddy

CMD ["caddy", "docker-proxy"]