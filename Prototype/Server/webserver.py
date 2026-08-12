import http.server
from http.server import BaseHTTPRequestHandler
import socketserver
import json
import os
import datetime

PORT = 55555
HOST = "192.168.50.72"


image_path = "images/"

changelog_path = "changelog.txt"
changelog_dict = {}


def retrieveChangelog():
	readfile = open(changelog_path).readlines()

	for i in readfile:
		pair = i.replace("\n","").split(":")
		changelog_dict.update({pair[0]:pair[1]})

def commitchangelog():
	keys = changelog_dict.keys()
	towrite = ""
	for i in keys:
		towrite += i + ":" + changelog_dict[i] + "\n"

	with open(changelog_path, "w") as f:
		f.write(towrite)

def updateLog(imagename):
	retrieveChangelog()
	timestamp_string = str(datetime.datetime.now().timestamp()).split(".")[0]
	changelog_dict.update({imagename : timestamp_string})
	commitchangelog()
	return timestamp_string

def getPathOnly(fullpath):
	segments = fullpath.split("/")
	segments = segments[:-1]
	returnpath = "/".join(segments)
	return returnpath



if not os.path.isdir(image_path):
	os.mkdir(image_path)

# https://stackoverflow.com/questions/66514500/how-do-i-configure-a-python-server-for-post

class MyHandler(BaseHTTPRequestHandler):


	#def log_message(self, format, *args):
	#	pass

	def do_POST(self):




		self.send_response(200)
		self.send_header("Access-control-request-method", "POST")

		print(self.headers)
		content_length = int(self.headers['Content-length'])
		content_type = self.headers['Content-Type']
		content_name = self.headers['Content-Name']

		print(content_type)

		saved = self.rfile.read(content_length)


		if content_type == "image/png":




			directory_path = getPathOnly(image_path + content_name)
			if not os.path.isdir(directory_path):
				os.mkdir(directory_path)

			updateLog(content_name)
			with open(image_path + content_name, "wb") as w:
				w.write(saved)

			timestamp = updateLog(content_name)

			message = content_name + ":" + timestamp
			content = bytes(message, "utf-8")

			self.send_header("Content-length", len(content))
			self.send_header('Content-type','text/plain')
			self.end_headers()

			self.wfile.write(content)

			
		elif content_type == "text/plain":

			filename = saved.decode("utf-8")

			content = open(image_path + filename, "rb").read()

			self.send_header('Content-name',filename)
			self.send_header('Content-type','image/png')
			self.send_header('Content-length',len(content))
			self.end_headers()

			
			self.wfile.write(content)
			

	def do_GET(self):
		self.send_response(200)

		changelogfile = open(changelog_path).read()


		content_length = int(self.headers['Content-Length'])
		content_type = self.headers['Content-Type']
		content_name = self.headers['Content-Name']

		recieved = self.rfile.read(content_length)
		message = recieved.decode("utf-8")

		check_response = "graffiti_server_online"

		content = ""
		if message == "retrieve_drawings_list":
			content = bytes(changelogfile, "utf-8")
		if message == "ping_graffiti_server":
			content = bytes(check_response, "utf-8")
		

		self.send_header("Content-length", len(content))
		self.send_header("Content-type", "text/plain")
		self.send_header("Access-control-request-method", "GET")
		self.end_headers()

		self.wfile.write(content)



Handler = MyHandler


# https://www.digitalocean.com/community/tutorials/python-simplehttpserver-http-server

with socketserver.TCPServer(("", PORT), Handler) as httpd:
	print("Serving at port " + str(PORT))
	httpd.serve_forever()