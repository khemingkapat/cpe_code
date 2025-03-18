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
	movs r3, #0                                    // sum = 0
	str  r3, [r7]                                  // store
	b    .L2

.L5:
	movs r3, #0       // i = 0
	str  r3, [r7, #4] // store at stack+4
	b    .L3

.L4:
	ldr  r2, [r7]      // load sum
	ldr  r3, [r7, #4]  // load i
	add  r3, r3, r2    // add
	str  r3, [r7, #12]
	ldr  r2, [r7, #8]
	ldr  r3, [r7, #12]
	add  r3, r3, r2
	str  r3, [r7, #8]
	ldr  r3, [r7, #4]
	adds r3, r3, #1
	str  r3, [r7, #4]

.L3:
	ldr  r3, [r7, #4] // load i
	cmp  r3, #9       // compare i and 9
	ble  .L4          // if i <= 9 continue
	ldr  r3, [r7]
	adds r3, r3, #1
	str  r3, [r7]

.L2:
	ldr r3, [r7]
	cmp r3, #9
	ble .L5
	ldr r1, [r7, #8]
	ldr r3, .L7

.LPIC0:
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
