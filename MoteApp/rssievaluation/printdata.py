import sys
import stoch
import csvparser

# TODO: - ausgabe weiter aufdroeseln (zb nach nodes)?
#       - ausgabe von boxplots per matplotlib?

def printlistevaluation(l, trim=0.2, upperquant=0.75, lowerquant=0.25):
    print "data:\n", l
    print "sorted:\n", sorted(l)
    print "#values:", len(l)
    print "minimum:", min(l)
    print "maximum:", max(l)
    print "range:", stoch.datarange(l)
    print "sum:", stoch.sum(l)
    print "mean:", stoch.mean(l)
    print trim, "trimmed mean:", stoch.trimmedmean(l, trim)
    print "median:", stoch.median(l)
    print upperquant, "quantile:", stoch.quantile(l, upperquant)
    print lowerquant, "quantile:", stoch.quantile(l, lowerquant)
    print "IQR:", stoch.interquartilerange(l)
    print "quantile coefficient:", stoch.quantilecoef(l)
    print "biggest normal value:", stoch.biggestnormal(l)
    print "smallest normal value:", stoch.smallestnormal(l)
    print "variance:", stoch.variance(l)
    print "standard deviation:", stoch.standarddeviation(l)
    print "coefficient of variation:", stoch.coefficientofvariation(l)

if len(sys.argv) <= 1:    
    print "Please enter CSV file to be evaluated as command line option."
    sys.exit(1)
else:
    data = csvparser.getdictfromcsv(sys.argv[1])

for i in range(min(csvparser.listfromkeyvalues(data, 'series')),
               max(csvparser.listfromkeyvalues(data, 'series'))+1):
    tmp = csvparser.listfromkeyvalues(data, 'rssi', series=i)
    if tmp:
        print "Series", i
        printlistevaluation(tmp)
        print 