FROM haproxy:1.8-alpine
EXPOSE 80/tcp
EXPOSE 1024/tcp
EXPOSE 9000/tcp

#Standard
COPY haproxy.cfg /usr/local/etc/haproxy/haproxy.cfg
COPY run.sh /run.sh
RUN chmod 0744 /run.sh

WORKDIR /
CMD ["/run.sh"]
