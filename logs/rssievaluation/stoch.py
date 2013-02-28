import math

def sum(data):
    return reduce(lambda x,y: x+y, data)
    
def datarange(data):
    return max(data)-min(data)

def mean(data):
    return sum(data)/float(len(data))
    
def median(data):
    data = sorted(data)
    l = len(data)
    if l%2 == 0:
        return 0.5*(data[l/2 - 1] + data[l/2])
    else:
        return data[(l + 1)/2 - 1]
 
def trimmedmean(data, a):
    data = sorted(data)
    k = int(math.floor(len(data) * a))
    return mean(data[k:-k])
    
def quantile(data, p):
    data = sorted(data)
    t = len(data) * p
    if t % 1 == 0:
        t = int(t)
        return 0.5 * (data[t-1] + data[t])
    else:
        return data[int(math.floor(t))] #ceil(t)-1
    
def variance(data):
    m = mean(data)
    return 1.0/(len(data)-1) * reduce(lambda x,y: x+y, map(lambda x: (x-m)**2, data))
    
def standarddeviation(data):
    return math.sqrt(variance(data))
    
def interquartilerange(data):
    return quantile(data, 0.75) - quantile(data, 0.25)
    
def biggestnormal(data):
    irq = interquartilerange(data)
    q = quantile(data, 0.75)
    data = filter(lambda x: x <= (q + 1.5*irq), data)
    return sorted(data, reverse=True)[0]
 
def smallestnormal(data):
    irq = interquartilerange(data)
    q = quantile(data, 0.25)
    data = filter(lambda x: x >= (q - 1.5*irq), data)
    return sorted(data)[0]
            
def empiricaldistfunc(data, k):
    return len(filter(lambda x: x <= k, data))
 
def coefficientofvariation(data):
    return standarddeviation(data)/mean(data)
    
def quartilecoef(data):
    m = median(data)
    return ((quantile(data, 0.75) - m) - (m - quantile(data, 0.25)))/float(interquartilerange(data))

    
# --------------------------------- Tests -------------------------------------    
if __name__ == "__main__":
    a = [
        46,23,51,46,65,54,80,58,54,42,52,29
    ]
        
    b = [
        145,154,154,154,154,154,154,154,162,162,162,162,162,162,162,169,169,
        169,169,169,169,169,169,175,175,175,175,175,180,180,180,180,180,180,
        180,180,180,180,180,180,180,180,180,180,180,180,180,180,180,180,184,
        184,184,184,184,184,184,184,184,184,184,184,184,184,184,184,184,184,
        184,184,184,187,187,187,187,187,187,187,187,187,187,187,187,187,187,
        189,189,189,189,189,189,189,189,189,189,189,189,189,189,189,189,189,
        190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,190,
        190
    ]

    c = [
        30,28,31,35,25,29,30,33,29
    ]

    d = [
        31,29,32,30,28,30,33,31,26
    ]

    #f = []
    #import random
    #for i in range(0,1000):
    #    f.append(int(random.gauss(100, 20)))

    datalists = [a, b, c, d]

    trim = 0.2
    quant1 = 0.25
    quant2 = 0.75

    zaehler = 0
    print 
    for l in datalists:
        zaehler = zaehler + 1
        print "Datensatz %d" % zaehler
        print "Datensatz", l
        print "geordnet:", sorted(l)
        print "Anzahl der Werte:", len(l)
        print "Minimum:", min(l)
        print "Maximum:", max(l)
        print "Spannweite:", datarange(l)
        print "Summe:", sum(l)
        print "Mittelwert:", mean(l)
        print trim, "getrimmtes Mittel:", trimmedmean(l, trim)
        print "Median:", median(l)
        print quant1, "Quantil:", quantile(l, quant1)
        print quant2, "Quantil:", quantile(l, quant2)
        print "IQR:", interquartilerange(l)
        print "Quartilskoeffizient der Schiefe:", quartilecoef(l)
        print "Groesste normale Beobachtung:", biggestnormal(l)
        print "Kleinste normale Beobachtung:", smallestnormal(l)
        print "Varianz:", variance(l)
        print "Standardabweichung:", standarddeviation(l)
        print "Variationskoeffizient:", coefficientofvariation(l)
        print 
