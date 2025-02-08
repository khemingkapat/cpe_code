	; Data section (array definition)

Data DCD     10, 12, 8, 1, 5, 7, 11, 6, 8

	;    Main program
	MOVS R12, #9
	LDR  R0, =Data
	MOV  R1, #0

	;    outer loop
	LP01 CMP     R1, R12
	BGE  ENDD

	MOV R3, R0; min index
	MOV R4, R0; current index
	MOV R5, R1; j = i, so we could compare to n

	BL LPMN; loop min

	;   Swap the elements at R0 (i) and R3 (min_index)
	LDR R11, [R0]
	LDR R2, [R3]
	STR R2, [R0]
	STR R11, [R3]

	ADD R0, R0, #4; i = i+1
	ADD R1, R1, #1; next index
	B   LP01; go to outer loop without link

	;    loop for find minimum
	LPMN ADD     R4, R4, #4; next index, we dont need to compare to itself
	ADD  R5, R5, #1; j=j+1
	CMP  R5, R12; cmp j, n
	BGE  LPMN_END; check if not = n

	LDR R6, [R3]; r6 is value in min idx
	LDR R7, [R4]; r7 is value in current index
	CMP R7, R6; cmp current and min
	BLT ASMN; if current is less than min
	B   LPMN; go back to loop

	ASMN MOV     R3, R4; update the min index
	B    LPMN; go to loop

	LPMN_END MOV     PC, LR ; return to current outer loop
	ENDD END; idk why it needs this but if only put end at bge on outer loop, it breaks
