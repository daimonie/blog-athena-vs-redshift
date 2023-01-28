FROM python:3.10

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -; \
    apt-get install -y nodejs
RUN npm install -g aws-cdk@2.61.0; \
    cdk --version

WORKDIR /opt/container
COPY container/ .
RUN pip install -r requirements.txt
RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -; \
    apt-get install -y nodejs

CMD [ "/bin/bash" ]
