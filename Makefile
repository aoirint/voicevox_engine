CMD=

build-linux-docker-ubuntu:
	docker buildx build . \
		-t aoirint/voicevox_engine:cpu-ubuntu20.04 \
		--target runtime-env \
		--progress plain \
		--build-arg BASE_RUNTIME_IMAGE=ubuntu:focal

run-linux-docker-ubuntu:
	docker run --rm -it \
		-p '127.0.0.1:50021:50021' \
		aoirint/voicevox_engine:cpu-ubuntu20.04 $(CMD)

build-linux-docker-nvidia:
	docker buildx build . \
		-t aoirint/voicevox_engine:nvidia-ubuntu20.04 \
		--target runtime-nvidia-env \
		--progress plain \
		--build-arg BASE_RUNTIME_IMAGE=nvidia/cuda:11.4.1-cudnn8-runtime-ubuntu20.04

run-linux-docker-nvidia:
	docker run --rm -it \
		--gpus all \
		-p '127.0.0.1:50021:50021' \
		aoirint/voicevox_engine:nvidia-ubuntu20.04 $(CMD)
