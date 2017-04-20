import sys
from PIL import Image

def convert_image_to_mif(filename,outputname):
	im = Image.open(filename, 'r')
	pixel_values = list(im.getdata())
	print pixel_values
	print len(pixel_values)

	# Create a .mif file to write to 
	f = open(outputname, 'w')

	included_values = ['000000','550055','ff00ff','5500aa','aa00ff','aa00aa','0000ff','aa55aa','5500ff','aa55ff','aaaaff','0000aa','000055','5555ff','5555aa','0055ff','0055aa','00ffff']

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

	hex_values = list()

	values_string = ''

	address_number = 0

	for four_tuple in pixel_values:
		#print four_tuple
		hex_value = '%02x%02x%02x' % (four_tuple[0], four_tuple[1], four_tuple[2])

		if hex_value not in hex_values:
			values_string = values_string + "'" + hex_value + "'" + ','

		hex_values.append(hex_value)

		hex_location = included_values.index(hex_value)

		file_string = '\t' + format(address_number,'03x') + ' : ' + format(hex_location,'06x') + ';\n'

		f.write(file_string)

		address_number = address_number + 1

	print 
	print values_string
	print len(values_string)/7
	#print hex_values
	#print len(hex_values)
	#print string
	#print "\n"
	#print pixels
	f.write('END')
	f.close()

if __name__ == '__main__':
	args = sys.argv
	if(len(args) != 3):
		raise Exception("Please enter arguments: input_image_filename output_mif_filename.")
	filename = args[1]
	outputname = args[2]
	print filename
	convert_image_to_mif(filename, outputname)