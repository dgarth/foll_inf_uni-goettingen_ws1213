import re, sys

if len(sys.argv) <= 1:
    print "Please enter files to be converted as command line options."
    sys.exit(1)

filenames = sys.argv[1:]
regexstring = r"Measure #(?P<count>\d{1,4}) from set (?P<set>\d{1,2}) \[(?P<from>\d{1,2}) --> (?P<to>\d{1,2})\], RSSI = (?P<rssi>-{0,1}\d{1,3})"
regex = re.compile(regexstring)

for filename in filenames:
    f = open(filename)
    w = open(filename+".converted.csv", "w")
    for line in f:
        result = regex.match(line).groupdict()
        w.write("{set},{count},{from},{to},{rssi}\n".format(**result))