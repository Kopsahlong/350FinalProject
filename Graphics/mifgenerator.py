import sys
from PIL import Image

def convert_image_to_mif(filename,outputname):
	im = Image.open(filename, 'r')
	pixel_values = list(im.getdata())
	#print pixel_values
	#print len(pixel_values)

	# Create a .mif file to write to 
	f = open(outputname, 'w')

	#included_values = ['0000cf','000002','000000','000004','000016','000009','00001e','000058','00002e','000059','000045','000034','00002c','000008','000023','000051','000033','00001f','000068','000067','000028','00004d','00006e','000039','00002b','00006d','00002d','000057','000078','000046','000077','000025','000061','000081','00000c','000037','00007c','000027','000066','00008c','00004c','000080','000032','000056','00006c','00008b','000050','00000b','00003d','00008a','000031','000060','000073','00009f','000054','000096','000089','00003e','000055','000065','000076','00009e','000044','000088','000038','000053','000072','00005f','0000a5','00005e','000095','000030','000087','0000ac','000036','00004f','000075','000064','00000d','000043','000094','000093','00003c','000084','00009d','00005d','0000a4','000007','000001','00004a','0000a3','00009c','00005c','00003b','000086','000071','0000ab','000085','000041','00006a','000006','00001b','000091','000092','00004b','0000a1','000040','000074','0000a2','00006b','000042','00000e','000022','000090','000035','00009a','00005b','000021','000049','000083','000048','000005','00007b','0000aa','000070','00002f','000015','00002a','00009b','000011','00008e','00008f','000099','0000a9','000047','00000a','00007a','000063','00003f','000014','00001a','000003','000052','0000a8','0000a0','000098','000079','00007f','00005a','00008d','000029','00006f','00004e','000082','0000a6','00007e','0000af','000062','0000a7','000097','000013','000069','000010','000012','000024','00001d','0000ad','0000b3','0000ae','0000b0','0000b2','000019','000018','000017','0000b4','0000b9','0000b1','0000b5','0000c4','0000b6','0000bd','0000bb','0000b7','0000c8','0000b8','0000c3','0000be','000020','0000ba','0000c7','0000c2','0000bf','000026','0000bc','0000c9','0000cb','0000c5','0000cd','0000c1','00001c','00003a','0000ca','0000c6','00007d','00000f','0000c0','0000cc','0000ff','0000d7']
	#print len(included_values);

	width = 8 # The size of memory in words
	depth = len(pixel_values) # Amount of addresses contained

	width_string = 'WIDTH = '+str(width)+';\n'
	depth_string = 'DEPTH = '+str(depth)+';\n\n'
	address_radix_string = 'ADDRESS_RADIX = HEX;\n'
	data_radix_string = 'DATA_RADIX = HEX;\n\n'

	f.write(width_string)
	f.write(depth_string)
	f.write(address_radix_string)
	f.write(data_radix_string)
	f.write('CONTENT BEGIN\n\n')

	address_number = 0

	string = ''
	for pixel in pixel_values:
		if format(pixel,'06x') in included_values: 
			hex_index = format(included_values.index(format(pixel,'06x')),'06x');
		else:
			string = string +"'"+ format(pixel,'06x') + "'"+ ','
		pixel_string = str(hex(address_number))[2:] + ' : ' + str(hex_index) + ";\n"
		f.write(pixel_string)
		address_number = address_number + 1 

	print string
	print "\n"
	#print pixels
	f.write('END')
	f.close()

	index_file = open("index.mif", 'w')
	index_file.write("WIDTH=24;\nDEPTH=256;\nADDRESS_RADIX=HEX;\nDATA_RADIX=HEX;\n\n");

	value_index = 0
	for value in included_values:
		value_string = "\t"+format(value_index, '03x') +" : " + value[::-1] +";\n"
		value_index = value_index + 1;
		index_file.write(value_string)


if __name__ == '__main__':
	args = sys.argv
	if(len(args) != 3):
		raise Exception("Please enter arguments: input_image_filename output_mif_filename.")
	filename = args[1]
	outputname = args[2]
	print filename
	convert_image_to_mif(filename, outputname)