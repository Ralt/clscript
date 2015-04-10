APP_NAME=clscript
LISP_FILES=$(shell find . -name '*.lisp')
ASDF_TREE ?= ~/quicklisp/
DIST_FOLDER ?= dist/root/usr/bin
APP_OUT=$(DIST_FOLDER)/$(APP_NAME)
QL_LOCAL=$(PWD)/.quicklocal/quicklisp
QUICKLISP_SCRIPT=http://beta.quicklisp.org/quicklisp.lisp
LOCAL_OPTS=--noinform --noprint --disable-debugger --no-sysinit --no-userinit
QL_OPTS=--load $(QL_LOCAL)/setup.lisp
LISP ?= sbcl
SOURCES := $(wildcard src/*.lisp) $(wildcard *.asd)
BUILDAPP = ./bin/buildapp
WITH_DOCS ?= 0
WITH_COMPRESSION ?= 0
PWD=$(shell pwd)

.PHONY: test docker-test clean install release deb rpm test man create-base-container aergia-test

all: $(APP_OUT)

test:
	sbcl \
		--eval '(ql:quickload :prove)' \
		--eval '(ql:quickload :clscript-test)' \
		--eval '(or (prove:run :clscript-test) (uiop:quit -1))' \
		--quit

docker-test:
	docker run -v $(PWD):/root/common-lisp/clscript -w /root/common-lisp/clscript -t dparnell/sbcl-1.2.5 make test

release:
ifndef VERSION
	$(error VERSION needs to be provided.)
endif
	make clean
	make
	make man
	make deb
	make rpm

man:
ifeq ($(WITH_DOCS),1)
	mkdir -p dist/root/usr/share/man/man1/
	pandoc -s -t man manpage.md > dist/root/usr/share/man/man1/$(APP_NAME).1
	gzip dist/root/usr/share/man/man1/$(APP_NAME).1
endif

install: man $(APP_OUT)
	install $(APP_OUT) $(DESTDIR)/usr/bin
ifeq ($(WITH_DOCS),1)
	install -g 0 -o 0 -m 0644 dist/root/usr/share/man/man1/$(APP_NAME).1.gz /usr/share/man/man1/
endif

bin:
	@mkdir bin

clean:
	@-yes | rm -rf $(QL_LOCAL)
	@-rm -f $(APP_OUT) deps install-deps
	@-rm -f dist/aergia*

$(QL_LOCAL)/setup.lisp:
	@curl -O $(QUICKLISP_SCRIPT)
	@sbcl $(LOCAL_OPTS) \
		--load quicklisp.lisp \
		--eval '(quicklisp-quickstart:install :path "$(QL_LOCAL)")' \
		--eval '(quit)'

deps:
	@sbcl $(LOCAL_OPTS) $(QL_OPTS) \
	     --eval '(push "$(PWD)/" asdf:*central-registry*)' \
	     --eval '(ql:quickload :clscript)' \
	     --eval '(quit)'
	@touch $@

install-deps: $(QL_LOCAL)/setup.lisp deps
	@touch $@

bin/buildapp: bin $(QL_LOCAL)/setup.lisp
	@cd $(shell sbcl $(LOCAL_OPTS) $(QL_OPTS) \
				--eval '(ql:quickload :buildapp :silent t)' \
				--eval '(format t "~A~%" (asdf:system-source-directory :buildapp))' \
				--eval '(quit)') && \
	$(MAKE) DESTDIR=$(PWD) install

$(APP_OUT): $(SOURCES) bin/buildapp $(QL_LOCAL)/setup.lisp install-deps
	@mkdir -p $(DIST_FOLDER)
	@$(BUILDAPP) --logfile /tmp/build.log \
			--sbcl sbcl \
			--asdf-path . \
			--asdf-tree $(QL_LOCAL)/local-projects \
			--asdf-tree $(QL_LOCAL)/dists \
			--asdf-path . \
			--load-system $(APP_NAME) \
			--entry $(APP_NAME):main \
			--output $(APP_OUT)
