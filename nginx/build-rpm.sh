#!/bin/bash
yum groupinstall "Development Tools"
yum install -y git libtool automake autoconf zlib-devel pcre-devel openssl-devel libxslt-devel libxml2-devel libXpm-devel geoip-devel google-perftools-devel perl-devel gd-devel

cd /usr/local/src
wget http://nginx.org/download/nginx-1.13.6.tar.gz
tar -xzvf nginx-1.13.6.tar.gz
mv nginx-1.13.6 nginx

git clone https://github.com/FRiCKLE/ngx_cache_purge.git
git clone https://github.com/openresty/memc-nginx-module.git
git clone https://github.com/simpl/ngx_devel_kit.git
git clone https://github.com/openresty/headers-more-nginx-module.git
git clone https://github.com/openresty/echo-nginx-module.git
git clone https://github.com/yaoweibin/ngx_http_substitutions_filter_module.git
git clone https://github.com/openresty/redis2-nginx-module.git
git clone https://github.com/openresty/srcache-nginx-module.git
git clone https://github.com/openresty/set-misc-nginx-module.git
git clone https://github.com/FRiCKLE/ngx_coolkit.git
git clone https://github.com/FRiCKLE/ngx_slowfs_cache.git
wget https://people.freebsd.org/~osa/ngx_http_redis-0.3.8.tar.gz
tar -zxf ngx_http_redis-0.3.8.tar.gz
mv ngx_http_redis-0.3.8 ngx_http_redis

git clone https://github.com/google/ngx_brotli.git
cd ngx_brotli
git submodule update --init --recursive
cd /usr/local/src

git clone https://github.com/openssl/openssl.git
cd openssl
git checkout tls1.3-draft-18

cd /usr/local/src/nginx/
wget https://raw.githubusercontent.com/cujanovic/nginx-dynamic-tls-records-patch/master/nginx__dynamic_tls_records_1.11.5%2B.patch
patch -p1 < nginx__dynamic_tls_records_1.11.5*.patch

./configure --prefix=/etc/nginx --sbin-path=/usr/sbin/nginx --conf-path=/etc/nginx/nginx.conf --error-log-path=/var/log/nginx/error.log --http-log-path=/var/log/nginx/access.log --lock-path=/var/lock/nginx.lock --pid-path=/var/run/nginx.pid --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --user=nginx --group=nginx --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_addition_module --with-http_geoip_module --with-http_gzip_static_module --with-http_image_filter_module --with-http_v2_module --with-http_sub_module --with-http_xslt_module --with-threads --add-module=/usr/local/src/ngx_cache_purge --add-module=/usr/local/src/memc-nginx-module --add-module=/usr/local/src/ngx_devel_kit --add-module=/usr/local/src/headers-more-nginx-module --add-module=/usr/local/src/echo-nginx-module --add-module=/usr/local/src/ngx_http_substitutions_filter_module --add-module=/usr/local/src/redis2-nginx-module --add-module=/usr/local/src/srcache-nginx-module --add-module=/usr/local/src/set-misc-nginx-module --add-module=/usr/local/src/ngx_http_redis --add-module=/usr/local/src/ngx_brotli --with-openssl=/usr/local/src/openssl --with-openssl-opt=enable-tls1_3

make -j $(nproc)
make install

systemctl unmask sw-nginx
systemctl enable nginx
systemctl start nginx
wget -O /etc/nginx/nginx.conf https://raw.githubusercontent.com/VirtuBox/plesk-nginx/master/etc/nginx/nginx.conf
wget -O /etc/nginx/conf.d/ssl.conf https://raw.githubusercontent.com/VirtuBox/plesk-nginx/master/etc/nginx/conf.d/ssl.conf
nginx -t && service nginx reload
systemctl restart nginx
