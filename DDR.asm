.text
main:
addi $1, $0, 0 // reset clockCycle to 0
addi $2, $0, noKeyInput // reset lastKeyInput to noKeyInput
addi $3, $0, 0 // reset counterSinceLastArrow to 0
addi $4, $0, 0 // reset randomNumber to 0
addi $5, $0, 0 // reset score to 0
addi $6, $0, 0 // reset screenIndexReg1 to 0's
addi $7, $0, 0 // reset screenIndexReg2 to 0's
addi $8, $0, 0 // reset screenIndexReg3 to 0's
addi $9, $0, 0 // reset goodBad to 0


stateWait:
addi $1, $1, 1 // increment clockCycle by 1, count to numClockCyclesUntilStateChange
addi $10, $0, numClockCyclesUntilStateChange
sll $10, $10, 20
blt $10, $1, stateChange // branch if clockCycle>numClockCyclesUntilStateChange -> stateChange
addi $10, $0, noKeyInput 
bne $2, $10, keyPressed //branch if lastKeyInput != noKeyInput -> keyPressed
j stateWait


keyPressed:
addi $10, $0, 7 // temp $10 to be used as a mask to select least significant 3 bits
sra $20, $8, 18
and $20, $20, $10 // store 3 bit goodIndex1 value in $20
sra $21, $8, 15
and $21, $21, $10 // store 3 bit excellentIndex value in $21
sra $22, $8, 12
and $22, $22, $10 // store 3 bit goodIndex2 value in $22
checkIfExcellent:
bne $21, $2, checkIfGood1 // if lastKeyInput != arrowInfo from excellentIndex --> check good1
j incrementScore2 // else score += 2
checkIfGood1:
bne $20, $2, checkIfGood2 // if lastKeyInput != arrowInfo from goodIndex1 --> check good2
j incrementScore1 // else score += 1
checkIfGood2:
bne $22, $2, decrementScore2  // if lastKeyInput != arrowInfo from goodIndex2 --> score -= 2
j incrementScore1 // else score += 1
incrementScore2:
addi $5, $5, 2
addi $9, $0, 3 // store 11 in goodBad register $9
j keyPressedStateWait
incrementScore1:
addi $5, $5, 1
addi $9, $0, 2 // store 10 in goodBad register $9
j keyPressedStateWait
decrementScore2:
addi $5, $5, -2
addi $9, $0, 1 // store 01 in goodBad register $9
j keyPressedStateWait
keyPressedStateWait:
addi $1, $1, 1 // increment clockCycle by 1, count to numClockCyclesUntilStateChange
addi $10, $0, numClockCyclesUntilStateChange
sll $10, $10, 20
blt $10, $1, stateChange // branch if clockCycle>numClockCyclesUntilStateChange -> stateChange
noop // trying to make this loop same # of clock cycles as stateWait loop
noop // trying to make this loop same # of clock cycles as stateWait loop
j keyPressedStateWait



stateChange:
addi $1, $0, 0 // reset clockCycle to 0
addi $2, $0, noKeyInput // reset lastKeyInput to noKeyInput
addi $9, $0, 0 // reset goodBad register to 00
shiftIndexes:
sll $8, $8, 3 // shift register $8 left 3
addi $10, $0, 7 // store 00000000000000000000000000000111 in temp $10 as mask
sra $11, $7, 27 // shift in19 to lower 3 bits of $11
and $11, $11, $10 // mask $11 to select lower 3 bits
or $8, $8, $11 // insert lower 3 bits of $11 into $8
sll $7, $7, 3 // shift register $7 left 3
sra $11, $6, 27 // shift in9 to lower 3 bits of $11
and $11, $11, $10 // mask $11 to select lower 3 bits
or $7, $7, $11 // insert lower 3 bits of $11 into $7
sll $6, $6, 3 // shift register $6 left 3
generateRandomNumber: 
addi $10, $0, 33 // load in constant a - should be a large number
addi $11, $0, 213 // load in constant b - should be a large number, but not large enough to cause an overflow
mul $12, $4, $10 // multiply previous random number by value a
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
add $13, $12, $11 // add value b 
addi $10, $0, 251 // read in mod value // I changed this from addi to lw, is that what you meant? -A
div $14, $13, $10  // divide by the mod value
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
mul $11, $10, $14 // multiply result by mod value
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
noop
sub $14, $13, $11 // subtract out multiplied value to take the real mod --> store in randomNumber
sra $4, $14, 1
addi $10, $0, 6 // make check value 
addi $11, $0, 7
and $12, $4, $11
blt $10, $12, generateRandomNumber // if the value is not within scope, get another one.
feedNewArrow:
addi $3, $3, 1 // increment counterSinceLastArrow
addi $10, $0, numStatesUntilNewArrow // store numStatesUntilNewArrow in temp0
blt $3, $10, feedNOArrow // if counterSinceLastArrow < numStatesUntilNewArrow, don't feed a new arrow --> feedNOArrow
add $3, $0, $0 // reset counterSinceLastArrow to 0
add $6, $6, $12 // add randomNumber from $4 to lower 3 bits of screenIndexReg1 $6
j stateWait // done changing state -> jump back to stateWait
feedNOArrow:
j stateWait // in0 will be filled with 000 due to sll shifting in 0s


.data
indexPtr: .word -1056
arrowInfoPtr: .word -1248

numClockCyclesUntilStateChange: .word 50000
numStatesUntilNewArrow: .word 20
numStates: .word 30
noKeyInput: .word 7

goodIndex1: .word 29
excellentIndex: .word 28
goodIndex2: .word 27