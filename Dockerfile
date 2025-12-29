FROM node:18-alpine as builder

RUN node -v

RUN mkdir -p /home/node/app && \
	chown -R node:node /home/node/app 

USER node

WORKDIR /home/node/app

COPY --chown=node:node . .

RUN npm install

RUN npm run build

FROM nginx:alpine

RUN apk add --no-cache socat

COPY --from=builder /home/node/app/dist/ /usr/share/nginx/html/

WORKDIR /app

COPY response.txt .

EXPOSE 80

EXPOSE 987/udp

CMD sh -c "socat -T5 UDP-RECVFROM:987,fork,reuseaddr SYSTEM:'cat /app/response.txt' 2>/dev/null & nginx -g 'daemon off;'"
