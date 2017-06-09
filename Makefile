.PHONY: bootstrap clean minify_css build
# .SILENT: clean

default: build

bootstrap:
	wget https://raw.githubusercontent.com/necolas/normalize.css/master/normalize.css -O src/normalize.css

clean:
	rm -rf build
	rm -f src/*.min.css

minify_css: clean
	util/minify_css.rb

build: clean minify_css
	mkdir build
	cp src/favicon.ico build/
	cp src/robots.txt build/
	util/inline.rb src/index.html build/index.html

