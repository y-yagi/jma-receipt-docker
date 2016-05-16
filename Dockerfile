FROM ubuntu:14.04

ENV ORMASTER_PASSWORD=ormaster

RUN apt-get -qq update
RUN set -xe \
  && cd /tmp \
  && apt-get install -y wget syslinux-common \
  && wget -q https://ftp.orca.med.or.jp/pub/ubuntu/archive.key \
  && apt-key add archive.key \
  && wget -q -O /etc/apt/sources.list.d/jma-receipt-trusty48.list https://ftp.orca.med.or.jp/pub/ubuntu/jma-receipt-trusty48.list \
  && apt-get update \
  && apt-get dist-upgrade -y \
  && apt-get install -y jma-receipt \
  && wget https://ftp.orca.med.or.jp/pub/data/receipt/outline/update/claim_update.tar.gz \
  && tar xvzf claim_update.tar.gz \
  && bash claim_update.sh \
  && service postgresql restart \
  && jma-setup \
  && /bin/echo -e "$ORMASTER_PASSWORD\n$ORMASTER_PASSWORD" | sudo -u orca /usr/lib/jma-receipt/bin/passwd_store.sh \
  && rm -rf /tmp/* /var/lib/apt/lists/*

ADD orca.dump.gz /tmp
RUN gzip -d /tmp/orca.dump.gz
RUN service postgresql restart \
  && service jma-receipt stop \
  && sudo -u orca dropdb orca \
  && jma-setup --noinstall \
  && sudo -u orca psql orca < /tmp/orca.dump \
  && jma-setup \
  && service jma-receipt start
EXPOSE 8000
CMD service postgresql restart && service jma-receipt start && tail -f /dev/null
