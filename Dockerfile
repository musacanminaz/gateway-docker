FROM ubuntu:18.04

COPY build-nginx.sh /root/

WORKDIR /root

RUN chmod +x build-nginx.sh && ./build-nginx.sh

# forward request and error logs to docker log collector
RUN ln -sf /dev/stdout /var/log/nginx/access.log \
    && ln -sf /dev/stderr /var/log/nginx/error.log

#defaults
COPY ./config/allow_cors /etc/nginx/allow_cors
COPY ./config/proxy_params /etc/nginx/proxy_params
COPY ./config/nginx.conf /etc/nginx/nginx.conf
COPY ./config/ssl /etc/nginx

#config
COPY ./config/vhosts/ /etc/nginx/vhosts/

#ssl
COPY ./ssl/*.key /etc/ssl/private/
COPY ./ssl/*.pem /etc/ssl/certs/

EXPOSE 80 443

CMD ["nginx", "-g", "daemon off;"]
