# blog-athena-vs-redshift

CDK scripts for athena vs redshift blog

## Instructions

The makefile specifies the most important steps:
* install: This will build the docker image.
* dev: this allows you to use the docker image as a virtual environment for development.
* pre-commit: this installs and runs pre-commit.
* unittest: This runs a unittest using the docker image.
* synth: This runs a `cdk synth` using the docker image.
* deploy: This will run `cdk deploy` with some arguments. Not used in the GH actions pipeline. 

## Github Actions
The github actions, runs the tests with empty environment variables, and makes sure that:
* The code passes linting/styling tests.
* The code passes unit tests.
* The code passes a `synth` test, which mostly means that CDK can actually dry run.

The environment variables are mostly required for deployment, using a local console. The list is:
* XOMNIA_AWS_KEY: This is the `AWS_ACCESS_KEY` for a service account.
* XOMNIA_AWS_SECRET: This is the `AWS_SECRET_ACCESS_KEY` for a service account.
* XOMNIA_AWS_DEFAULT_ACCOUNT: This is the Account ID of the AWS account to be used.

