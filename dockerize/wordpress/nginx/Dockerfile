FROM nginx:1.27.3

# remove symlinks from nginx image (the nginx docker image actually stores the
# log file in /etc/nginx/logs for some reason)
# RUN rm /var/log/nginx/access.log
# RUN rm /var/log/nginx/error.log

# install logrotate and cron
RUN apt-get update && apt-get install -y logrotate cron

# copy nginx config
COPY nginx.conf /etc/nginx/nginx.conf

# copy nginx templates
COPY templates/* /etc/nginx/templates

# copy nginx logrotate config
COPY logrotate.nginx /etc/logrotate.d/nginx

# we need to make this directory for some reason
RUN mkdir /etc/nginx/logs

# start nginx and cron as a service
CMD [ "sh", "-c", "service cron start && nginx -g 'daemon off;'" ]
