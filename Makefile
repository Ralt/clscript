.PHONY: test

test:
	sbcl \
		--eval '(ql:quickload :clscript-test)' \
		--eval '(or (prove:run :clscript-test) (uiop:quit -1))' \
		--quit
