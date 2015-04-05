.PHONY: test docker-test

PWD=$(shell pwd)

test:
	sbcl \
		--eval '(ql:quickload :prove)' \
		--eval '(ql:quickload :clscript-test)' \
		--eval '(or (prove:run :clscript-test) (uiop:quit -1))' \
		--quit

docker-test:
	docker run -v $(PWD):/root/common-lisp/clscript -w /root/common-lisp/clscript -t dparnell/sbcl-1.2.5 make test
