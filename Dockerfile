FROM python:3.10

# nodejs will install npm

RUN curl -fsSL https://deb.nodesource.com/setup_lts.x | bash -; \
    apt-get install -y nodejs

# use npm to install the aws cdk
RUN npm install -g npm@9.4.2
RUN npm install -g aws-cdk

RUN cdk --version

# get the aws cli tools. This is convenient when developing, could be removed if you want to actually use this.
RUN apt update
RUN apt install curl unzip -y
RUN curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
RUN unzip awscliv2.zip
RUN ./aws/install

# Set workdir
WORKDIR /opt/container
COPY container/ .

# Install requirements
RUN pip install -r requirements.txt

CMD [ "/bin/bash" ]
