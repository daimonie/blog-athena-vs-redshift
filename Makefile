version = "0.1.3"
docker_image_name = "blog-athena-infra"
install:
	docker build -t $(docker_image_name) .

dev:
	docker run -it --rm \
	-v $(PWD)/container/:/opt/container \
	$(docker_image_name)

pre-commit:
	docker run -v $(PWD):/opt/repo \
	-w /opt/repo \
	$(docker_image_name):latest \
	pre-commit run --all

unittest:
	docker run \
	-v $(PWD)/container/:/opt/container \
	-e AWS_DEFAULT_ACCOUNT=12 \
	$(docker_image_name):latest \
	pytest

synth:
	docker run \
	-v $(PWD)/container/:/opt/container \
	-e AWS_DEFAULT_ACCOUNT=12 \
	$(docker_image_name):latest \
	cdk synth --app "python3 main.py"
