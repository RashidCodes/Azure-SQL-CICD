FROM --platform=linux/amd64 ubuntu:20.04

SHELL ["/bin/bash", "-c"]

WORKDIR /src

COPY ["q89BuI8PiZXjiaHE3HF6LlywtzUL.sh", "./"]

RUN apt-get update

RUN apt-get install unzip

RUN apt install -y curl

RUN mkdir /sqlpackage
RUN cd /sqlpackage
RUN curl -Lq https://go.microsoft.com/fwlink/?linkid=2225105 -o sqlpackage-linux-x64-latest.zip
RUN unzip sqlpackage-linux-x64-latest -d /sqlpackage
RUN apt-get install libunwind8
RUN apt-get install -y libicu66
ENV PATH="${PATH}:/sqlpackage"

RUN chmod a+x /sqlpackage/sqlpackage

CMD . ./q89BuI8PiZXjiaHE3HF6LlywtzUL.sh