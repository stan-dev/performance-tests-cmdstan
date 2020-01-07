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

def print_output_markdown(ratios):

    # Keep this print so Jenkins can extract what's in between for GitHub
    print("---RESULTS---")

    print("| Name | Old Result | New Result | Ratio | Performance change( 1 - new / old ) |")
    print("| ------------- |------------- | ------------- | ------------- | ------------- |")

    total = 0
    for r in ratios:
        print("| " + r + " | " +  
            str(round(ratios[r]['old'], 2)) + " | " +
            str(round(ratios[r]['new'], 2)) + " | " +
            str(round(ratios[r]['ratio'], 2)) + " | " +
            str(round(ratios[r]['change'], 2)) + ("% faster" if round(ratios[r]['change'], 2) > 0 else "% slower" ) + " |"
        )
        total = total + ratios[r]['ratio']

    print("Mean result: " + str(total / len(ratios)))
    
    # Keep this print so Jenkins can extract what's in between for GitHub
    print("---RESULTS---")

def print_output_csv(ratios):

    print("Name, Old Result, New Result, Ratio, Performance change( 1 - new / old )")

    total = 0
    for r in ratios:
        print(r + ", " +
            str(round(ratios[r]['old'], 2)) + ", " +
            str(round(ratios[r]['new'], 2)) + ", " +
            str(round(ratios[r]['ratio'], 2)) + ", " +
            str(round(ratios[r]['change'], 2)) + ("% faster" if round(ratios[r]['change'], 2) > 0 else "% slower" )
        )
        total = total + ratios[r]['ratio']

    print("Mean result: " + str(total / len(ratios)))
    
if __name__ == "__main__":
    csv1 = sys.argv[1]
    csv2 = sys.argv[2]
    output_type = sys.argv[3]
    times1, times2 = map(get_times, [csv1, csv2])
    ratios = {}

    for n in times1:
        key = "performance.compilation" if "compilation" in n else n

        old = times1[n]
        new = times2[key]
        ratio = old / new

        ratios[key] = {
            "old": old,
            "new": new,
            "ratio": ratio,
            "change": (1 - new / old) * 100
        }

    if output_type == "markdown":
        print_output_markdown(ratios)
    elif output_type == "csv":
        print_output_csv(ratios)
    elif not output_type:
        print_output_csv(ratios)