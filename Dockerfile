FROM ruby:2.2
MAINTAINER Ivan Valdes <ivan@vald.es>

ENV NGINX_VERSION 1.8.1-1~jessie
ENV LANG C.UTF-8

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
	&& echo "deb http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install -y ca-certificates nginx=${NGINX_VERSION} gettext-base supervisor locales vim python-pip \
	&& rm -rf /var/lib/apt/lists/* \
	&& rm -rf /etc/nginx/conf.d/* \
	&& echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
	&& locale-gen \
	&& pip install s3cmd

COPY files/nginx.conf /etc/nginx/nginx.conf
COPY files/supervisord.conf /etc/supervisor/supervisord.conf

EXPOSE 80

RUN addgroup --gid 9999 app \
	&& adduser --uid 9999 --gid 9999 --disabled-password --gecos "Application" app \
	&& usermod -L app \
	&& mkdir -p /home/app/.ssh \
	&& chmod 700 /home/app/.ssh \
	&& chown app:app /home/app/.ssh

CMD ["/usr/bin/supervisord"]
