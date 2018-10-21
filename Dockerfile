FROM ubuntu:18.04
MAINTAINER John Orth <jmorth at gmail dot com>

RUN echo 'debconf debconf/frontend select Noninteractive' | debconf-set-selections && \
    echo steam steam/question select "I AGREE" | debconf-set-selections && \
    echo steam steam/license note '' | debconf-set-selections

RUN dpkg --add-architecture i386

RUN apt-get -y update && \
    apt-get -y upgrade && \
    apt-get -y install curl && \
    apt-get -y install steamcmd && \
    apt-get -y install libtinfo5:i386 libncurses5:i386 libcurl3-gnutls:i386 && \
    apt-get clean &&  \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

ENV USER tf2

RUN useradd $USER
ENV HOME /home/$USER
RUN mkdir $HOME
RUN chown $USER:$USER $HOME

USER $USER
ENV SERVER $HOME/hlserver
RUN mkdir $SERVER
RUN curl http://media.steampowered.com/client/steamcmd_linux.tar.gz | tar -C $SERVER -xvz
ADD ./tf2_ds.txt $SERVER/tf2_ds.txt
ADD ./update.sh $SERVER/update.sh
ADD ./tf.sh $SERVER/tf.sh
RUN $SERVER/update.sh

EXPOSE 27015/udp

WORKDIR /home/$USER/hlserver
ENTRYPOINT ["./tf.sh"]
CMD ["+sv_pure", "1", "+mapcycle", "mapcycle_quickplay_payload.txt", "+map", "pl_badwater", "+maxplayers", "24"]
