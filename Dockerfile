FROM debian:buster-slim
MAINTAINER Odoo S.A. <info@odoo.com>

SHELL ["/bin/bash", "-xo", "pipefail", "-c"]

# Generate locale C.UTF-8 for postgres and general locale data
ENV LANG C.UTF-8

# Install some deps, lessc and less-plugin-clean-css, and wkhtmltopdf
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
        ca-certificates \
        curl \
        dirmngr \
        fonts-noto-cjk \
        gnupg \
        libssl-dev \
        node-less \
        npm \
        python3-num2words \
        python3-pdfminer \
        python3-pip \
        python3-phonenumbers \
        python3-pyldap \
        python3-qrcode \
        python3-renderpm \
        python3-setuptools \
        python3-slugify \
        python3-vobject \
        python3-watchdog \
        python3-xlrd \
#        python3-xlwt \
        xz-utils \
        libjpeg62-turbo-dev

#RUN curl -o wkhtmltox.deb -sSL https://github.com/wkhtmltopdf/wkhtmltopdf/releases/download/0.12.5/wkhtmltox_0.12.5-1.buster_amd64.deb \
#    && echo 'ea8277df4297afc507c61122f3c349af142f31e5 wkhtmltox.deb' | sha1sum -c - \
#    && apt-get install -y --no-install-recommends ./wkhtmltox.deb \
#    && rm -rf /var/lib/apt/lists/* wkhtmltox.deb

#RUN dpkg -i ./lib/wkhtmltox.deb
#RUN rm -rf /var/lib/apt/lists/* wkhtmltox.deb
RUN rm -rf /var/lib/apt/lists/*

###########################Tambahan - jeki start
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    apt-utils


RUN pip3 install xlwt num2words wheel

RUN set -x; \
        apt-get update \
        && apt-get install -y --no-install-recommends \
        python3-babel \
        python3-decorator \
        python3-docutils \
        python3-feedparser \
        python3-gevent \
        python3-html2text \
        python3-idna \
        python3-jinja2 \
        python3-libsass \
        python3-lxml \
        python3-mako \
        python3-mock \
        python3-ofxparse \
        python3-passlib \
        python3-polib \
        python3-psutil \
        python3-psycopg2 \
        python3-pydot \
        python3-pypdf2 \
        python3-reportlab \
        python3-requests \
        python3-serial \
        python3-stdnum \
        python3-tz \
        python3-usb \
        python3-werkzeug \
        python3-xlsxwriter \
        python3-zeep \
        python3-usb \
        fonts-inconsolata \
        fonts-font-awesome \
        fonts-roboto-unhinted \
        python3-chardet \
        python3-freezegun \
        python3-xlrd \
        python3-ipdb \
        procps \
        net-tools \
        nano

RUN pip3 install pillow
RUN pip3 install ofxparse
RUN pip3 install suds-jurko-requests
#RUN pip3 install pytrustnfe3
RUN pip3 install python3-cnab
RUN pip3 install python3-boleto
#RUN pip3 install xmlsec
RUN pip3 install lxml
RUN pip3 install xlwt
RUN pip3 install pycnab240

###########################Tambahan - jeki end


# install latest postgresql-client
RUN echo 'deb http://apt.postgresql.org/pub/repos/apt/ buster-pgdg main' > /etc/apt/sources.list.d/pgdg.list \
    && GNUPGHOME="$(mktemp -d)" \
    && export GNUPGHOME \
    && repokey='B97B0AFCAA1A47F044F244A07FCC7D46ACCC4CF8' \
    && gpg --batch --keyserver keyserver.ubuntu.com --recv-keys "${repokey}" \
    && gpg --batch --armor --export "${repokey}" > /etc/apt/trusted.gpg.d/pgdg.gpg.asc \
    && gpgconf --kill all \
    && rm -rf "$GNUPGHOME" \
    && apt-get update  \
    && apt-get install --no-install-recommends -y postgresql-client \
    && rm -f /etc/apt/sources.list.d/pgdg.list \
    && rm -rf /var/lib/apt/lists/*

# Install rtlcss (on Debian buster)
RUN npm install -g rtlcss

# Install Odoo
ENV ODOO_VERSION 14.0
ARG ODOO_RELEASE=20210618
ARG ODOO_SHA=261431b2bcb6d64751560cbd4dd98a9d98863e0c
RUN curl -o odoo.deb -sSL https://nightly.odoo.com/${ODOO_VERSION}/nightly/deb/odoo_${ODOO_VERSION}.${ODOO_RELEASE}_all.deb \
    && echo "${ODOO_SHA} odoo.deb" | sha1sum -c - \
    && apt-get update \
    && apt-get -y install --no-install-recommends ./odoo.deb \
    && rm -rf /var/lib/apt/lists/* odoo.deb

# Copy entrypoint script and Odoo configuration file
COPY ./entrypoint.sh /
COPY ./data/app/config/odoo.conf /etc/odoo/

# Set permissions and Mount /var/lib/odoo to allow restoring filestore and /mnt/extra-addons for users addons
RUN chown odoo /etc/odoo/odoo.conf \
    && mkdir -p /mnt/extra-addons \
    && chown -R odoo /mnt/extra-addons
VOLUME ["/var/lib/odoo", "/mnt/extra-addons"]

# Expose Odoo services
EXPOSE 8069 8071 8072

# Set the default config file
ENV ODOO_RC /etc/odoo/odoo.conf

COPY wait-for-psql.py /usr/local/bin/wait-for-psql.py

RUN chmod +x /usr/local/bin/wait-for-psql.py

# Set default user when running the container
USER odoo

ENTRYPOINT ["/entrypoint.sh"]
CMD ["odoo"]