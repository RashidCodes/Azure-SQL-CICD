FROM --platform=linux/amd64 ubuntu:22.04

SHELL ["/bin/bash", "-c"]

RUN apt update
RUN apt upgrade -y
RUN apt install -y curl git jq libicu70

RUN apt-get install -y unzip dotnet-sdk-7.0 dotnet-runtime-7.0 vim

RUN mkdir /sqlpackage
RUN cd /sqlpackage
RUN curl -Lq https://go.microsoft.com/fwlink/?linkid=2225105 -o sqlpackage-linux-x64-latest.zip
RUN unzip sqlpackage-linux-x64-latest -d /sqlpackage
RUN apt-get install libunwind8
ENV PATH="${PATH}:/sqlpackage"

RUN chmod a+x /sqlpackage/sqlpackage

# Also can be "linux-arm", "linux-arm64".
ENV TARGETARCH="linux-x64"

WORKDIR /azp/

COPY ./start.sh ./
RUN chmod +x ./start.sh

RUN useradd agent
RUN chown agent ./
USER agent
# Another option is to run the agent as root.
# ENV AGENT_ALLOW_RUNASROOT="true"

ENTRYPOINT ./start.sh