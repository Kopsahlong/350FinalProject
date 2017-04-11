.text
main: addi $1, $0, 1999
noop
halt
sw $18, -640($7)
bne $3, $2, middle
addi $6, $1, 65535
addi $7, $1, -65536

middle:
sub $8, $2, $1
and $9, $2, $1
j quit
dead: addi $7, $0, 0x0000DF00
quit:
halt

.data
wow: .word 0x0000B504
mystring: .string ASDASDASDASDASDASD
var: .char Z
label: .char A
heapsize: .word 0x00000000
myheap: .word 0x00000000