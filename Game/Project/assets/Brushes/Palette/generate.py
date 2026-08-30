import PIL
from PIL import Image
import os





def addzero(s):
	s = s.replace("0x","")
	if len(s) == 1:
		s = "0"+s
	return s

def hexadecimal(input):
	r = addzero(hex(input[0]))
	g = addzero(hex(input[1]))
	b = addzero(hex(input[2]))

	return (r + g + b)

iterate = 0

for file in os.listdir("."):
	name = os.path.basename(file)
	print(name)
	if ".png" in file and not ".import" in file:
		palette = Image.open(file)

		width = palette.width
		height = palette.height


		colors = []


		for y in range(height):
			for x in range(width):

				color = palette.getpixel([x, y])
				if not color in colors:
					colors.append(color)


		document = ""


		for i in colors:

			newline = ""
			iterate += 1
			if iterate > 2:
				newline = "\n"
				iterate = 0

		
			document = '"' + hexadecimal(i) + '",' + newline + document

		document = document[:-1] + "]"
		print(document)

		with open("generated/" + file.replace(".png", ".txt"), "w") as f:
			f.write(document)