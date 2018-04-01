make revert
make clean
echo "--march=core2" >> cmdstan/make/local
./runPerformanceTests.py -j8 --overwrite --runj 8 stat_comp_benchmarks/
