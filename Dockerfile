FROM nood/nginx-lua
COPY ./conf/nginx.conf /nginx/conf/nginx.conf
COPY ./content/index.html /nginx/html/index.html