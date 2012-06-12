all: test linc
test:
	jasmine-node --coffee --color --verbose .
linc:
	coffee -c -o ./ src/linc.coffee
	smoosh make/build.json
