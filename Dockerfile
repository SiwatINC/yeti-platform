FROM siwatinc/python3baseimage
RUN apt-get -y install build-essential libxml2-dev libxslt-dev zlib1g-dev python-setuptools python-wheel locales libmagic1 apt-transport-https uwsgi-plugin-python uwsgi && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/* /root/.cache/*
RUN apt-get update && apt-get install -y --no-install-suggests --no-install-recommends gnupg2 && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/* /root/.cache/*
RUN curl -sL https://deb.nodesource.com/setup_8.x |  bash -
RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN apt-get update && apt-get install -y nodejs yarn && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/* /usr/share/doc/* /usr/share/man/* /root/.cache/*
RUN pip install uwsgi
ADD . /opt/yeti
WORKDIR /opt/yeti
RUN pip install -r requirements.txt && \
        yarn install && \
        mv yeti.conf.sample yeti.conf && \
        sed -i '9s/# host = 127.0.0.1/host = mongodb/' yeti.conf && \
        sed -i '22s/# host = 127.0.0.1/host = redis/' yeti.conf
ADD https://raw.githubusercontent.com/vishnubob/wait-for-it/master/wait-for-it.sh /usr/local/bin/
RUN groupadd yeti && \
        useradd -r --home-dir /opt/yeti -g yeti yeti && \
        mv extras/docker/scripts/docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh && \
        chmod 755 /usr/local/bin/wait-for-it.sh /usr/local/bin/docker-entrypoint.sh && \
        chown -R yeti.yeti /opt/yeti
USER yeti
ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["docker-entrypoint.sh", "webserver"]
