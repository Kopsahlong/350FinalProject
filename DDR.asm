.text
main:
addi $1, $0, 0 // reset clockCycle to 0
addi $2, $0, noKeyInput // reset lastKeyInput to noKeyInput
addi $3, $0, 0 // reset counterSinceLastArrow to 0
addi $4, $0, 0 // reset randomNumber to 0
addi $5, $0, 0 // reset score to 0


stateWait:
addi $1, $1, 1 // increment clockCycle by 1, count to numClockCyclesUntilStateChange
addi $10, $0, numClockCyclesUntilStateChange
blt $10, $1, stateChange // branch if clockCycle>numClockCyclesUntilStateChange -> stateChange
addi $10, $0, noKeyInput 
bne $2, $10, keyPressed //branch if lastKeyInput != noKeyInput -> keyPressed
j stateWait


keyPressed:
checkIfExcellent:
addi $10, $0, indexPtr
lw $11, excellentIndex($10) // load arrowInfo from excellentIndex
bne $11, $2, checkIfGood1 // if lastKeyInput != arrowInfo from excellentIndex --> check good1
j incrementScore2 // else score += 2
checkIfGood1:
addi $10, $0, indexPtr
lw $11, goodIndex1($10) // load arrowInfo from goodIndex1
bne $11, $2, checkIfGood2 // if lastKeyInput != arrowInfo from goodIndex1 --> check good2
j incrementScore1 // else score += 1
checkIfGood2:
addi $10, $0, indexPtr
lw $11, goodIndex2($10) // load arrowInfo from goodIndex2
bne $11, $2, decrementScore2  // if lastKeyInput != arrowInfo from goodIndex2 --> score -= 2
j incrementScore1 // else core += 1
incrementScore2:
addi $5, $5, 2
j keyPressedStateWait
incrementScore1:
addi $5, $5, 1
j keyPressedStateWait
decrementScore2:
addi $5, $5, -2
j keyPressedStateWait
keyPressedStateWait:
addi $1, $1, 1 // increment clockCycle by 1, count to numClockCyclesUntilStateChange
addi $10, $0, numClockCyclesUntilStateChange
blt $10, $1, stateChange // branch if clockCycle>numClockCyclesUntilStateChange -> stateChange
j keyPressedStateWait



stateChange:
addi $1, $0, 0 // reset clockCycle to 0
addi $2, $0, noKeyInput // reset lastKeyInput to noKeyInput
addi $10, $0, indexPtr // shift all arrowInstructions up, starting at indexPtr
stateChangeLoop:
lw $11, 0($10) // load from $10
addi $10, $10, 1 // increment $10
sw $11, 0($10) // store to register $10, done with $11
addi $11, $0, indexPtr
addi $11, $11, numStates // set $11 = max index to set
bne $10, $11, stateChangeLoop // if $10 is max index to set, continue to --> generateRandomNumber --> feedNewArrow
generateRandomNumber: 
lw $10, 555($0) // load in constant a - should be a large number
lw $11, 556($0) // load in constant b - should be a large number, but not large enough to cause an overflow
mul $12, $4, $10 // multiply previous random number by value a
add $13, $12, $11 // add value b //TODO fix nick's addi instructions and figure out this algorithm and dmem addressing
lw $10, 8($0) // read in mod value // I changed this from addi to lw, is that what you meant? -A
div $14, $13, $10  // divide by the mod value
mul $11, $10, $14 // multiply result by mod value
sub $4, $13, $11 // subtract out multiplied value to take the real mod --> store in randomNumber
lw $10, 5($0) // make check value // I changed this from addi to lw, is that what you meant? -A
blt $10, $4, generateRandomNumber // if the value is not within scope, get another one.
feedNewArrow:
addi $3, $3, 1 // increment counterSinceLastArrow
addi $10, $0, numStatesUntilNewArrow // store numStatesUntilNewArrow in temp0
blt $3, $10, feedNOArrow // if counterSinceLastArrow < numStatesUntilNewArrow, don't feed a new arrow --> feedNOArrow
add $3, $0, $0 // reset counterSinceLastArrow to 0
sw $4, indexPtr($0) // store randomNumber in memory
j stateWait // done changing state -> jump back to stateWait
feedNOArrow:
sw $0, indexPtr($0)
j stateWait


.data
indexPtr: .word -1056
arrowInfoPtr: .word -1248

numClockCyclesUntilStateChange: .word 50000
numStatesUntilNewArrow: .word 5
numStates: .word 30
noKeyInput: .word 7

goodIndex1: .word 29
excellentIndex: .word 28
goodIndex2: .word 27