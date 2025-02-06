FROM nginx:1.27.3
WORKDIR /etc/nginx

# create logs folder and files
RUN mkdir logs
RUN touch logs/access.log

# copy custom nginx config to container fs
COPY nginx.conf ./
COPY conf.d/default.conf ./conf.d
