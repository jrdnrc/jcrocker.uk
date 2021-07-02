FROM nginx

RUN rm -rf /usr/share/nginx/*

COPY public /usr/share/nginx/html