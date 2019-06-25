#!/usr/bin/python

import argparse
import csv
from collections import defaultdict
import os
import os.path
import sys
import re
import subprocess
from difflib import SequenceMatcher
from fnmatch import fnmatch
from functools import wraps
from multiprocessing.pool import ThreadPool
from time import time
from datetime import datetime
import xml.etree.ElementTree as ET
import multiprocessing

GOLD_OUTPUT_DIR = os.path.join("golds","")
DIR_UP = os.path.join("..","")
CURR_DIR = os.path.join(".","")
SEP_RE = "\\\\" if os.sep == "\\" else "/"
EXE_FILE_EXT = ".exe" if os.name == "nt" else ""
def find_files(pattern, dirs):
    res = []
    for pd in dirs:
        for d, _, flist in os.walk(pd):
            for f in flist:
                if fnmatch(f, pattern):
                    res.append(os.path.join(d, f))
    return res

def read_tests(filename, default_num_samples):
    test_files = []
    num_samples_list = []
    with open(filename) as f:
        for line in f:
            line = line.strip()
            if line.startswith("#"): continue
            if ", " in line:
                model, num_samples = line.split(", ")
            else:
                model = line
                num_samples = default_num_samples
            num_samples_list.append(num_samples)
            test_files.append(model)
    return test_files, num_samples_list

def str_dist(target):
    def str_dist_internal(candidate):
        return SequenceMatcher(None, candidate, target).ratio()
    return str_dist_internal

def closest_string(target, candidates):
    if candidates:
        return max(candidates, key=str_dist(target))

def find_data_for_model(model):
    d = os.path.dirname(model)
    data_files = find_files("*.data.R", [d])
    if len(data_files) == 1:
        return data_files[0]
    else:
        return closest_string(model, data_files)

def time_step(name, fn, *args, **kwargs):
    start = time()
    res = fn(*args, **kwargs)
    end = time()
    return end-start, res

class FailedCommand(Exception):
    def __init__(self, returncode, command):
        self.returncode = returncode
        self.command = command
        Exception(self, "return code '{}' from command '{}'!"
                  .format(returncode, command))


def shexec(command, wd = "."):
    print(command)
    returncode = subprocess.call(command, shell=True, cwd=wd)
    if returncode != 0:
        raise FailedCommand(returncode, command)
    return returncode

def make(targets, j=8):
    try:
        shexec("make -i -j{} {}"
            .format(j, " ".join(DIR_UP + t + EXE_FILE_EXT for t in targets)), wd = "cmdstan")
    except FailedCommand:
        print("Failed to make at least some targets")

model_name_re = re.compile(".*"+SEP_RE+"[A-z_][^"+SEP_RE+"]+\.stan$")

bad_models = frozenset(
    [os.path.join("example-models","ARM","Ch.21","finite_populations.stan")
     , os.path.join("example-models","ARM","Ch.21","multiple_comparison.stan")
     , os.path.join("example-models","ARM","Ch.21","r_sqr.stan")
     , os.path.join("example-models","ARM","Ch.23","electric_1a.stan")
     , os.path.join("example-models","ARM","Ch.23","educational_subsidy.stan")
     , os.path.join("example-models","bugs_examples","vol2","pines","pines-3.stan")
     , os.path.join("example-models","bugs_examples","vol3","fire","fire.stan")
     # The following have data issues
     , os.path.join("example-models","ARM","Ch.10","ideo_two_pred.stan")
     , os.path.join("example-models","ARM","Ch.16","radon.1.stan")
     , os.path.join("example-models","ample-models","ARM","Ch.16","radon.2.stan")
     , os.path.join("example-models","ARM","Ch.16","radon.2a.stan")
     , os.path.join("example-models","ARM","Ch.16","radon.2b.stan")
     , os.path.join("example-models","ample-models","ARM","Ch.16","radon.3.stan")
     , os.path.join("example-models","ample-models","ARM","Ch.16","radon.nopooling.stan")
     , os.path.join("example-models","ARM","Ch.16","radon.pooling.stan")
     , os.path.join("example-models","ARM","Ch.18","radon.1.stan")
     , os.path.join("example-models","ARM","Ch.18","radon.2.stan")
     , os.path.join("example-models","ARM","Ch.18","radon.nopooling.stan")
     , os.path.join("example-models","ARM","Ch.18","radon.pooling.stan")
     , os.path.join("example-models","ARM","Ch.19","item_response.stan")
     , os.path.join("example-models","bugs_examples","vol1","dogs","dogs.stan")
     , os.path.join("example-models","bugs_examples","vol1","rats","rats_stanified.stan")
     , os.path.join("example-models","bugs_examples","vol2","pines","pines-4.stan")
     , os.path.join("example-models","bugs_examples","vol2","pines","fit.stan")
     , os.path.join("example-models","BPA","Ch.06","MtX.stan")
     , os.path.join("example-models","ARM","Ch.21","radon_vary_intercept_a.stan")
     , os.path.join("example-models","ARM","Ch.21","radon_vary_intercept_b.stan")
     , os.path.join("example-models","ARM","Ch.23","sesame_street2.stan")
     , os.path.join("example-models","ARM","Ch.3","kidiq_validation.stan")
     , os.path.join("example-models","ARM","Ch.7","earnings_interactions.stan")
     , os.path.join("example-models","ARM","Ch.8","y_x.stan")
     , os.path.join("example-models","basic_estimators","normal_mixture_k.stan")
     , os.path.join("example-models","basic_estimators","normal_mixture_k_prop.stan")
     , os.path.join("example-models","BPA","Ch.04","GLM0.stan")
     , os.path.join("example-models","BPA","Ch.04","GLM1.stan")
     , os.path.join("example-models","BPA","Ch.04","GLM2.stan")
     , os.path.join("example-models","BPA","Ch.04","GLMM3.stan")
     , os.path.join("example-models","BPA","Ch.04","GLMM4.stan")
     , os.path.join("example-models","BPA","Ch.04","GLMM5.stan")
     , os.path.join("example-models","BPA","Ch.05","ssm2.stan")
     , os.path.join("example-models","BPA","Ch.07","cjs_group_raneff.stan")
    ])

