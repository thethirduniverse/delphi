#@s
import httplib
conn = httplib.HTTPSConnection("www.google.com")
print conn
conn.request("GET","/")
r1 = conn.getresponse()
print r1.status, r1.reason
print r1.read()
#@e
