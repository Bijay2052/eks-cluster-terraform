FROM nginx:1.21.6-alpine

COPY ./index.html /usr/share/nginx/html/index.html
COPY ./nginx.conf /etc/nginx/conf.d/default.conf

RUN chown -R nginx /var/cache/nginx \
    && chmod -R g+w /var/cache/nginx \
    && chown -R nginx /etc/nginx \
    && chmod -R g+w /etc/nginx \
    && chown -R nginx /usr/share/nginx \
    && chmod -R g+w /usr/share/nginx \
    && touch /run/nginx.pid \
    && chown -R nginx /run/nginx.pid

USER nginx

EXPOSE 8080