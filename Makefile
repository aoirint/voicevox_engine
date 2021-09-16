CMD=

# Ubuntu 20.04
.PHONY: build-linux-docker-ubuntu20.04
build-linux-docker-ubuntu20.04:
	docker buildx build . \
		-t hiroshiba/voicevox_engine:cpu-ubuntu20.04-latest \
		--target runtime-env \
		--progress plain \
		--build-arg BASE_IMAGE=ubuntu:focal \
		--build-arg BASE_RUNTIME_IMAGE=ubuntu:focal \
		--build-arg LIBTORCH_URL=https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.9.0%2Bcpu.zip \
		--build-arg INFERENCE_DEVICE=cpu

.PHONY: run-linux-docker-ubuntu20.04
run-linux-docker-ubuntu20.04:
	docker run --rm -it \
		-p '127.0.0.1:50021:50021' \
		hiroshiba/voicevox_engine:cpu-ubuntu20.04-latest $(CMD)

.PHONY: build-linux-docker-nvidia-ubuntu20.04
build-linux-docker-nvidia-ubuntu20.04:
	docker buildx build . \
		-t hiroshiba/voicevox_engine:nvidia-ubuntu20.04-latest \
		--target runtime-nvidia-env \
		--progress plain \
		--build-arg BASE_IMAGE=ubuntu:focal \
		--build-arg BASE_RUNTIME_IMAGE=nvidia/cuda:11.4.1-cudnn8-runtime-ubuntu20.04 \
		--build-arg LIBTORCH_URL=https://download.pytorch.org/libtorch/cu111/libtorch-cxx11-abi-shared-with-deps-1.9.0%2Bcu111.zip \
		--build-arg INFERENCE_DEVICE=nvidia

.PHONY: run-linux-docker-nvidia-ubuntu20.04
run-linux-docker-nvidia-ubuntu20.04:
	docker run --rm -it \
		--gpus all \
		-p '127.0.0.1:50021:50021' \
		hiroshiba/voicevox_engine:nvidia-ubuntu20.04-latest $(CMD)


# Ubuntu 18.04
.PHONY: build-linux-docker-ubuntu18.04
build-linux-docker-ubuntu18.04:
	docker buildx build . \
		-t hiroshiba/voicevox_engine:cpu-ubuntu18.04-latest \
		--target runtime-bionic-env \
		--progress plain \
		--build-arg BASE_IMAGE=ubuntu:bionic \
		--build-arg BASE_RUNTIME_IMAGE=ubuntu:bionic \
		--build-arg LIBTORCH_URL=https://download.pytorch.org/libtorch/cpu/libtorch-cxx11-abi-shared-with-deps-1.9.0%2Bcpu.zip \
		--build-arg INFERENCE_DEVICE=cpu

.PHONY: run-linux-docker-ubuntu18.04
run-linux-docker-ubuntu18.04:
	docker run --rm -it \
		-p '127.0.0.1:50021:50021' \
		hiroshiba/voicevox_engine:cpu-ubuntu18.04-latest $(CMD)

.PHONY: build-linux-docker-ubuntu18.04
build-linux-docker-nvidia-ubuntu18.04:
	docker buildx build . \
		-t hiroshiba/voicevox_engine:nvidia-ubuntu18.04-latest \
		--target runtime-nvidia-bionic-env \
		--progress plain \
		--build-arg BASE_IMAGE=ubuntu:bionic \
		--build-arg BASE_RUNTIME_IMAGE=nvidia/cuda:11.4.1-cudnn8-runtime-ubuntu18.04 \
		--build-arg LIBTORCH_URL=https://download.pytorch.org/libtorch/cu111/libtorch-cxx11-abi-shared-with-deps-1.9.0%2Bcu111.zip \
		--build-arg INFERENCE_DEVICE=nvidia

.PHONY: run-linux-docker-ubuntu18.04
run-linux-docker-nvidia-ubuntu18.04:
	docker run --rm -it \
		-p '127.0.0.1:50021:50021' \
		hiroshiba/voicevox_engine:nvidia-ubuntu18.04-latest $(CMD)

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
