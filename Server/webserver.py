import http.server
from http.server import BaseHTTPRequestHandler
import socketserver
import json
import os
import datetime



image_path = "images/"

changelog_path = "images/changelog.txt"
changelog_dict = {}


def get_config_dict():
	return_config_dict = {}
	read_config = open("config.txt").readlines()
	for i in read_config:
		pair = i.split("=")
		return_config_dict[pair[0]] = pair[1].replace("\n","")
	return return_config_dict

config_dict = get_config_dict()


PORT = int(config_dict["Port"])
server_folder = config_dict["Folder"]
compatibility_version = config_dict["Compatibility"]

world_file_path = ""
if "World" in config_dict:
	world_file_path = config_dict["World"]

password = ""
if "Password" in config_dict:
	if config_dict["Password"]:
		password = config_dict["Password"]

denied_unknown_message = bytes("Denied", "utf-8")
incompatible_version_message = bytes("Wrong Version", "utf-8")
wrong_password_message = bytes("Wrong Password", "utf-8")






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

def trim_text(inp):
	return inp.replace("\n","").replace(" ","")


def validate_password(self):

	reason_denied = denied_unknown_message
	allowed = False
	if self.headers['Authorization']:
		authorization_pair = self.headers['Authorization'].split(",")

		if len(authorization_pair) > 0:

			recieved_password = trim_text(authorization_pair[0])
			recieved_compatibility = trim_text(authorization_pair[1])

			if recieved_compatibility == compatibility_version:
				if len(password) > 0:
					if recieved_password == password:
						allowed = True
					else:
						allowed = False
						reason_denied = wrong_password_message
				else:
					allowed = True
			else:
				reason_denied = incompatible_version_message
		else:
			allowed = False

	if not allowed:
		print(password)
		self.send_header("Content-length", len(reason_denied))
		self.send_header("Content-type", "text/plain")
		self.end_headers()
		self.wfile.write(reason_denied)
		self.send_response(401)

		return False
	return True


if not os.path.isdir(image_path):
	os.mkdir(image_path)

if not os.path.isfile(changelog_path):
	with open(changelog_path, "w") as w:
		w.write("")



class footstep:
	position = ""
	time = 0.0
	color = ""

footsteps = []


footstep_delete_timer = 25

def store_footsteps(all):
	for i in all.split("\n"):
		values = i.split("/")

		if len(values) == 3:

			new_footstep = footstep()
			new_footstep.position = values[0]
			new_footstep.time = float(values[1])
			new_footstep.color = values[2]

			footsteps.append(new_footstep)

	footsteps_to_delete = []
	for i in footsteps:
		current_time = datetime.datetime.now().timestamp()
		if (current_time - footstep_delete_timer) > i.time:
			footsteps_to_delete.append(i)
	for i in footsteps_to_delete:
		footsteps.remove(i)

def send_footsteps():


	all = ""
	for i in footsteps:
		all += i.position + "/" + str(i.time) + "/" + i.color + "\n"
	return all



# https://stackoverflow.com/questions/66514500/how-do-i-configure-a-python-server-for-post

class MyHandler(http.server.BaseHTTPRequestHandler):

	def log_message(self, format, *args):
		pass


	def do_POST(self):



		self.send_response(200)
		self.send_header("Access-control-request-method", "POST")

		if not validate_password(self):
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

				if ".glb" in filename:
					content = open(filename, "rb").read()
					self.send_header('Content-type','model/gltf-binary')
				else:
					content = open(image_path + filename, "rb").read()
					self.send_header('Content-type','image/png')

				

				print(printCurrentDateTime() + "Sending " + filename)

				self.send_header('Content-name',filename)
				self.send_header('Content-length',len(content))
				self.end_headers()

				
				self.wfile.write(content)
			elif content_type == "text/csv":

				store_footsteps(saved.decode("utf-8"))
				content = bytes(send_footsteps(), "utf-8")
				if len(content) == 0:
					content = bytes("no footsteps", "utf-8")
				self.send_header('Content-type','text/csv')
				self.send_header('Content-length',len(content))
				self.end_headers()


				self.wfile.write(content)
				

	def do_GET(self):

		
		self.send_response(200)

		if not validate_password(self):
			return

		
		changelogfile = open(changelog_path).read()
		changelogfile += "\nMotd:" + get_config_dict()["Motd"]

		content_length = int(self.headers['Content-Length'])
		content_type = self.headers['Content-Type']
		content_name = self.headers['Content-Name']

		recieved = self.rfile.read(content_length)
		message = recieved.decode("utf-8")

		check_response = "scribble_server_online/" + server_folder
		if world_file_path != "": check_response += "/" + world_file_path

		content = ""
		if message == "retrieve_drawings_list":
			content = bytes(changelogfile, "utf-8")
		if message == "ping_scribble_server":
			content = bytes(check_response, "utf-8")

		self.send_header("Content-length", len(content))
		self.send_header("Content-type", "text/plain")
		self.send_header("Access-control-request-method", "GET")
		self.end_headers()

		self.wfile.write(content)



Handler = MyHandler


# https://www.digitalocean.com/community/tutorials/python-simplehttpserver-http-server

with socketserver.ThreadingTCPServer(("", PORT), Handler) as httpd:
	print("Serving at port " + str(PORT))
	httpd.serve_forever()