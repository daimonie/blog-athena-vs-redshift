FROM python:3.9

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -; \
    apt-get install -y nodejs

RUN npm install -g aws-cdk@2.61.0; \
    cdk --version

WORKDIR /src
COPY ./ .
RUN pip install -r requirements.txt
RUN pip install -r requirements-dev.txt

CMD [ "/bin/bash" ]
