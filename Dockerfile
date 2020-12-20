FROM python:3.9.1-alpine
COPY requirements.txt .
RUN apk add --update-cache \
    openssh-client \
    && pip install --no-cache-dir --requirement requirements.txt && rm requirements.txt \
    && rm -rf /var/cache/apk/*
COPY change_ip.sh route53.py entrypoint.sh ./
RUN chmod +x change_ip.sh entrypoint.sh
RUN mkdir /root/.ssh && chmod 755 /root/.ssh
VOLUME ["/root/.ssh"]
RUN echo "0.0.0.0" > /var/lastip
RUN echo '* * * * * echo "0.0.0.0" > /var/lastip ' >> /etc/crontabs/root
ENTRYPOINT ["/entrypoint.sh"]
