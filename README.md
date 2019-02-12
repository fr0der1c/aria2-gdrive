# aria2-gdrive
Download files to Google Drive using Aria2. (Technically, download then move to Google Drive using rclone.) Embedded AriaNg, a web UI for Aria2.

TODO:
- Add SSL make it more secure to work on public internet.

## Usage
### Build
```bash
docker build -t aria2-gdrive .
```

### Get Google Drive Key
```bash
docker run --rm -it \
-v $(pwd)/files/rclone:/root/.config/rclone \
aria2-gdrive:latest rclone config
```
Choose the following:
- n
- my-drive
- 12
- (blank)
- (blank)
- 1
- (blank or set your own)
- (blank)
- n
- n
- (copy the link and open in browser and paste back the code)
- n
- y
- q

### Run
```bash
docker run -d \
-p 6801:80 -p 6800:6800 \
-e ARIA2_RPC_SECRET=[your aria2 password here, default is some_secret]\
-v path/to/your.key:/aria2.key \
-v path/to/your.crt:/aria2.crt \
-e RPC_SECURE=[true|false, default is false] \
-v $(pwd)/data:/data \
-v $(pwd)/files/rclone:/root/.config/rclone \
--cap-add SYS_ADMIN --device /dev/fuse \
--name aria2 \
aria2-gdrive:latest
```
If you wish to use SSL/TLS with aria2, use the command above. If you wish to use plain HTTP or you want to use an reverse proxy to add TLS (I personally prefer this way), omit the key, crt and `RPC_SECURE` line:

```bash
docker run -d \
-p 6801:80 -p 6800:6800 -p 6881:6881 -p 6882:6882 \
-e ARIA2_RPC_SECRET=[your aria2 password here, default is some_secret]\
-v $(pwd)/files/rclone:/root/.config/rclone \
-v $(pwd)/data:/data \
--cap-add SYS_ADMIN --device /dev/fuse \
--name aria2 \
aria2-gdrive:latest
```

The `-v $(pwd)/data:/data` is optional. Add it if you want to view the files without entering container.

#### Nginx configuration
If your AriaNg port is 6801 and Aria2 port is 6802, you can use the following configuration.
```
server
{
    listen 80;
    listen 443 ssl http2;
    server_name aria2.example.com;
    index index.html index.htm;
    
    ssl_certificate    /www/server/vhost/cert/fullchain.cer;
    ssl_certificate_key    /www/server/vhost/cert/private.key;
    ssl_protocols TLSv1.1 TLSv1.2;
    ssl_ciphers ECDHE-RSA-AES128-GCM-SHA256:HIGH:!aNULL:!MD5:!RC4:!DHE;
    ssl_prefer_server_ciphers on;
    ssl_session_cache shared:SSL:10m;
    ssl_session_timeout 10m;

    location /jsonrpc {
        proxy_pass http://localhost:6802/jsonrpc;
        proxy_redirect off;
        proxy_set_header        X-Real-IP       $remote_addr;
        proxy_set_header        X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header Host $host;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
    location /
    {
        proxy_pass http://localhost:6801;
    }
}
```

## Known issues
Since we cannot stream the files to Google while downloading, your disk size must be larger than 2x of the file(s) you download. If you managed to break this limitation, welcome to give me a pull request.


## Changelog
### 2.0
- Added a vacuum to delete files of canceled tasks every 10 seconds(beta)
- Adjusted log level
- Added a script that get latest BT trackers and added to aria2 config file when the container starts
- Added BT/DHT port
- TLS support
- Aria2 session support

### 1.0
first version