.arch    armv7-a
.fpu     vfpv3-d16
.eabi_attribute 28, 1
.eabi_attribute 20, 1
.eabi_attribute 21, 1
.eabi_attribute 23, 3
.eabi_attribute 24, 1
.eabi_attribute 25, 1
.eabi_attribute 26, 2
.eabi_attribute 30, 6
.eabi_attribute 34, 1
.eabi_attribute 18, 4
.file    "pipeline_02.c"
.text
.section .rodata
.align   2

.LC1:
	.ascii "%d\000"
	.align 2

.LC2:
	.ascii "Error\000"
	.align 2

.LC3:
	.ascii "A\000"
	.align 2

.LC4:
	.ascii "B\000"
	.align 2

.LC5:
	.ascii "C\000"
	.align 2

.LC6:
	.ascii "D\000"
	.align 2

.LC7:
	.ascii "F\000"
	.align 2

.LC0:
	.word   80
	.word   70
	.word   60
	.word   50
	.text
	.align  1
	.global main
	.syntax unified
	.thumb
	.thumb_func
	.type   main, %function

main:
	@    args = 0, pretend = 0, frame = 32
	@    frame_needed = 1, uses_anonymous_args = 0
	push {r4, r7, lr}                              // store to stack
	sub  sp, sp, #36                               // reserve stack
	add  r7, sp, #0                                // keep track of stack head
	ldr  r2, .L11

.LPIC9:
	add r2, pc
	ldr r3, .L11+4
	ldr r3, [r2, r3]
	ldr r3, [r3]
	str r3, [r7, #28]
	mov r3, #0
	ldr r3, .L11+8

.LPIC0:  // i beleve this is to store array to memory and dealing with value of c
	add  r3, pc
	add  r4, r7, #12
	ldm  r3, {r0, r1, r2, r3}
	stm  r4, {r0, r1, r2, r3}
	add  r3, r7, #12
	adds r3, r3, #8
	str  r3, [r7, #8]
	adds r3, r7, #4
	mov  r1, r3
	ldr  r3, .L11+12

.LPIC1:  // and this is use for scanf
	add r3, pc
	mov r0, r3
	bl  __isoc99_scanf(PLT) // scanf to a
	ldr r3, [r7, #4]        // load a to here
	cmp r3, #100            // compare a with 100
	ble .L2                 // branching
	ldr r3, .L11+16

.LPIC2:
	add r3, pc
	mov r0, r3
	bl  puts(PLT) // isr for print
	b   .L3       // branch to end

.L2:
	ldr r3, [r7, #4] // load a
	cmp r3, #80      // compare a with 80
	ble .L4          // branching
	ldr r3, .L11+20

.LPIC3:
	add r3, pc
	mov r0, r3
	bl  puts(PLT) // isr for print
	b   .L3       // branch to end

.L4:
	ldr r2, [r7, #16] // load b[1]
	ldr r3, [r7, #4]  // load a
	cmp r2, r3        // compare b1 with a
	bge .L5           // branching
	ldr r3, .L11+24

.LPIC4:
	add r3, pc
	mov r0, r3
	bl  puts(PLT) // isr for print
	b   .L3       // branch to end

.L5:
	ldr r3, [r7, #8] // load c as address
	ldr r2, [r3]     // load value at address c
	ldr r3, [r7, #4] // load a
	cmp r2, r3       // cmp c with a
	bge .L6          // branching
	ldr r3, .L11+28

.LPIC5:
	add r3, pc
	mov r0, r3
	bl  puts(PLT) // isr for print
	b   .L3       // branch to end

.L6:
	ldr r2, [r7, #24] // load b[3]
	ldr r3, [r7, #4]  // load a
	cmp r2, r3        // cmp b[3] with a
	bgt .L7           // branching
	ldr r3, .L11+32

.LPIC6:
	add r3, pc
	mov r0, r3
	bl  puts(PLT) // isr for print
	b   .L3       // branch to end

.L7:
	ldr r3, [r7, #4] // load a
	cmp r3, #0       // cmp with 0
	blt .L8          // branch for the last else
	ldr r3, .L11+36

.LPIC7:
	add r3, pc
	mov r0, r3
	bl  puts(PLT) // isr for print
	b   .L3       // branch to end

.L8:
	ldr r3, .L11+40

.LPIC8:
	add r3, pc
	mov r0, r3
	bl  puts(PLT) // isr for print

.L3:
	movs r3, #0
	ldr  r1, .L11+44

.LPIC10:
	add  r1, pc
	ldr  r2, .L11+4
	ldr  r2, [r1, r2]
	ldr  r1, [r2]
	ldr  r2, [r7, #28]
	eors r1, r2, r1
	mov  r2, #0
	beq  .L10
	bl   __stack_chk_fail(PLT)

.L10:
	mov  r0, r3
	adds r7, r7, #36
	mov  sp, r7
	@    sp needed
	pop  {r4, r7, pc}

.L12:
	.align 2

.L11:
	.word    _GLOBAL_OFFSET_TABLE_-(.LPIC9+4)
	.word    __stack_chk_guard(GOT)
	.word    .LC0-(.LPIC0+4)
	.word    .LC1-(.LPIC1+4)
	.word    .LC2-(.LPIC2+4)
	.word    .LC3-(.LPIC3+4)
	.word    .LC4-(.LPIC4+4)
	.word    .LC5-(.LPIC5+4)
	.word    .LC6-(.LPIC6+4)
	.word    .LC7-(.LPIC7+4)
	.word    .LC2-(.LPIC8+4)
	.word    _GLOBAL_OFFSET_TABLE_-(.LPIC10+4)
	.size    main, .-main
	.ident   "GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section .note.GNU-stack, "", %progbits
