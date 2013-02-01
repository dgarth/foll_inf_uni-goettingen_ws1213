def getdictfromcsv(path):
    data = map(lambda x: [int (i) for i in x.split(',')], open(path).read().split())
    measurements = []
    for m in data:
        measurements.append({
                'series':    m[0],
                'num':       m[1],
                'receiver':  m[2],
                'sender':    m[3],
                'rssi':      m[4]
            })
    return measurements

def listfromkeyvalues(l, listkey=None, **kwargs):
    for k, v in kwargs.iteritems():
        l = filter(lambda x: x[k] == v, l)    
    return map(lambda x: x if listkey==None else x[listkey], l)

    
# --------------------------------- Tests -------------------------------------
if __name__ == "__main__":    
    test = getdictfromcsv("test/test.csv")
    for i in test:
        print i
        
    print listfromkeyvalues(test, 'series')
    print listfromkeyvalues(test, 'rssi', series=1)
    print listfromkeyvalues(test, series=1)
    print listfromkeyvalues(test, 'rssi', series=1, receiver=3)
    print listfromkeyvalues(test, series=10)
