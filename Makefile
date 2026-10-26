IMAGE := userver-build-analysis
SERVICE ?= origin

DOCKER_ARGS := --rm \
	--cpus=4 \
	--cpuset-cpus=0-3 \
	--memory=8g \
	--memory-swap=8g \
	-v "$(CURDIR):/work" \
	-w /work

CBA := tools/ClangBuildAnalyzer/build/ClangBuildAnalyzer
TRACE_BUILD_DIR ?= $(SERVICE)/build-release

OUTPUT ?= results/baseline

.PHONY: image shell configure build setup-analyzer analyze reproduce

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
	mkdir -p "$(dir $(OUTPUT))"
	$(CBA) --all "$(TRACE_BUILD_DIR)" "$(OUTPUT).bin"
	$(CBA) --analyze "$(OUTPUT).bin" > "$(OUTPUT).txt"
	cat "$(OUTPUT).txt"

reproduce:
	bash scripts/reproduce.sh