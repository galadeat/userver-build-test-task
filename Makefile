IMAGE := userver-build-analysis
SERVICE := myservice

DOCKER_ARGS := --rm \
	--cpus=4 \
	--cpuset-cpus=0-3 \
	--memory=8g \
	--memory-swap=8g \
	-v "$(CURDIR):/work" \
	-w /work

CBA := tools/ClangBuildAnalyzer/build/ClangBuildAnalyzer
TRACE_BUILD_DIR := myservice/build-release

.PHONY: image shell configure build setup-analyzer analyze

image:
	docker build -t $(IMAGE) .

shell:
	docker run -it $(DOCKER_ARGS) $(IMAGE) bash

configure:
	docker run $(DOCKER_ARGS) $(IMAGE) \
		bash -c 'cd /work/$(SERVICE) && cmake --preset release \
			-DCMAKE_C_COMPILER=clang-14 \
			-DCMAKE_CXX_COMPILER=clang++-14 \
			-DUSERVER_COMPILATION_TIME_TRACE=ON \
			-DUSERVER_USE_CCACHE=OFF'

build:
	docker run $(DOCKER_ARGS) $(IMAGE) \
		cmake --build /work/$(SERVICE)/build-release --parallel 2


setup-analyzer:
	bash scripts/setup-analyzer.sh

analyze: setup-analyzer
	mkdir -p results
	$(CBA) --all $(TRACE_BUILD_DIR) results/baseline.bin
	$(CBA) --analyze results/baseline.bin > results/baseline.txt
	cat results/baseline.txt