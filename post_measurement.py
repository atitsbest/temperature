#
# So wird in Python eine neue Messung an das WebService geschickt,
#
import json
import urllib2
 
data = {'measurement': { 'sensor':'Kl. Saal', 'value': 32100} }
data = json.dumps(data)
 
url = "http://localhost:8090/api/measurements"
 
print "Sending Request..."
req = urllib2.Request(url, data, {'Content-Type': 'application/json'})
 
f = urllib2.urlopen(req)
response = f.read()
f.close()
print "OK"

