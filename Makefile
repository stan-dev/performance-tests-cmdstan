clean:
	cd cmdstan; make clean-all; cd ..
	git submodule foreach --recursive git clean -xffd

revert:
	git submodule update --init --recursive
