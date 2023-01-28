version = "0.1.3"
install:
	docker build -t blog-athena-infra .

dev:
	docker run -it --rm \
	-v $(PWD)/container/:/opt/container \
	blog-athena-infra

pre-commit:
	pip install pre-commit
	pre-commit run --all

unittest:
	docker run \
	-v $(PWD)/container/:/opt/container \
	blog-athena-infra:latest \
	pytest

synth:
	docker run \
	-v $(PWD)/container/:/opt/container \
	-e AWS_DEFAULT_ACCOUNT=12 \
	blog-athena-infra:latest \
	cdk synth --app "python3 main.py"
