	.arch armv7-a
	.fpu vfpv3-d16
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
	.file	"main.c"
	.text
	.section	.rodata
	.align	2
.LC0:
	.ascii	"the 44th fibonacci is %ld\012\000"
	.text
	.align	1
	.global	main
	.syntax unified
	.thumb
	.thumb_func
	.type	main, %function
main:
	@ args = 0, pretend = 0, frame = 8
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r7, lr}
	sub	sp, sp, #8
	add	r7, sp, #0
	movs	r0, #44
	bl	fib(PLT)
	str	r0, [r7, #4]
	ldr	r1, [r7, #4]
	ldr	r3, .L3
.LPIC0:
	add	r3, pc
	mov	r0, r3
	bl	printf(PLT)
	movs	r3, #0
	mov	r0, r3
	adds	r7, r7, #8
	mov	sp, r7
	@ sp needed
	pop	{r7, pc}
.L4:
	.align	2
.L3:
	.word	.LC0-(.LPIC0+4)
	.size	main, .-main
	.align	1
	.global	fib
	.syntax unified
	.thumb
	.thumb_func
	.type	fib, %function
fib:
	@ args = 0, pretend = 0, frame = 24
	@ frame_needed = 1, uses_anonymous_args = 0
	push	{r4, r5, r7, r8, r9, lr}
	sub	sp, sp, #24
	add	r7, sp, #0
	str	r0, [r7, #4]
	ldr	r2, .L10
.LPIC1:
	add	r2, pc
	ldr	r3, .L10+4
	ldr	r3, [r2, r3]
	ldr	r3, [r3]
	str	r3, [r7, #20]
	mov	r3, #0
	mov	r3, sp
	mov	r0, r3
	ldr	r3, [r7, #4]
	adds	r1, r3, #1
	subs	r3, r1, #1
	str	r3, [r7, #12]
	mov	r2, r1
	movs	r3, #0
	mov	r8, r2
	mov	r9, r3
	mov	r2, #0
	mov	r3, #0
	lsl	r3, r9, #5
	orr	r3, r3, r8, lsr #27
	lsl	r2, r8, #5
	mov	r2, r1
	movs	r3, #0
	mov	r4, r2
	mov	r5, r3
	mov	r2, #0
	mov	r3, #0
	lsls	r3, r5, #5
	orr	r3, r3, r4, lsr #27
	lsls	r2, r4, #5
	mov	r3, r1
	lsls	r3, r3, #2
	adds	r3, r3, #7
	lsrs	r3, r3, #3
	lsls	r3, r3, #3
	sub	sp, sp, r3
	mov	r3, sp
	adds	r3, r3, #3
	lsrs	r3, r3, #2
	lsls	r3, r3, #2
	str	r3, [r7, #16]
	ldr	r3, [r7, #16]
	movs	r2, #0
	str	r2, [r3]
	ldr	r3, [r7, #16]
	movs	r2, #1
	str	r2, [r3, #4]
	movs	r3, #2
	str	r3, [r7, #8]
	b	.L6
.L7:
	ldr	r3, [r7, #8]
	subs	r2, r3, #1
	ldr	r3, [r7, #16]
	ldr	r2, [r3, r2, lsl #2]
	ldr	r3, [r7, #8]
	subs	r1, r3, #2
	ldr	r3, [r7, #16]
	ldr	r3, [r3, r1, lsl #2]
	adds	r1, r2, r3
	ldr	r3, [r7, #16]
	ldr	r2, [r7, #8]
	str	r1, [r3, r2, lsl #2]
	ldr	r3, [r7, #8]
	adds	r3, r3, #1
	str	r3, [r7, #8]
.L6:
	ldr	r2, [r7, #8]
	ldr	r3, [r7, #4]
	cmp	r2, r3
	ble	.L7
	ldr	r3, [r7, #16]
	ldr	r2, [r7, #4]
	ldr	r3, [r3, r2, lsl #2]
	mov	sp, r0
	ldr	r1, .L10+8
.LPIC2:
	add	r1, pc
	ldr	r2, .L10+4
	ldr	r2, [r1, r2]
	ldr	r1, [r2]
	ldr	r2, [r7, #20]
	eors	r1, r2, r1
	mov	r2, #0
	beq	.L9
	bl	__stack_chk_fail(PLT)
.L9:
	mov	r0, r3
	adds	r7, r7, #24
	mov	sp, r7
	@ sp needed
	pop	{r4, r5, r7, r8, r9, pc}
.L11:
	.align	2
.L10:
	.word	_GLOBAL_OFFSET_TABLE_-(.LPIC1+4)
	.word	__stack_chk_guard(GOT)
	.word	_GLOBAL_OFFSET_TABLE_-(.LPIC2+4)
	.size	fib, .-fib
	.ident	"GCC: (Ubuntu 13.3.0-6ubuntu2~24.04) 13.3.0"
	.section	.note.GNU-stack,"",%progbits
