FROM --platform=linux/amd64 ubuntu:22.04

SHELL ["/bin/bash", "-c"]

WORKDIR /src  

COPY . .

RUN apt-get update

RUN apt-get install unzip

RUN apt install -y curl

RUN apt-get install -y dotnet-sdk-7.0

RUN apt-get install -y dotnet-runtime-7.0

RUN mkdir /sqlpackage
RUN cd /sqlpackage
RUN curl -Lq https://go.microsoft.com/fwlink/?linkid=2225105 -o sqlpackage-linux-x64-latest.zip
RUN unzip sqlpackage-linux-x64-latest -d /sqlpackage
RUN apt-get install libunwind8
ENV PATH="${PATH}:/sqlpackage"

RUN chmod a+x /sqlpackage/sqlpackage

CMD . ./extract_and_publish.sh
