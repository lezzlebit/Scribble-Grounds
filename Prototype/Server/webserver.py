import http.server
from http.server import BaseHTTPRequestHandler
import socketserver
import json
import os
import datetime



image_path = "images/"

changelog_path = "images/changelog.txt"
changelog_dict = {}


config_dict = {}
read_config = open("config.txt").readlines()
for i in read_config:
	pair = i.split("=")
	config_dict[pair[0]] = pair[1].replace("\n","")


PORT = int(config_dict["Port"])
server_folder = config_dict["Folder"] + "-" + config_dict["Version"]

password = ""
if "Password" in config_dict:
	password = config_dict["Password"]

unauthorized_message = bytes("wrong_password", "utf-8")






def printCurrentDateTime():
	return datetime.datetime.today().strftime("%b %d at %I:%M:%S%p") + " - "


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

if not os.path.isfile(changelog_path):
	with open(changelog_path, "w") as w:
		w.write("")




# https://stackoverflow.com/questions/66514500/how-do-i-configure-a-python-server-for-post

class MyHandler(http.server.BaseHTTPRequestHandler):

	#def log_message(self, format, *args):
	#	pass


	def do_POST(self):




		self.send_header("Access-control-request-method", "POST")

		allowed = False
		if self.headers['Authorization']:
			allowed = self.headers['Authorization'] == password or password == ""

		self.send_response(200)

		if not allowed:

			print("NOT ALLOWED!")
			self.send_header("Content-length", len(unauthorized_message))
			self.send_header("Content-type", "text/plain")
			self.end_headers()
			self.wfile.write(unauthorized_message)
			self.send_response(401)

			return

		if self.headers['Content-length']:
			content_length = int(self.headers['Content-length'])
			content_type = self.headers['Content-Type']
			content_name = self.headers['Content-Name']

			saved = self.rfile.read(content_length)


			if content_type == "image/png":




				directory_path = getPathOnly(image_path + content_name)
				if not os.path.isdir(directory_path):
					os.mkdir(directory_path)

				updateLog(content_name)
				with open(image_path + content_name, "wb") as w:
					w.write(saved)

				print(printCurrentDateTime() + "Received " + content_name)

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

				print(printCurrentDateTime() + "Sending " + filename)

				self.send_header('Content-name',filename)
				self.send_header('Content-type','image/png')
				self.send_header('Content-length',len(content))
				self.end_headers()

				
				self.wfile.write(content)
				

	def do_GET(self):

		


		allowed = False
		if self.headers['Authorization']:
			allowed = self.headers['Authorization'] == password or password == ""

		self.send_response(200)

		if not allowed:

			print("NOT ALLOWED!")
			self.send_header("Content-length", len(unauthorized_message))
			self.send_header("Content-type", "text/plain")
			self.end_headers()
			self.wfile.write(unauthorized_message)

			return

		
		changelogfile = open(changelog_path).read()
		changelogfile += "\nMotd:" + config_dict["Motd"]


		content_length = int(self.headers['Content-Length'])
		content_type = self.headers['Content-Type']
		content_name = self.headers['Content-Name']

		recieved = self.rfile.read(content_length)
		message = recieved.decode("utf-8")

		check_response = "graffiti_server_online/" + server_folder

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

with socketserver.ThreadingTCPServer(("127.0.0.1", PORT), Handler) as httpd:
	print("Serving at port " + str(PORT))
	httpd.serve_forever()