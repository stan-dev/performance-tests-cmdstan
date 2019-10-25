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
    times1, times2 = map(get_times, [csv1, csv2])
    ratios = [(n, times1[n]/times2[n]) for n in times1]

    f = open(csv1 + " - " + csv2 + ".xml", "w+")

    for r in ratios:
        f.write(str(r[0]) + ", " + str(round(r[1], 2)))

    f.write(str(mean([r for _, r in ratios])))

    f.close()