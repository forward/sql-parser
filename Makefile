test:
	./node_modules/.bin/cake build && ./node_modules/.bin/mocha --require should --compilers coffee:coffee-script

.PHONY: test