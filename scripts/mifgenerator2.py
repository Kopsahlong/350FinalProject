import sys
from PIL import Image

def convert_image_to_mif(filename,outputname):
	im = Image.open(filename, 'r')
	pixel_values = list(im.getdata())
	print pixel_values
	print len(pixel_values)

	# Create a .mif file to write to 
	f = open(outputname, 'w')


	width = 8 # The size of memory in words
	depth = len(pixel_values) # Amount of addresses contained

	width_string = 'WIDTH = '+str(width)+';\n'
	depth_string = 'DEPTH = '+str(width)+';\n'
	address_radix_string = 'ADDRESS_RADIX = HEX;\n'
	data_radix_string = 'DATA_RADIX = HEX;\n'

	f.write(width_string)
	f.write(depth_string)
	f.write(address_radix_string)
	f.write(data_radix_string)
	f.write('CONTENT BEGIN\n\n')

	address_number = 0

	for pixel in pixel_values:
		pixel_string = str(hex(address_number))[2:] + ' : ' + format(pixel, '06x') + "\n"
		f.write(pixel_string)
		address_number = address_number + 1 



	f.write('END')
	f.close()

	'''WIDTH = 8;
		DEPTH = 225;
		ADDRESS_RADIX = HEX;
		DATA_RADIX = HEX;
		CONTENT BEGIN'''
if __name__ == '__main__':
	args = sys.argv
	if(len(args) != 3):
		raise Exception("Please enter arguments: input_image_filename output_mif_filename.")
	filename = args[1]
	outputname = args[2]
	print filename
	convert_image_to_mif(filename, outputname)