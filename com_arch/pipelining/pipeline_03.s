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
.file    "pipeline_03.c"
.text
.section .rodata
.align   2

.LC0:
	.ascii  "%ld\012\000"
	.text
	.align  1
	.global main
	.syntax unified
	.thumb
	.thumb_func
	.type   main, %function

main:
	@    args = 0, pretend = 0, frame = 16
	@    frame_needed = 1, uses_anonymous_args = 0
	push {r7, lr}
	sub  sp, sp, #16
	add  r7, sp, #0
	movs r3, #0                                    // i=0
	str  r3, [r7]                                  // store i on top of stack could create Data Hazard
	b    .L2                                       // go to .L2(branching causing control

.L5:
	movs r3, #0       // initialize j
	str  r3, [r7, #4] // store at stack+4
	b    .L3

.L4:
	ldr  r2, [r7]      // load i
	ldr  r3, [r7, #4]  // load j
	add  r3, r3, r2    // add i +j
	str  r3, [r7, #12] // store for x
	ldr  r2, [r7, #8]  // load sum
	ldr  r3, [r7, #12] // store at x
	add  r3, r3, r2    // sum = sum +x
	str  r3, [r7, #8]  // store back at sum
	ldr  r3, [r7, #4]  // load j
	adds r3, r3, #1    // j = j+1
	str  r3, [r7, #4]  // store back

.L3:  // loop j
	ldr  r3, [r7, #4] // load j
	cmp  r3, #9       // compare j and 9
	ble  .L4          // if j<= 9
	ldr  r3, [r7]     // load i
	adds r3, r3, #1   // i = i+1
	str  r3, [r7]     // store back

.L2:  // loop i
	ldr r3, [r7]     // load i
	cmp r3, #9       // if i <= 9(i<10)
	ble .L5
	ldr r1, [r7, #8]
	ldr r3, .L7

.LPIC0:  // as end of function, load value and print out, as well as clear stack
	add  r3, pc
	mov  r0, r3
	bl   printf(PLT)
	movs r3, #0
	mov  r0, r3
	adds r7, r7, #16
	mov  sp, r7
	@    sp needed
	pop  {r7, pc}

.L8:
	.align 2

.L7:
	.word    .LC0-(.LPIC0+4)
	.size    main, .-main
	.ident   "GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section .note.GNU-stack, "", %progbits