def avg(coll):
    return float(sum(coll)) / len(coll)

def stdev(coll, mean):
    if len(coll ) < 2:
        return 0
    return (sum((x - mean)**2 for x in coll) / (len(coll) - 1)**0.5)

def csv_summary(csv_file):
    d = defaultdict(list)
    with open(csv_file, 'rb') as raw:
        headers = None
        for row in csv.reader(raw):
            if row[0].startswith("#"):
                continue
            if headers is None:
                headers = row
                continue
            for i in range(0, len(row)):
                d[headers[i]].append(float(row[i]))
    res = {}
    for k, v in d.items():
        if k.endswith("__"):
            continue
        mean = avg(v)
        res[k] = (mean, stdev(v, mean))
    return res

def format_summary_lines(summary):
    return ["{} {.15f} {.15f}\n".format(k, avg, stdev) for k, (avg, stdev) in summary.items()]

def parse_summary(f):
    d = {}
    for line in f:
        param, avg, stdev = line.split()
        d[param] = (float(avg), float(stdev))
    return d

def run_model(exe, method, data, tmp, runs, num_samples):
    def run_as_fixed_param():
        shexec("{} method=sample algorithm='fixed_param' random seed=1234 output file={}"
               .format(exe, tmp))

    data_str = data and "data file={}".format(data)
    total_time = 0
    for i in range(runs):
        start = time()
        if not data_str:
            run_as_fixed_param()
        else:
            try:
                num_samples_str = ""
                if method == "sample":
                    num_samples_str = "num_samples={} num_warmup={}".format(num_samples, num_samples)
                shexec("{} method={} {} {} random seed=1234 output file={}"
                    .format(exe, method, num_samples_str, data_str, tmp))
            except FailedCommand as e:
                if e.returncode == 78:
                    run_as_fixed_param()
                else:
                    raise e
        end = time()
        total_time += end-start
    return total_time

def run_golds(gold, tmp, summary, check_golds_exact):
    gold_summary = {}
    with open(gold) as gf:
        gold_summary = parse_summary(gf)

    fails, errors = [], []
    first_params = set(summary)
    second_params = set(gold_summary)
    if not (first_params == second_params):
        msg = "First program has these extra params: {}.  ".format(
                first_params - second_params)
        msg += "2nd program has these extra params: {}.  ".format(
                second_params - first_params)
        msg += "They have these params in common: {}".format(
                second_params & first_params)
        print("ERROR: " + msg)
        errors.append(msg)
        return fails, errors
    for k, (mean, stdev) in gold_summary.items():
        if stdev < 0.00001: #XXX Uh...
            continue
        err = abs(summary[k][0] - mean)
        if check_golds_exact and err > check_golds_exact:
            print("FAIL: {} param {} |{} - {}| not within {}"
                    .format(gold, k, summary[k][0], mean, check_golds_exact))
            fails.append((k, mean, stdev, summary[k][0]))
        elif err > 0.0001 and (err / stdev) > 0.3:
            print("FAIL: {} param {} not within ({} - {}) / {} < 0.3"
                    .format(gold, k, summary[k][0], mean, stdev))
            fails.append((k, mean, stdev, summary[k][0]))
    if not fails and not errors:
        print("SUCCESS: Gold {} passed.".format(gold))
    return fails, errors

def run(exe, data, overwrite, check_golds, check_golds_exact, runs, method, num_samples):
    if not os.path.isfile(exe):
        return 0, ([], ["Did not compile!"])

    fails, errors = [], []
    gold = os.path.join(GOLD_OUTPUT_DIR,
                        exe.replace(DIR_UP, "").replace(os.sep, "_") + ".gold")
    tmp = gold + ".tmp"
    try:
        total_time = run_model(exe, method, data, tmp, runs, num_samples)
    except Exception as e:
        print("Encountered exception while running {}:".format(exe))
        print(e)
        return 0, (fails, errors + [str(e)])
    summary = csv_summary(tmp)
    with open(tmp, "w+") as f:
        f.writelines(format_summary_lines(summary))

    if overwrite:
        shexec("mv {} {}".format(tmp, gold))
    elif check_golds or check_golds_exact:
        fails, errors = run_golds(gold, tmp, summary, check_golds_exact)

    return total_time, (fails, errors)

