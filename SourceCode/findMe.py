import glob
import sys
for file in glob.glob('*.m'):
    with open(file) as f:
        contents = f.read()
    if sys.argv[1] in contents:
        print file
