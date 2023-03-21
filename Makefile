docker_image_name = "blog-athena-infra"
install:
	docker build -t $(docker_image_name) .

dev:
	docker run -it --rm \
	-v $(PWD)/container/:/opt/container \
	-e AWS_ACCESS_KEY_ID=$$XOMNIA_AWS_KEY \
	-e AWS_SECRET_ACCESS_KEY=$$XOMNIA_AWS_SECRET \
	-e AWS_DEFAULT_REGION=eu-central-1 \
	-e AWS_DEFAULT_ACCOUNT=$$XOMNIA_AWS_DEFAULT_ACCOUNT \
	$(docker_image_name)

pre-commit:
	pip install pre-commit && pre-commit run --all

unittest:
	docker run \
	-v $(PWD)/container/:/opt/container \
	-e AWS_ACCESS_KEY_ID=$$XOMNIA_AWS_KEY \
	-e AWS_SECRET_ACCESS_KEY=$$XOMNIA_AWS_SECRET \
	-e AWS_DEFAULT_REGION=eu-central-1 \
	-e AWS_DEFAULT_ACCOUNT=$$XOMNIA_AWS_DEFAULT_ACCOUNT \
	$(docker_image_name):latest \
	pytest

synth:
	docker run \
	-v $(PWD)/container/:/opt/container \
	-e AWS_ACCESS_KEY_ID=$$XOMNIA_AWS_KEY \
	-e AWS_SECRET_ACCESS_KEY=$$XOMNIA_AWS_SECRET \
	-e AWS_DEFAULT_REGION=eu-central-1 \
	-e AWS_DEFAULT_ACCOUNT=$$XOMNIA_AWS_DEFAULT_ACCOUNT \
	$(docker_image_name):latest \
	cdk synth --app "python3 main.py" --output cdk2.out

deploy:
	docker run \
	-v $(PWD)/container/:/opt/container \
	-e AWS_ACCESS_KEY_ID=$$XOMNIA_AWS_KEY \
	-e AWS_SECRET_ACCESS_KEY=$$XOMNIA_AWS_SECRET \
	-e AWS_DEFAULT_REGION=eu-central-1 \
	-e AWS_DEFAULT_ACCOUNT=$$XOMNIA_AWS_DEFAULT_ACCOUNT \
	$(docker_image_name):latest \
	cdk deploy --require-approval never --all  --app "python3 main.py" --output cdk5.out
