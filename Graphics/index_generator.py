import sys
from PIL import Image

def create_index_file(outputname):

	# Create a .mif file to write to 
	f = open(outputname, 'w')

	included_values = ['000000','550055','ff00ff','5500aa','aa00ff','aa00aa','0000ff','aa55aa','5500ff','aa55ff','aaaaff','0000aa','000055','5555ff','5555aa','0055ff','0055aa','00ffff','000080','0054ff','0052ff','0057ff','4040bf','4040bf','0000ad','4040bf','5600ff','0000bf','00009f','5400ff','5600ff','5600ff','000040','0000bf','0000b6','5400ff','5300ff','8080ff','0000bf','4040bf','5400ff','8080ff','5300ff','5300ff','0000bf','8080ff','800080','800080','5600ff','8000ff','4040bf','5600ff','4040bf','4040ff','5300ff','0000bf','800080','5600ff','8000ff','5400ff','5600ff','8000ff','bf40ff','5300ff','0000bf','800080','8000ff','6600ff','8000ff','bf40ff','5300ff','0000bf','800080','8000ff','6600ff','5700ff','5400ff','8000ff','bf40ff','5300ff','0000bf','800080','5400ff','8000ff','6600ff','5600ff','8000ff','bf40ff','5300ff','800080','5600ff','8000ff','6600ff','5600ff','8000ff','bf40ff','5700ff','8080ff','8000ff','5600ff','8000ff','6600ff','8000ff','bf40ff','6600ff','bf40bf','5400ff','5400ff','8000ff','6600ff','5300ff','ab00ff','8000ff','5100ff','5700ff','5300ff','9900ff','bf40bf','ab00ff','5700ff','5700ff','5300ff','800080','9900ff','5300ff','a900ff','8000ff','8000ff','5900a6','5800ff','a900ff','ab00ff','9900ff','ac00ff','8000ff','8000ff','8000ff','9900ff','5100ff','a900ff','a900ff','8000ff','8000ff','9900ff','a800ff','ab00ff','8000ff','bf40bf','5100ae','9900ff','a800ff','ab00ff','8000ff','bf40bf','ae00ff','9900ff','a400ff','9900ff','8000ff','9900ff','ac00ff','9900ff','ac00ff','9900ff','ac00ff','a800ff','a800ff',
'000000','000055','0055ff','0055aa','00ffff','0000ff','000080','0054ff','0052ff','5555aa','0000aa','5500aa','5500ff','ff00ff','aa00ff','550055','aa55ff','aa00aa','001f5f','001f7f','003f7f','001f9f','003f9f','003fbf','ffffff','001f3f','001f1f','00001f','3f7f9f','5f9fdf','003f5f','7f9fdf','bfffff','7fbfdf','1f5f9f','1f3f7f','7fbfff','3f7fbf','9fbfff','9fdfff','5f9fbf','1f5f7f','1f5fbf','3f5fbf','3f7fdf','00003f','5f7fbf','3f5f9f','7f9fff','5f7fdf','bfdfff','3f9fdf','005f9f','1f3f5f','3f5f7f','7fdfff','007fbf','5fbfff','1f7fbf','5f7f9f','dfffff','9fbfdf','7fdfdf','1f7f9f','9fdfdf','005fbf','3f9fbf','7f9fbf','005f7f','7f7fdf','7f7fbf','9f9fdf','5f5f9f','9f9fff','bf9fdf','9f9fbf','df9fdf','dfbfdf','bf9fff','bfbfff','bfbfdf','dfbfff','df9fff','5f5fbf','9f7fdf','9f7fbf','bf9fbf','1f3fbf','5f7fff','bf7fbf','df9fbf','ff9fdf','1f3f9f','1f7fdf','7f7f9f','5f9fff','7f5f9f','1f1f5f','5f5f7f','1f1f3f','3f3f5f','7f5f7f','5f3f7f','5f3f5f','9f5f9f','9f5f7f','bf7f9f','bf5f9f','3f3f7f','9fffff','7f7f7f','9f3f7f','7f1f5f','3f1f3f','9f7f9f','7f3f7f','3f1f5f','005fdf','007fdf','3f9fff','1f9fdf','5fbfdf','009fdf','1f3f3f','dfdfff','ffdfff','1f9fff','1f003f','007f9f','1fbfff','7f3f5f','9f5f5f','7f5f5f','bf5f7f','3f5f5f','3fbfff','5fdfff','003f3f','5f1f5f','009fff','1f7fff','1f9fbf','007fff','7fffff','009fbf','5fbfbf','3fbfdf','5fffff','5fdfdf','1fbfdf','3fdfff','3f7f7f','bfdfdf','003fdf','005fff','3f7fff','1f5fff','003fff','7f9f9f','9fbfbf','dfdfdf','7fbfbf','bfbfbf','5f7f7f','001fbf','3f5fdf','1f5fdf','9f9f9f','5f5f5f','3f3f3f','001f00','1f3f1f']

	width_string = 'WIDTH = 24;\n'
	depth_string = 'DEPTH = 256;\n'
	address_radix_string = 'ADDRESS_RADIX = HEX;\n'
	data_radix_string = 'DATA_RADIX = HEX;\n'

	f.write(width_string)
	f.write(depth_string)
	f.write(address_radix_string)
	f.write(data_radix_string)
	f.write('CONTENT BEGIN\n\n')

	address_number = 0

	for value in included_values:

		file_string = ''
		file_string = '\t' + format(address_number,'03x')+ ' : ' + value[::-1]  + ';\n'
		f.write(file_string)

		address_number = address_number + 1

	f.write('END;')
	f.close()

if __name__ == '__main__':
	args = sys.argv
	create_index_file(args[1])