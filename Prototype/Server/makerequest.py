import requests


r = requests.get("http://98.111.128.146:55555")

if r.status_code != 0:
	print("Got code " + str(r.status_code) + "! Succeeded!")
else:
	print("Nothing returned")

