ROOT_DIR=$(dir $(realpath $(firstword $(MAKEFILE_LIST))))
CMD=

.PHONY: build-linux-docker-ubuntu
build-linux-docker-ubuntu:
	docker buildx build . \
		-t hiroshiba/voicevox_engine:cpu-ubuntu20.04-latest \
		--target runtime-env \
		--progress plain \
		--build-arg BASE_RUNTIME_IMAGE=ubuntu:focal \
		--build-arg VOICEVOX_CORE_VERSION=0.5.2 \
		--build-arg VOICEVOX_CORE_EXAMPLE_VERSION=0.5.2

.PHONY: run-linux-docker-ubuntu
run-linux-docker-ubuntu:
	docker run --rm -it \
		-p '127.0.0.1:50021:50021' \
		hiroshiba/voicevox_engine:cpu-ubuntu20.04-latest $(CMD)

.PHONY: build-linux-docker-nvidia
build-linux-docker-nvidia:
	docker buildx build . \
		-t hiroshiba/voicevox_engine:nvidia-ubuntu20.04-latest \
		--target runtime-nvidia-env \
		--progress plain \
		--build-arg BASE_RUNTIME_IMAGE=nvidia/cuda:11.4.1-cudnn8-runtime-ubuntu20.04

.PHONY: run-linux-docker-nvidia
run-linux-docker-nvidia:
	docker run --rm -it \
		--gpus all \
		-p '127.0.0.1:50021:50021' \
		hiroshiba/voicevox_engine:nvidia-ubuntu20.04-latest $(CMD)

.PHONY: build-linux-docker-compile-python-env
build-linux-docker-compile-python-env:
	docker buildx build . \
		-t hiroshiba/voicevox_engine:compile-python-env \
		--target compile-python-env \
		--progress plain \
		--build-arg BASE_RUNTIME_IMAGE=ubuntu:focal

.PHONY: run-linux-docker-compile-python-env
run-linux-docker-compile-python-env:
	docker run --rm -it \
		hiroshiba/voicevox_engine:compile-python-env $(CMD)
