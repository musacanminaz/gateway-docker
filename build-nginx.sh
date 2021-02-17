#!/usr/bin/env bash
set -e
# http://nginx.org/download/nginx-1.16.0.tar.gz
SRC_ROOT=/usr/src
NSRC_ROOT=/usr/src/nginx
NPS_VERSION=1.13.35.2
NGINX_VERSION=1.16.1
### automated tasks
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
mkdir -p ${NSRC_ROOT}
echo "Repo update"
apt-get update -y
apt-get upgrade -y
echo "Installing base packages & libs"
apt-get install -y openssl libssl-dev libssl-doc htop iotop iftop xtail fail2ban aria2
apt-get install -y sysstat links libpcre3 libpcre3-dev libssl-dev zlibc zlib1g zlib1g-dev
apt-get install -y perl libnet-ssleay-perl openssl libauthen-pam-perl libpam-runtime libio-pty-perl python
apt-get install -y build-essential zlib1g-dev libpcre3 libpcre3-dev unzip git uuid-dev
echo "Start to compile Nginx & modules, ngx_pagespeed, test-cookie, headers-more, cache-purge"
cd ${NSRC_ROOT}
rm -rf *
####
#aria2c https://github.com/apache/incubator-pagespeed-ngx/archive/v${NPS_VERSION}-stable.tar.gz
#tar zxvf incubator-pagespeed-ngx-${NPS_VERSION}-stable.tar.gz
#cd incubator-pagespeed-ngx-${NPS_VERSION}-stable
### https://dl.google.com/dl/page-speed/psol/1.13.35.2-x64.tar.gz
#aria2c https://dl.google.com/dl/page-speed/psol/${NPS_VERSION}-x64.tar.gz
#tar -xzvf ${NPS_VERSION}-x64.tar.gz
cd ${NSRC_ROOT}
aria2c http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar -xvzf nginx-${NGINX_VERSION}.tar.gz
cd nginx-${NGINX_VERSION}/
cd ${NSRC_ROOT}
aria2c https://github.com/openresty/headers-more-nginx-module/archive/v0.33.tar.gz
tar zxvf headers-more-nginx-module-0.33.tar.gz

aria2c https://github.com/FRiCKLE/ngx_cache_purge/archive/2.3.tar.gz
tar zxvf ngx_cache_purge-2.3.tar.gz

#aria2c https://github.com/kyprizel/testcookie-nginx-module/tarball/master
#mv kyprizel-testcookie-nginx-module-*.tar.gz kyprizel-testcookie-nginx.tar.gz
#tar zxvf kyprizel-testcookie-nginx.tar.gz

#cd ${NSRC_ROOT}
#git clone --depth 1 https://github.com/SpiderLabs/ModSecurity-nginx.git
#./configure --with-compat --add-dynamic-module=../ModSecurity-nginx
#./configure --conf-path=/etc/nginx/nginx.conf --sbin-path=/usr/sbin/nginx --pid-path=/var/run/nginx.pid --lock-path=/var/run/nginx.lock --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --with-compat --add-dynamic-module=../ModSecurity-nginx

cd ${NSRC_ROOT}
git clone git://github.com/vozlt/nginx-module-vts.git

cd ${NSRC_ROOT}
#git clone --depth 1 -b v3/master --single-branch https://github.com/SpiderLabs/ModSecurity

#cd ${NSRC_ROOT}/ModSecurity
#git submodule init
#git submodule update
#./build.sh
#./configure
#make -j4
#make install


cd nginx-${NGINX_VERSION}/

#--with-http_addition_module \
## --with-cc-opt='-O2 -g -pipe -Wp,-D_FORTIFY_SOURCE=2 -fexceptions -fstack-protector --param=ssp-buffer-size=4 -march=native -mtune=native -D_GLIBCXX_USE_CXX11_ABI=0' \

#  --with-select_module
#  --with-poll_module
#  --with-threads

# now start to configure
echo "Configuring Nginx"
./configure --conf-path=/etc/nginx/nginx.conf \
--sbin-path=/usr/sbin/nginx \
--pid-path=/var/run/nginx.pid \
--lock-path=/var/run/nginx.lock \
--error-log-path=/var/log/nginx/error.log \
--http-log-path=/var/log/nginx/access.log \
--with-poll_module \
--with-threads \
--with-http_ssl_module \
--with-http_v2_module \
--with-http_slice_module \
--with-http_realip_module \
--with-http_gzip_static_module \
--with-http_stub_status_module \
--with-http_sub_module \
--with-file-aio \
--with-http_addition_module \
--with-ipv6 \
--with-compat \
--add-module=${NSRC_ROOT}/headers-more-nginx-module-0.33 \
--add-module=${NSRC_ROOT}/ngx_cache_purge-2.3 \
--add-module=${NSRC_ROOT}/nginx-module-vts


#--add-dynamic-module=${NSRC_ROOT}/ModSecurity-nginx

# ngx_http_modsecurity_module requires the ModSecurity library
# ngx_http_modsecurity_module requires the ModSecurity library
#https://github.com/kyprizel/testcookie-nginx-module
#--add-module=${NSRC_ROOT}/kyprizel-testcookie-nginx-module \

echo "Compiling Nginx"
make -j4
echo "Installing Nginx"
make install
