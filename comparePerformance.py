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
    #ratios = [(n, times1[n]/times2[n]) for n in times1]
    ratios = {}

    for n in times1:
        key = "compilation" if "compilation" in n else n

        print("Key: " + str(key))

        old = times1[key]
        new = times2[key]
        ratio = old / new

        ratios[key] = {
            "old": old,
            "new": new,
            "ratio": ratio,
            "change": (1 - new / old) * 100
        }

    print("| Name, Old Value, New Value, Ratio, Change % |")
    total = 0
    for r in ratios:
        print(r, 
            round(ratios[r]['old'], 2), 
            round(ratios[r]['new'], 2), 
            round(ratios[r]['ratio'], 2), 
            round(ratios[r]['change'], 2)
        )
        total = total + ratios[r]['ratio']

    meanResult = total / len(ratios)
    print("Mean: " + str(meanResult))
