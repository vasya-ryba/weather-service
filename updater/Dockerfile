FROM alpine:3.14
RUN echo "* * * * * echo '<plaintext>' > /data/index.html; wget wttr.in/Tbilisi?0Tm -O- >> /data/index.html" > /etc/crontab && crontab /etc/crontab
CMD ["/usr/sbin/crond", "-f"]