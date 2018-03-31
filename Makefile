clean:
	git submodule update --init --recursive
	git submodule foreach --recursive git clean -xffd
	cd cmdstan; make clean-all; cd ..
