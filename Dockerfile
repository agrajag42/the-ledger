FROM nginx:alpine

# Remove default config
RUN rm /etc/nginx/conf.d/default.conf

# Add custom nginx config serving at /friends/ledger
COPY nginx.conf /etc/nginx/conf.d/default.conf

# Copy static files
COPY index.html /usr/share/nginx/html/friends/ledger/index.html

# Cloud Run uses PORT env var
ENV PORT=8080
EXPOSE 8080

# Substitute PORT into nginx config at runtime
CMD sh -c "sed -i \"s/LISTEN_PORT/$PORT/g\" /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
