#!/usr/bin/python

import os
from fnmatch import fnmatch

def find_files(pattern, dirs):
    res = []
    for pd in dirs:
        for d, _, flist in os.walk(pd):
            for f in flist:
                if fnmatch(f, pattern):
                    res.append(os.path.join(d, f))
    return res

files = find_files("*.stan", ["example-models/bugs_examples"])

with open('test.txt', 'w') as f:
    for item in files:
        f.write("%s\n" % item)