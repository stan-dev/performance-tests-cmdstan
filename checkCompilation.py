
from cmdstan_perf_util import *
import argparse
import multiprocessing


def read_tests(filename):
    test_files = []
    with open(filename) as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#"): continue
            if ", " in line:
                model, _ = line.split(", ")
            else:
                model = line
            test_files.append(model)
    return test_files

def parse_args():
    parser = argparse.ArgumentParser(description="Try the C++ compilation of the given directories.")
    parser.add_argument("directories", nargs="*")
    parser.add_argument("--syntax-only", dest="syntax_only", action="store_true", default=False)
    parser.add_argument("-j", dest="j", action="store", type=int, default=multiprocessing.cpu_count())
    parser.add_argument("--tests-file", dest="tests", action="store", type=str, default="")
    parser.add_argument("--even-slow-models", dest="slow_models", action="store_true")
    return parser.parse_args()

if __name__ == "__main__":
    args = parse_args()

    if args.tests == "":
        models = find_files("*.stan", args.directories)
    else:
        models, _ = read_tests(args.tests)

    if not args.slow_models:
        models = filter_out_weekly_models(models)

    executables = [m[:-5] for m in models]
    delete_temporary_exe_files(executables)

    if args.syntax_only:
        os.environ["CXXFLAGS"] = os.getenv("CXXFLAGS","") + " -fsyntax-only"
        ext = ".o"
    else:
        ext = EXE_FILE_EXT

    try:
        for batch in batched(executables):
            make(batch, args.j, ext=ext, allow_failure=False)
    finally:
        delete_temporary_exe_files(executables)
