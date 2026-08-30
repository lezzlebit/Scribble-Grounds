import http.server
from http.server import BaseHTTPRequestHandler
import socketserver
import json
import os
import datetime


passwords_path = "validation.txt"
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
wrong_user_password_message = bytes("Wrong User Password", "utf-8")






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


def password_dictionary():
	all_passwords = []
	if os.path.isfile(passwords_path):
		all_passwords = open(passwords_path).readlines()

	password_dict = {}
	for i in all_passwords:
		validation_pair = i.split(",")
		for v in range(len(validation_pair)):
			validation_pair[v] = validation_pair[v].replace("\n","")
		if len(validation_pair) > 1:
			password_dict[validation_pair[0]] = validation_pair[1]
	return password_dict


def store_username_password(username, user_password):


	user_password = user_password.replace("\n", "")

	password_dict = password_dictionary()

	print(username)
	if len(user_password) > 1:
		if not (username in password_dict):
			password_dict[username] = user_password


	all_passwords = []
	for i in password_dict:
		all_passwords.append(i + "," + password_dict[i] + "\n")
	combined_passwords = "\n".join(all_passwords)

	with open(passwords_path, "w") as w:
		w.write(combined_passwords)


def validate_password(self, upload_password):

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

		if len(authorization_pair) >= 4 and allowed:
			if upload_password:
				store_username_password(authorization_pair[2],authorization_pair[3])
			password_dict = password_dictionary()
			pair_username = authorization_pair[2]
			pair_password = authorization_pair[3]
			if pair_username in password_dict:
				print(password_dict)
				print(pair_password)
				if password_dict[pair_username] == pair_password:
					print("yes! correct!")
				else:
					allowed = False
					reason_denied = wrong_user_password_message

			
		print(len(authorization_pair))

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

def validate_image_upload_username(self, username):
	print("tried to validate")
	username = username.split("/")[0]
	password_dict = password_dictionary()
	if username in password_dict:
		if self.headers["Authorization"]:
			print(self.headers["Authorization"])
			authorization_pair = self.headers['Authorization'].split(",")
			if len(authorization_pair) >= 4:
				if authorization_pair[3] == password_dict[username]:
					print("password successfully validated!")
				else:
					print("wrong password for image upload!")
				
			else:
				print("user tried to upload image with no password!")
		else:
			print("user tried to upload image with no authorization!")



# https://stackoverflow.com/questions/66514500/how-do-i-configure-a-python-server-for-post

class MyHandler(http.server.BaseHTTPRequestHandler):

	def log_message(self, format, *args):
		pass


	def do_POST(self):



		self.send_response(200)
		self.send_header("Access-control-request-method", "POST")

		if not validate_password(self, False):
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

				# validate_image_upload_username(self, content_name)

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

		content_length = int(self.headers['Content-Length'])
		content_type = self.headers['Content-Type']
		content_name = self.headers['Content-Name']

		recieved = self.rfile.read(content_length)

		message = recieved.decode("utf-8")

		check_ping = "ping_scribble_server"
		check_join = "join_scribble_server"

		upload_password = False
		if message == check_join: upload_password = True

		if not validate_password(self, upload_password):
			return

		
		changelogfile = open(changelog_path).read()
		changelogfile += "\nMotd:" + get_config_dict()["Motd"]




		check_response = "scribble_server_online/" + server_folder
		if world_file_path != "": check_response += "/" + world_file_path

		content = ""
		if message == "retrieve_drawings_list":
			content = bytes(changelogfile, "utf-8")
		if message == check_ping or message == check_join:
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