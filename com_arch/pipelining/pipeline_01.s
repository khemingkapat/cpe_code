.arch   armv7-a
.fpu    vfpv3-d16
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
.file   "pipeline_01.c"
.text
.align  1
.global main
.syntax unified
.thumb
.thumb_func
.type   main, %function

main:
	@        args = 0, pretend = 0, frame = 24
	@        frame_needed = 1, uses_anonymous_args = 0
	@        link register save eliminated.
	push     {r7}                                         // store r7 in case needed
	sub      sp, sp, #28                                  // reserve stack
	add      r7, sp, #0                                   // store sp in r7
	movs     r3, #10                                      // r3 = 10, as a = 10
	str      r3, [r7, #4]                                 // store r3 in stack
	ldr      r3, [r7, #4]                                 // load r3 from stack
	adds     r3, r3, #30                                  // add r3, which is a by 30
	str      r3, [r7, #8]                                 // store c in stack
	movs     r3, #20                                      // now r3 = 20, which is b
	str      r3, [r7, #12]                                // store b in stack
	ldr      r3, [r7, #12]                                // load b into r3
	adds     r3, r3, #20                                  // add b by 20, now it is d
	str      r3, [r7, #16]                                // store d in stack
	ldr      r2, [r7, #4]                                 // load a in to r2
	ldr      r3, [r7, #12]                                // load b into r3
	add      r2, r2, r3                                   // add a+b into r2
	ldr      r3, [r7, #8]                                 // load c into r3
	add      r3, r3, r2                                   // add c to to r2, which is a + b + c and store in r3
	ldr      r2, [r7, #16]                                // load d into r2
	add      r3, r3, r2                                   // add d into r3, to be a + b + c + d = e
	str      r3, [r7, #20]                                // store e in stack
	ldr      r3, [r7, #20]                                // load e
	mov      r0, r3                                       // move value of e into r0, return address
	adds     r7, r7, #28                                  // return stack to top
	mov      sp, r7                                       // clear stack
	@        sp needed
	ldr      r7, [sp], #4
	bx       lr
	.size    main, .-main
	.ident   "GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section .note.GNU-stack, "", %progbits
