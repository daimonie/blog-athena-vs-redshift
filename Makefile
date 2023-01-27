version = "0.1.3"
install:
	docker build -t blog-athena-infra .

dev:
	docker run -it --rm \
	-v $(PWD)/container/:/opt/container \
	blog-athena-infra

pre-commit:
	docker run \
	-v $(PWD)/container/:/opt/container \
	blog-athena-infra:latest \
	pre-commit run --all

unittest-woco:
	docker run \
	-v $(PWD)/container/:/opt/container \
	blog-athena-infra:latest \
	pytest

synth-woco:
	docker run \
	-v $(PWD)/container/:/opt/container \
	blog-athena-infra:latest \
	cdk synth
