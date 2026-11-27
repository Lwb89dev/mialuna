#!/usr/bin/env python3
"""Fails when an APK or app bundle gives away who built it.

Looks inside every file of the package for:

* a project address that is not the neutral one of tool/build_release.sh;
* the home directory and the name of whoever is running this;
* any word listed, one per line, in tool/private_words.txt (not committed).

Run it on the machine that built the package, before publishing it:

    tool/check_release.py build/release/mialuna-1.2.3.apk
"""

import getpass
import gzip
import pathlib
import re
import sys
import zipfile

NEUTRAL = b"file:///mnt/mialuna/"
REGISTRANT = re.compile(rb"file:///[ -~]*?dart_plugin_registrant\.dart")


def private_words():
    home = str(pathlib.Path.home())
    user = getpass.getuser()
    # The home directory, also as tools that flatten paths into a name write it.
    words = {home, home.replace("/", "-")}
    # A user name is often a surname and some digits: look for the surname.
    bare = user.rstrip("0123456789")
    if len(bare) >= 5:
        words.add(bare)
    extra = pathlib.Path(__file__).with_name("private_words.txt")
    if extra.exists():
        words.update(line.strip() for line in extra.read_text().splitlines())
    return sorted(w for w in words if len(w) >= 4)


def contents(path):
    # The raw file too: the signing block belongs to no entry.
    yield "(the package itself)", path.read_bytes()
    with zipfile.ZipFile(path) as package:
        for entry in package.infolist():
            data = package.read(entry)
            yield entry.filename, data
            if data[:2] == b"\x1f\x8b":
                yield entry.filename + " (unzipped)", gzip.decompress(data)


def problems(path, words):
    patterns = [
        (word, re.compile(re.escape(word.encode(encoding)), re.IGNORECASE))
        for word in words
        for encoding in ("utf-8", "utf-16-le")
    ]
    found = set()
    for name, data in contents(path):
        for address in REGISTRANT.findall(data):
            if not address.startswith(NEUTRAL):
                found.add(f"{name}: built from {address.decode()}")
        for word, pattern in patterns:
            if pattern.search(data):
                found.add(f"{name}: contains '{word}'")
    return sorted(found)


def main(arguments):
    if not arguments:
        print(__doc__, file=sys.stderr)
        return 2
    words = private_words()
    failed = False
    for argument in arguments:
        found = problems(pathlib.Path(argument), words)
        if found:
            failed = True
            print(f"DO NOT PUBLISH {argument}:", file=sys.stderr)
            for line in found:
                print(f"  {line}", file=sys.stderr)
        else:
            print(f"{argument}: nothing private found")
    return 1 if failed else 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
