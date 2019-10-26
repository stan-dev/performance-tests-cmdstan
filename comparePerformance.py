#!/usr/bin/python

import sys

def mean(nums):
    return sum(nums) / len(nums)

def get_times(csv):
    times = {}
    with open(csv) as f:
        for line in f:
            name, time_ = line.split(",")
            time_ = float(time_)
            if time_ == 0:
                print("Warning - {} was 0 for ".format(name, csv))
                continue
            times[name] = float(time_)
    return times

if __name__ == "__main__":
    csv1 = sys.argv[1]
    csv2 = sys.argv[2]
    os = sys.argv[3]
    times1, times2 = map(get_times, [csv1, csv2])
    ratios = [(n, times1[n]/times2[n]) for n in times1]

    f = open(os + "_compare_results.xml", "w+")

    #<testcase name="compilation" result="99.7739980221"/>
    for r in ratios:
        f.write("<testcase name=\"" + str(r[0]) + "\" time=\"" + str(round(r[1], 2)) + "\"/>")

    f.write(str(mean([r for _, r in ratios])))

    f.close()