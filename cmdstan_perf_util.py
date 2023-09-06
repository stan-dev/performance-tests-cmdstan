import os
import os.path
from fnmatch import fnmatch
from difflib import SequenceMatcher
import subprocess
import platform
from time import time

def isWin():
    return platform.system().lower().startswith(
        "windows"
    ) or os.name.lower().startswith("windows")


DIR_UP = os.path.join("..","")
CURR_DIR = os.path.join(".","")
SEP_RE = "\\\\" if os.sep == "\\" else "/"
EXE_FILE_EXT = ".exe" if isWin() else ""

def find_files(pattern, dirs):
    res = []
    for pd in dirs:
        for d, _, flist in os.walk(pd):
            for f in flist:
                if fnmatch(f, pattern):
                    res.append(os.path.join(d, f))
    return res


def str_dist(target):
    def str_dist_internal(candidate):
        return SequenceMatcher(None, candidate, target).ratio()
    return str_dist_internal

def closest_string(target, candidates):
    if candidates:
        return max(candidates, key=str_dist(target))



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

def make(targets, j=8, ext=EXE_FILE_EXT, allow_failure=True):
    for i in range(len(targets)):
        prefix = ""
        if not targets[i].startswith(os.sep):
            prefix = DIR_UP
        targets[i] = prefix + targets[i] + ext
    try:
        shexec("make -i -j{} {}"
            .format(j, " ".join(targets)), wd = "cmdstan")
    except FailedCommand:
        if allow_failure:
            print("Failed to make at least some targets")
        else:
            raise

batchSize = 20 if isWin() else 200

def batched(tests):
    return [tests[i : i + batchSize] for i in range(0, len(tests), batchSize)]

def delete_temporary_exe_files(exes):
    for exe in exes:
        extensions = ["", ".hpp", ".o"]
        for ext in extensions:
            print("Removing " + exe + ext)
            if os.path.exists(exe + ext):
                os.remove(exe + ext)
