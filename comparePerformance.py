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

def write_output(ratios):

    f = open(os + "_compare_results.xml", "w+")

    # Keep this print so Jenkins can extract what's in between for GitHub
    #f.write("---RESULTS---")

    f.write("| Name | Old Result | New Result | Ratio | Performance change( 1 - new / old ) | \n")
    f.write("| ------------- |------------- | ------------- | ------------- | ------------- | \n")

    total = 0
    for r in ratios:
        f.write("| " + r + " | " +  
            str(round(ratios[r]['old'], 2)) + " | " +
            str(round(ratios[r]['new'], 2)) + " | " +
            str(round(ratios[r]['ratio'], 2)) + " | " +
            str(round(ratios[r]['change'], 2)) + ("% faster" if round(ratios[r]['change'], 2) > 0 else "% slower" ) + " | \n"
        )
        total = total + ratios[r]['ratio']

    f.write("Mean result: " + str(total / len(ratios)) + "\n")

    f.close()

    # Keep this print so Jenkins can extract what's in between for GitHub
    #f.write("---RESULTS---")

if __name__ == "__main__":
    csv1 = sys.argv[1]
    csv2 = sys.argv[2]
    os = sys.argv[3]
    times1, times2 = map(get_times, [csv1, csv2])
    ratios = {}

    for n in times1:
        print("---")
        print(n)
        print("---")
        #key = "performance.compilation" if "compilation" in n else n
        key = n

        old = times1[n]
        new = times2[key]
        ratio = old / new

        ratios[key] = {
            "old": old,
            "new": new,
            "ratio": ratio,
            "change": (1 - new / old) * 100
        }

    write_output(ratios)