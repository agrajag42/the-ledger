FROM nginx:alpine

RUN rm /etc/nginx/conf.d/default.conf

COPY nginx.conf /etc/nginx/conf.d/default.conf
COPY index.html /usr/share/nginx/html/index.html

ENV PORT=8080
EXPOSE 8080

CMD sh -c "sed -i \"s/LISTEN_PORT/$PORT/g\" /etc/nginx/conf.d/default.conf && nginx -g 'daemon off;'"
