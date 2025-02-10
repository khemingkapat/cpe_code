Data dcd     10, 12, 8, 1, 5, 7, 11, 6, 8
movs R12, #9; size of array at r12
ldr  R0, =Data; address of first element
mov  r1, r0; left
sub  r2, r12, #1
lsl  r2, r2, #2
add  r2, r1, r2; right
bl   QCKS
end

	QCKS sub     r10, r1, #0x200
	lsr  r10, r10, #2
	sub  r11, r2, #0x200
	lsr  r11, r11, #2

	cmp r1, r2; cmp left and right
	bge ENDF

	stmfd sp!, {r1, r2, lr}

	bl PART

	sub r2, r3, #4
	bl  QCKS

	ldmfd sp!, {r1, r2}
	add   r1, r3, #4
	bl    QCKS
	ldmfd sp!, {pc}

	PART ldr     r4, [r1]; pivot element
	mov  r5, r1; i = left
	add  r6, r2, #4; j = right +1

	LPIJ cmp     r5, r6; cmp i and j
	bge  PEND

	LPII add     r5, r5, #4; preincrement
	ldr  r7, [r5]

	cmp r4, r7; compare pivot to element in current index of i
	ble LPJJ

	cmp r5, r2; compare i to right
	bgt LPJJ
	b   LPII

	LPJJ sub     r6, r6, #4; predecrement
	ldr  r7, [r6]

	cmp r4, r7; compare pivot to element in current index of j
	bge IJED

	cmp r5, r1; compare j to left
	blt IJED
	b   LPJJ

	IJED cmp     r5, r6; cmp i and j
	bge  PEND

	ldr r8, [r5]
	ldr r9, [r6]
	str r9, [r5]
	str r8, [r6]
	b   LPIJ

	PEND ldr     r8, [r1]
	ldr  r9, [r6]
	str  r9, [r1]
	str  r8, [r6]

	mov r3, r6
	mov pc, lr

	ENDF mov     pc, lr
