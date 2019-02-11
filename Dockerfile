FROM alpine:edge

LABEL maintainer="frederic.t.chan@gmail.com"

RUN apk update \
    && apk add --no-cache bash aria2 nginx curl fuse\
    && wget https://github.com/mayswind/AriaNg-DailyBuild/archive/master.zip \
    && unzip master.zip \
    && rm -rf master.zip \
    && mv AriaNg-DailyBuild-master ariang \
    && mkdir -p /data/Download \
    && cd /etc/nginx/conf.d \
    && mkdir -p /run/nginx

RUN curl -O https://downloads.rclone.org/rclone-current-linux-amd64.zip \
    && unzip rclone-current-linux-amd64.zip \
    && cd rclone-*-linux-amd64 \
    && cp rclone /usr/bin/ \
    && chown root:root /usr/bin/rclone \
    && chmod 755 /usr/bin/rclone

RUN mkdir -p /data/GoogleDrive

ADD files/aria2.conf /root/.aria2/aria2.conf
ADD files/ariang-nginx.conf /etc/nginx/conf.d/default.conf
ADD files/start.sh /start.sh
ADD files/rclone_upload.sh /rclone_upload.sh

RUN chmod +x /start.sh \
    && chmod +x /rclone_upload.sh

EXPOSE 80

CMD ["/start.sh"]