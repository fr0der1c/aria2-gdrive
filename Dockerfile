FROM alpine:edge

LABEL maintainer="frederic.t.chan@gmail.com"

RUN apk update \
    && apk add --no-cache bash aria2 nginx curl fuse python3\
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
    && chmod 755 /usr/bin/rclone \
    && mkdir -p /data/GoogleDrive

ADD files/aria2.conf /root/.aria2/aria2.conf
ADD files/ariang-nginx.conf /etc/nginx/conf.d/default.conf
ADD files/start.sh /start.sh
ADD files/rclone_upload.sh /rclone_upload.sh
ADD files/update_trackers.sh /update_trackers.sh
ADD files/file_vacuum.py /file_vacuum.py

RUN chmod +x /start.sh \
    && chmod +x /rclone_upload.sh \
    && chmod +x /update_trackers.sh \
    && touch /root/.aria2/aria2.session

ENV ARIA2_RPC_SECRET=some_secret
ENV ARIA2_RPC_TLS=false

EXPOSE 80
EXPOSE 6800

CMD ["/start.sh"]