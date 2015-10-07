FROM alpine
MAINTAINER Genki Takiuchi <genki@s21g.com>

RUN apk add --update ruby && rm -rf /var/cache/apk/*
RUN gem install --no-ri --no-rdoc json_pure && gem cleanup

RUN mkdir /gantry
WORKDIR /gantry
ADD ./run ./
ADD ./server ./

VOLUME /gantry
EXPOSE 6479
ENTRYPOINT /gantry/server
