clean:
	git submodule update --init --recursive
	git submodule foreach --recursive git clean -xffd
	pushd cmdstan; make clean-all; popd
