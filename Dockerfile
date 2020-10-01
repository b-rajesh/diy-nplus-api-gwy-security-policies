#For Debian 9
FROM debian:stretch-slim

LABEL maintainer="NGINX Docker Maintainers <docker-maint@nginx.com>"
COPY etc/ssl/nginx/nginx-repo.crt /etc/ssl/nginx/
COPY etc/ssl/nginx/nginx-repo.key /etc/ssl/nginx/
# COPY etc/ssl/certs/api.example.com.crt /etc/ssl/certs/
# COPY etc/ssl/certs/api.example.com.key /etc/ssl/certs/

# Install NGINX Plus
RUN set -x \
  && apt-get update && apt-get upgrade -y \
  && apt-get install --no-install-recommends --no-install-suggests -y apt-transport-https lsb-release ca-certificates wget gnupg2 \
  && wget https://cs.nginx.com/static/keys/nginx_signing.key && apt-key add nginx_signing.key \
  && printf "deb https://plus-pkgs.nginx.com/debian `lsb_release -cs` nginx-plus\n" | tee /etc/apt/sources.list.d/nginx-plus.list \
  && wget -P /etc/apt/apt.conf.d https://cs.nginx.com/static/files/90nginx \
  ## Install NGINX Plus Modules from repo
  && apt-get update && apt-get install -y nginx-plus \
  && apt-get remove --purge --auto-remove -y gnupg2 \
  # See https://www.nginx.com/products/nginx/modules
  # Required for this demo:
  && apt-get install -y nginx-plus-module-njs \
  && apt-get install -y app-protect \
  && apt-get install -y nginx-plus-module-opentracing \
  && apt-get install -y nginx-plus-module-headers-more \
  # Optional, not required:
  #&& apk add nginx-plus-module-modsecurity \
  #&& apk add nginx-plus-module-geoip \
  # Remove default nginx config
  && rm /etc/nginx/conf.d/default.conf \
  # Optional: Create cache folder and set permissions for proxy caching
  #  && mkdir -p /var/cache/nginx \
  #  && chown -R nginx /var/cache/nginx \
  ## Optional: Install Tools
  # jq
  && apt-get install -y  jq \
  && rm -rf /var/lib/apt/lists/* \
  && rm -rf /etc/ssl/nginx

# COPY /etc/nginx (Nginx configuration) directory
COPY etc/nginx /etc/nginx
RUN chown -R nginx:nginx /etc/nginx \
 # Forward request logs to docker log collector
 && ln -sf /dev/stdout /var/log/nginx/access.log \
 && ln -sf /dev/stderr /var/log/nginx/error.log
COPY entrypoint.sh  ./
RUN rm -rf /etc/ssl/nginx
RUN chmod -R 755 /etc/nginx 

# EXPOSE ports, HTTP 80, HTTPS 443 and, Nginx status page 8080
EXPOSE 80 443 8080 9000
STOPSIGNAL SIGTERM
CMD ["sh", "/entrypoint.sh"]