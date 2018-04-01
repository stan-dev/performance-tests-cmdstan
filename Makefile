clean:
	cd cmdstan; make clean-all; cd ..

revert:
	git submodule update --init --recursive
	git submodule foreach --recursive git clean -xffd
