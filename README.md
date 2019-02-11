
## Build
```bash
docker build -t aria2-gdrive .  
```

## Get Google Drive Key
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

## Run
```bash
docker run -d \
-p 80:80 -p 6800:6800 \
--name aria2 \
-v $(pwd)/files/rclone:/root/.config/rclone \
--cap-add SYS_ADMIN --device /dev/fuse \
aria2-gdrive:latest
```