def test_results_xml(tests):
    failures = str(sum(1 if x[2] else 0 for x in tests))
    time_ = str(sum(x[1] for x in tests))
    root = ET.Element("testsuite", disabled = '0',
            failures=failures, name="Performance Tests",
            tests=str(len(tests)), time=str(time_),
            timestamp=str(datetime.now()))
    for model, time_, fails, errors in tests:
        name = model.replace(".stan", "").replace(os.sep, ".")
        classname = name
        last_dot = name.rfind(".")
        if last_dot > 0:
            classname = classname[:last_dot]
            name = name[last_dot + 1:]
        time_ = str(time_)
        testcase = ET.SubElement(root, "testcase", status="run",
                classname=classname, name=name, time=time_)
        for fail in fails:
            failure = ET.SubElement(testcase, "failure", type="OffGold",
                    classname=classname, name = name,
                    message = ("param {} got mean {}, gold has mean {} and stdev {}"
                        .format(fail[0], fail[3], fail[1], fail[2])))
        for error in errors:
            err = ET.SubElement(testcase, "failure", type="Exception",
                    classname=classname, name = name, message = error)
    return ET.ElementTree(root)

def test_results_csv(tests):
    return "\n".join(",".join([model, str(time_)]) for model, time_, _, _ in tests) + "\n"

def parse_args():
    parser = argparse.ArgumentParser(description="Run gold tests and record performance.")
    parser.add_argument("directories", nargs="*")
    parser.add_argument("--check-golds", dest="check_golds", action="store_true",
                        help="Run the gold tests and check output within loose boundaries.")
    parser.add_argument("--check-golds-exact", dest="check_golds_exact", action="store",
                        help="Run the gold tests and check output to within specified tolerance",
                        type=float)
    parser.add_argument("--overwrite-golds", dest="overwrite", action="store_true",
                        help="Overwrite the gold test records.")
    parser.add_argument("--runs", dest="runs", action="store", type=int,
                        help="Number of runs per benchmark.", default=1)
    parser.add_argument("-j", dest="j", action="store", type=int, default=multiprocessing.cpu_count())
    parser.add_argument("--runj", dest="runj", action="store", type=int, default=1)
    parser.add_argument("--name", dest="name", action="store", type=str, default="performance")
    parser.add_argument("--method", dest="method", action="store", default="sample",
                        help="Inference method to ask Stan to use for all models.")
    parser.add_argument("--num-samples", dest="num_samples", action="store", default=None, type=int,
                        help="Number of samples to ask Stan programs for if we're sampling.")
    parser.add_argument("--tests-file", dest="tests", action="store", type=str, default="")
    return parser.parse_args()

def process_test(overwrite, check_golds, check_golds_exact, runs, method):
    def process_test_wrapper(tup):
        model, exe, data, num_samples = tup
        time_, (fails, errors) = run(exe, data, overwrite, check_golds,
                                     check_golds_exact, runs, method, num_samples)
        average_time = time_ / runs
        return (model, average_time, fails, errors)
    return process_test_wrapper

if __name__ == "__main__":
    args = parse_args()

    models = None

    default_num_samples = 1000
    if args.tests == "":
        models = find_files("*.stan", args.directories)
        num_samples = [args.num_samples or default_num_samples] * len(models)
    else:
        models, num_samples = read_tests(args.tests, args.num_samples or default_num_samples)
        if args.num_samples:
            num_samples = [args.num_samples] * len(models)

    models = filter(model_name_re.match, models)
    models = list(filter(lambda m: not m in bad_models, models))

    executables = [m[:-5] for m in models]
    make_time, _ = time_step("make_all_models", make, executables, args.j)
    tests = [(model, exe, find_data_for_model(model), ns)
             for model, exe, ns in zip(models, executables, num_samples)]
    if args.runj > 1:
        tp = ThreadPool(args.runj)
        map_ = tp.imap_unordered
    else:
        map_ = map
    results = map_(process_test(args.overwrite, args.check_golds,
                                args.check_golds_exact, args.runs,
                                args.method),
                    tests)
    results = list(results)
    results.append(("{}.compilation".format(args.name), make_time, [], []))
    test_results_xml(results).write("{}.xml".format(args.name))
    with open("{}.csv".format(args.name), "w") as f:
        f.write(test_results_csv(results))
    failed = False
    for model, _, fails, errors in results:
        if fails or errors:
            print("'{}' had fails '{}' and errors '{}'".format(model, fails, errors))
            failed = True
    if failed:
        sys.exit(-1)
