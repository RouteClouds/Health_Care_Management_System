Error at Build and Push Stage
#10 [builder 4/7] RUN npm config set registry https://registry.npmjs.org/ &&     npm config set fetch-timeout 300000 &&     npm config set fetch-retry-mintimeout 20000 &&     npm config set fetch-retry-maxtimeout 120000 &&     npm config set fetch-retries 5
#10 ...
#11 [production 2/5] RUN apk add --no-cache curl
#11 0.061 fetch https://dl-cdn.alpinelinux.org/alpine/v3.22/main/x86_64/APKINDEX.tar.gz
#11 0.220 fetch https://dl-cdn.alpinelinux.org/alpine/v3.22/community/x86_64/APKINDEX.tar.gz
#11 0.577 OK: 49 MiB in 70 packages
#11 DONE 0.7s
#12 [production 3/5] COPY nginx/nginx.conf /etc/nginx/nginx.conf
#12 DONE 0.0s
#10 [builder 4/7] RUN npm config set registry https://registry.npmjs.org/ &&     npm config set fetch-timeout 300000 &&     npm config set fetch-retry-mintimeout 20000 &&     npm config set fetch-retry-maxtimeout 120000 &&     npm config set fetch-retries 5
#10 DONE 1.2s
#13 [builder 5/7] RUN for attempt in 1 2 3; do       echo "npm install attempt $attempt/3..." &&       npm install && break ||       (echo "npm install failed on attempt $attempt" &&        if [ $attempt -eq 3 ]; then exit 1; fi &&        sleep 30);     done
#13 0.048 npm install attempt 1/3...
#13 144.3 npm warn deprecated inflight@1.0.6: This module is not supported, and leaks memory. Do not use it. Check out lru-cache if you want a good and tested way to coalesce async requests by a key value, which is much more comprehensive and powerful.
#13 145.0 npm warn deprecated glob@7.2.3: Glob versions prior to v9 are no longer supported
#13 146.9 npm error code E403
#13 146.9 npm error 403 403 Forbidden - GET https://registry.npmjs.org/yup
#13 146.9 npm error 403 In most cases, you or one of your dependencies are requesting
#13 146.9 npm error 403 a package version that is forbidden by your security policy, or
#13 146.9 npm error 403 on a server you do not have access to.
#13 146.9 npm error A complete log of this run can be found in: /root/.npm/_logs/2025-08-25T13_50_21_406Z-debug-0.log
#13 147.0 npm install failed on attempt 1
#13 177.0 npm install attempt 2/3...
#13 179.0 npm warn deprecated inflight@1.0.6: This module is not supported, and leaks memory. Do not use it. Check out lru-cache if you want a good and tested way to coalesce async requests by a key value, which is much more comprehensive and powerful.
#13 179.3 npm warn deprecated glob@7.2.3: Glob versions prior to v9 are no longer supported
#13 181.8 npm error code E403
#13 181.8 npm error 403 403 Forbidden - GET https://registry.npmjs.org/yup
#13 181.8 npm error 403 In most cases, you or one of your dependencies are requesting
#13 181.8 npm error 403 a package version that is forbidden by your security policy, or
#13 181.8 npm error 403 on a server you do not have access to.
#13 181.8 npm error A complete log of this run can be found in: /root/.npm/_logs/2025-08-25T13_53_18_333Z-debug-0.log
#13 181.9 npm install failed on attempt 2
#13 58.03 npm install attempt 2/3...
#13 59.90 npm warn deprecated inflight@1.0.6: This module is not supported, and leaks memory. Do not use it. Check out lru-cache if you want a good and tested way to coalesce async requests by a key value, which is much more comprehensive and powerful.
#13 60.18 npm warn deprecated glob@7.2.3: Glob versions prior to v9 are no longer supported
#13 64.37 
#13 64.37 added 458 packages, and audited 459 packages in 6s
#13 64.37 
#13 64.37 141 packages are looking for funding
#13 64.37   run `npm fund` for details
#13 64.39 
#13 64.39 8 vulnerabilities (2 low, 6 moderate)
#13 64.39 
#13 64.39 To address issues that do not require attention, run:
#13 64.39   npm audit fix
#13 64.39 
#13 64.39 To address all issues (including breaking changes), run:
#13 64.39   npm audit fix --force
#13 64.39 
#13 64.39 Run `npm audit` for details.
#13 DONE 64.8s
#14 [builder 6/7] COPY frontend/ .
#14 DONE 0.0s
#15 [builder 7/7] RUN npm run build
#15 0.212 
#15 0.212 > routeclouds-health-stage3@1.0.0 build
#15 0.212 > vite build
#15 0.212 
#15 0.425 vite v5.4.19 building for production...
#15 0.763 transforming...
#15 4.235 ✓ 1615 modules transformed.
#15 4.482 rendering chunks...
#15 4.490 computing gzip size...
#15 4.502 dist/index.html                   0.46 kB │ gzip:   0.30 kB
#15 4.503 dist/assets/index-CqxUxE59.css   23.13 kB │ gzip:   4.45 kB
#15 4.503 dist/assets/index-CZh41kS7.js   350.72 kB │ gzip: 112.22 kB
#15 4.503 ✓ built in 4.05s
#15 DONE 4.6s
#16 [production 4/5] COPY --from=builder /app/dist /usr/share/nginx/html
#16 DONE 0.0s
#17 [production 5/5] RUN chown -R nginx:nginx /usr/share/nginx/html
#17 DONE 0.1s
#18 exporting to image
#18 exporting layers
#18 exporting layers 0.8s done
#18 writing image sha256:dad6899f107668767a285b4667c4e7176e571563665f6cb2c755a806af2247a4 done
#18 naming to 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:b751bec97e9ddffe1401578c08344b1853be1278 done
#18 naming to 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3:latest done
#18 DONE 0.8s
✅ Frontend build successful on attempt 2
🏗️ Building backend image with network resilience...
Backend build attempt 1/3...
#0 building with "default" instance using docker driver
#1 [internal] load build definition from Dockerfile.backend
#1 transferring dockerfile: 2.28kB done
#1 DONE 0.0s
#2 [internal] load metadata for docker.io/library/node:18-alpine
#2 DONE 0.3s
#3 [internal] load .dockerignore
#3 transferring context: 2B done
#3 DONE 0.0s
#4 [ 1/16] FROM docker.io/library/node:18-alpine@sha256:8d6421d663b4c28fd3ebc498332f249011d118945588d0a35cb9bc4b8ca09d9e
#4 CACHED
#5 [internal] load build context
#5 transferring context: 291.10kB 0.0s done
#5 DONE 0.0s
#6 [ 2/16] RUN apk add --no-cache     curl     postgresql-client     openssl     openssl-dev     && rm -rf /var/cache/apk/*
#6 0.062 fetch https://dl-cdn.alpinelinux.org/alpine/v3.21/main/x86_64/APKINDEX.tar.gz
#6 0.199 fetch https://dl-cdn.alpinelinux.org/alpine/v3.21/community/x86_64/APKINDEX.tar.gz
#6 0.481 (1/21) Upgrading libcrypto3 (3.3.3-r0 -> 3.3.4-r0)
#6 0.526 (2/21) Upgrading libssl3 (3.3.3-r0 -> 3.3.4-r0)
#6 0.545 (3/21) Installing brotli-libs (1.1.0-r2)
#6 0.571 (4/21) Installing c-ares (1.34.5-r0)
#6 0.586 (5/21) Installing libunistring (1.2-r0)
#6 0.611 (6/21) Installing libidn2 (2.3.7-r0)
#6 0.625 (7/21) Installing nghttp2-libs (1.64.0-r0)
#6 0.639 (8/21) Installing libpsl (0.21.5-r3)
#6 0.652 (9/21) Installing zstd-libs (1.5.6-r2)
#6 0.671 (10/21) Installing libcurl (8.12.1-r1)
#6 0.688 (11/21) Installing curl (8.12.1-r1)
#6 0.703 (12/21) Installing openssl (3.3.4-r0)
#6 0.722 (13/21) Installing pkgconf (2.3.0-r0)
#6 0.736 (14/21) Installing openssl-dev (3.3.4-r0)
#6 0.771 (15/21) Installing postgresql-common (1.2-r1)
#6 0.784 Executing postgresql-common-1.2-r1.pre-install
#6 0.794 (16/21) Installing lz4-libs (1.10.0-r0)
#6 0.808 (17/21) Installing libpq (17.6-r0)
#6 0.824 (18/21) Installing ncurses-terminfo-base (6.5_p20241006-r3)
#6 0.844 (19/21) Installing libncursesw (6.5_p20241006-r3)
#6 0.859 (20/21) Installing readline (8.2.13-r0)
#6 0.873 (21/21) Installing postgresql17-client (17.6-r0)
#6 0.909 Executing busybox-1.37.0-r12.trigger
#6 0.915 Executing postgresql-common-1.2-r1.trigger
#6 0.918 * Setting postgresql17 as the default version
#6 0.983 WARNING: opening from cache https://dl-cdn.alpinelinux.org/alpine/v3.21/main: No such file or directory
#6 0.983 WARNING: opening from cache https://dl-cdn.alpinelinux.org/alpine/v3.21/community: No such file or directory
#6 0.987 OK: 21 MiB in 36 packages
#6 DONE 1.1s
#7 [ 3/16] WORKDIR /app
#7 DONE 0.0s
#8 [ 4/16] RUN addgroup -g 1001 -S nodejs &&     adduser -S -D -H -u 1001 -h /app -s /sbin/nologin -G nodejs -g nodejs nodejs
#8 DONE 0.1s
#9 [ 5/16] COPY backend/package*.json ./
#9 DONE 0.0s
#10 [ 6/16] RUN npm config set registry https://registry.npmjs.org/ &&     npm config set fetch-timeout 300000 &&     npm config set fetch-retry-mintimeout 20000 &&     npm config set fetch-retry-maxtimeout 120000 &&     npm config set fetch-retries 5
#10 DONE 1.1s
#11 [ 7/16] RUN for attempt in 1 2 3; do       echo "npm install attempt $attempt/3..." &&       npm install && npm cache clean --force && break ||       (echo "npm install failed on attempt $attempt" &&        if [ $attempt -eq 3 ]; then exit 1; fi &&        sleep 30);     done
#11 0.049 npm install attempt 1/3...
#11 2.817 npm warn deprecated supertest@6.3.4: Please upgrade to supertest v7.1.3+, see release notes at https://github.com/forwardemail/supertest/releases/tag/v7.1.3 - maintenance is supported by Forward Email @ https://forwardemail.net
#11 2.989 npm warn deprecated rimraf@3.0.2: Rimraf versions prior to v4 are no longer supported
#11 3.294 npm warn deprecated superagent@8.1.2: Please upgrade to superagent v10.2.2+, see release notes at https://github.com/forwardemail/superagent/releases/tag/v10.2.2 - maintenance is supported by Forward Email @ https://forwardemail.net
#11 3.482 npm warn deprecated inflight@1.0.6: This module is not supported, and leaks memory. Do not use it. Check out lru-cache if you want a good and tested way to coalesce async requests by a key value, which is much more comprehensive and powerful.
#11 3.553 npm warn deprecated glob@7.2.3: Glob versions prior to v9 are no longer supported
#11 4.197 npm warn deprecated @humanwhocodes/object-schema@2.0.3: Use @eslint/object-schema instead
#11 4.243 npm warn deprecated @humanwhocodes/config-array@0.13.0: Use @eslint/config-array instead
#11 6.218 npm warn deprecated eslint@8.57.1: This version is no longer supported. Please see https://eslint.org/version-support for other options.
#11 8.789 
#11 8.789 added 567 packages, and audited 568 packages in 9s
#11 8.789 
#11 8.789 84 packages are looking for funding
#11 8.790   run `npm fund` for details
#11 8.791 
#11 8.791 found 0 vulnerabilities
#11 8.945 npm warn using --force Recommended protections disabled.
#11 DONE 9.5s
#12 [ 8/16] COPY backend/prisma ./prisma/
#12 DONE 0.0s
#13 [ 9/16] RUN npx prisma generate
#13 1.133 Prisma schema loaded from prisma/schema.prisma
#13 1.538 
#13 1.538 ✔ Generated Prisma Client (v5.22.0) to ./node_modules/@prisma/client in 89ms
#13 1.538 
#13 1.538 Start by importing your Prisma Client (See: https://pris.ly/d/importing-client)
#13 1.538 
#13 1.538 Tip: Want to turn off tips and other hints? https://pris.ly/tip-4-nohints
#13 1.538 
#13 DONE 1.8s
#14 [10/16] COPY backend/src ./src/
#14 DONE 0.0s
#15 [11/16] COPY backend/tsconfig.json ./
#15 DONE 0.0s
#16 [12/16] COPY backend/scripts ./scripts/
#16 DONE 0.0s
#17 [13/16] RUN ls -la scripts/ && chmod +x scripts/*.sh
#17 0.049 total 36
#17 0.049 drwxr-xr-x    2 root     root          4096 Aug 25 13:49 .
#17 0.049 drwxr-xr-x    1 root     root          4096 Aug 25 13:55 ..
#17 0.049 -rw-r--r--    1 root     root          6304 Aug 25 13:49 docker-entrypoint.sh
#17 0.049 -rwxr-xr-x    1 root     root          5105 Aug 25 13:49 init-db.sh
#17 0.049 -rw-r--r--    1 root     root          6116 Aug 25 13:49 seed-database.js
#17 0.049 -rwxr-xr-x    1 root     root           562 Aug 25 13:49 start.sh
#17 DONE 0.1s
#18 [14/16] RUN npm run build
#18 0.215 
#18 0.215 > healthcare-backend-stage3@1.0.0 build
#18 0.215 > tsc
#18 0.215 
#18 DONE 2.4s
#19 [15/16] RUN npm prune --production &&     rm -rf src tsconfig.json &&     chmod +x scripts/*.sh &&     chown -R nodejs:nodejs scripts/ &&     ls -la scripts/
#19 0.176 npm warn config production Use `--omit=dev` instead.
#19 2.416 
#19 2.416 up to date, audited 109 packages in 2s
#19 2.416 
#19 2.416 15 packages are looking for funding
#19 2.416   run `npm fund` for details
#19 2.417 
#19 2.417 found 0 vulnerabilities
#19 2.438 total 44
#19 2.438 drwxr-xr-x    1 nodejs   nodejs        4096 Aug 25 13:49 .
#19 2.438 drwxr-xr-x    1 root     root          4096 Aug 25 13:55 ..
#19 2.438 -rwxr-xr-x    1 nodejs   nodejs        6304 Aug 25 13:49 docker-entrypoint.sh
#19 2.438 -rwxr-xr-x    1 nodejs   nodejs        5105 Aug 25 13:49 init-db.sh
#19 2.438 -rw-r--r--    1 nodejs   nodejs        6116 Aug 25 13:49 seed-database.js
#19 2.438 -rwxr-xr-x    1 nodejs   nodejs         562 Aug 25 13:49 start.sh
#19 DONE 2.4s
#20 [16/16] RUN chown -R nodejs:nodejs /app
#20 DONE 1.0s
#21 exporting to image
#21 exporting layers
#21 exporting layers 3.2s done
#21 writing image sha256:dfe61d178334f5e1373aa12d30102415e60803a3a9e9569aa222da3a18718ff4 done
#21 naming to 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:b751bec97e9ddffe1401578c08344b1853be1278 done
#21 naming to 867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3:latest done
#21 DONE 3.2s
✅ Backend build successful on attempt 1
📋 Built images:
867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3    b751bec97e9ddffe1401578c08344b1853be1278   dfe61d178334   3 seconds ago    466MB
867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-backend-stage3    latest                                     dfe61d178334   3 seconds ago    466MB
867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3   b751bec97e9ddffe1401578c08344b1853be1278   dad6899f1076   24 seconds ago   53.4MB
867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3   latest                                     dad6899f1076   24 seconds ago   53.4MB
📤 Pushing frontend images...
The push refers to repository [867344452513.dkr.ecr.us-east-1.amazonaws.com/healthcare-frontend-stage3]