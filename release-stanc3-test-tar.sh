cd ..
tar -czf performance-tests-cmdstan.tar.gz ./performance-tests-cmdstan
ghr --recreate stanc3-tests-`date --iso-8601`
