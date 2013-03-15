import sys
import stoch
import csvparser

# TODO: - ausgabe weiter aufdroeseln (zb nach nodes)?

def printlistevaluation(l, trim=0.2, upperquant=0.75, lowerquant=0.25, verbose=False):
    if verbose:
        print "data:\n", l
        print "sorted:\n", sorted(l)
        print "sum:", stoch.sum(l)
    print "#values:", len(l)
    print "minimum:", min(l)
    print "maximum:", max(l)
    print "range:", stoch.datarange(l)
    print "mean:", stoch.mean(l)
    print trim, "trimmed mean:", stoch.trimmedmean(l, trim)
    print "median:", stoch.median(l)
    print upperquant, "quantile:", stoch.quantile(l, upperquant)
    print lowerquant, "quantile:", stoch.quantile(l, lowerquant)
    print "IQR:", stoch.interquartilerange(l)
    print "quantile coefficient:", stoch.quartilecoef(l)
    print "biggest normal value:", stoch.biggestnormal(l)
    print "smallest normal value:", stoch.smallestnormal(l)
    print "variance:", stoch.variance(l)
    print "standard deviation:", stoch.standarddeviation(l)
    print "coefficient of variation:", stoch.coefficientofvariation(l)

v = False
if "-v" in sys.argv:
    sys.argv.remove("-v")
    v = True

p = False
if "-p" in sys.argv:
    sys.argv.remove("-p")
    p = True

if len(sys.argv) != 2:
    print "Please enter exactly one CSV file to be evaluated."
    sys.exit(1)

doPlots = False
if p:
    try:
        import matplotlib.pyplot as mpl
    except ImportError:
        print "Install matplotlib to display Boxplots."    
    else:
        doPlots = True
        fg = mpl.figure()
        plots_data = []


data = csvparser.getdictfromcsv(sys.argv[1])
for i in range(min(csvparser.listfromkeyvalues(data, 'series')),
               max(csvparser.listfromkeyvalues(data, 'series'))+1):
    tmp = csvparser.listfromkeyvalues(data, 'rssi', series=i)
    if tmp:
        print "Set", i
        printlistevaluation(tmp, verbose=v)
        print
        if doPlots: plots_data.append(tmp)

if doPlots:
    fg.add_subplot(111).boxplot(plots_data)
    mpl.show()
