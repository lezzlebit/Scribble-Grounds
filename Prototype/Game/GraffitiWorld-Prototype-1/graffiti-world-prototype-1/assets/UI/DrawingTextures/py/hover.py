
import os
import PIL
from PIL import Image, ImagePalette




def makefordir(dir):
	all_textures = os.listdir(dir)
	for i in all_textures:
		if ".png" in i.lower() and not (".png.import" in i.lower()):
			print(i)

			og = Image.open(dir + i)
			bg = Image.new("RGB", (og.width,og.height))
			bg.paste((200, 200, 200), (0, 0, bg.width, bg.height))
			bg.paste(og, (0,0), mask = og)
			bg.save("../hover/" + i)

makefordir("../")
makefordir("../brushes/")