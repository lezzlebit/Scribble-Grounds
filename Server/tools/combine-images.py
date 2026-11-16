
import os
import PIL
from PIL import Image


dir = "../images/"

def get_all_images():

	all = []
	for i in os.listdir(dir):

		new_dir = dir + i
		if os.path.isdir(new_dir) and not os.path.isfile(new_dir):

			for j in os.listdir(new_dir):
				all.append(new_dir + "/" + j)
	return all

def get_file_name(file):
	all = file.split("/")
	return all[len(all)-1]


all_images = get_all_images()
duplicates_dictionary = {}

for i in all_images:
	name = get_file_name(i)
	if name in duplicates_dictionary:
		duplicates_dictionary[name].append(i)
	else:
		duplicates_dictionary[name] = [i]

for i in duplicates_dictionary:
	selected = duplicates_dictionary[i]
	scale_selector = Image.open(selected[0])
	
	new_image = Image.new("RGBA", (scale_selector.width,scale_selector.height),  "#00000000")

	for j in selected:
		opened_image = Image.open(j)
		print(opened_image.width)
		new_image = Image.alpha_composite(new_image, opened_image)
	new_image.save(dir + i)