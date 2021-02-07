all: install

help:
	@echo ""
	@echo "-- Help Menu"
	@echo ""
	@echo "   1. make build            - build the image"
	@echo "   2. make install          - install launch wrappers"
	@echo ""

build:
	@docker build --tag=docker-zoom:$(shell cat VERSION) .

install uninstall: build
	@docker run -it --rm \
		--volume=/usr/local/bin:/target \
		--user root \
		docker-zoom:$(shell cat VERSION) $@
