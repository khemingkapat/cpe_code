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
	push	{r4, r5, r7, r8, r9, lr} ; preserving registers for this program
	sub	sp, sp, #24 ; allocate the stack pointer, subtract 24 bytes (idk why 24)
	add	r7, sp, #0 ; sub r7 by 24 to be add the start
	str	r0, [r7, #4] ; store the value of num in the program to 4 bytes after the r7
	ldr	r2, .L10
.LPIC1:
; i believe this part is  is to initialize array, some of them is quite questionable(i think it is for optimization purpose)
; so I try my best to do explain it
	add	r2, pc ; add pc to r2 and store in r2
	ldr	r3, .L10+4 ; load value from .L10 that offset by 4 bytes
	ldr	r3, [r2, r3] ; load value from r2 offset by r3 to r3
	ldr	r3, [r3] ; load value from address stored in r3 to r3
	str	r3, [r7, #20] ; store that value we loaded to 20 bytes from r7 (start of the program)
	mov	r3, #0  ; clear r3 to 0
	mov	r3, sp ; copy sp to r3
	mov	r0, r3 ; copy value from r3 to r0
	ldr	r3, [r7, #4]  ; load value from 4 bytes from r7 (num) to r3
	adds	r1, r3, #1 ; add r3 by 1 (num+1) and store result in r1 
	subs	r3, r1, #1 ; store value (num+1)-1 (which is num) to r3
	str	r3, [r7, #12] ; store value in r3(num) into 12 bytes after r7
	mov	r2, r1 ; copy value in r1 (num+1) to r2 
	movs	r3, #0 ; clear r3 to 0
	mov	r8, r2 ; copy value in r2 (num+1) to r8
	mov	r9, r3 ; copy value in r3 (0) to r9
	mov	r2, #0 ; clear r2 to 0
	mov	r3, #0 ; clear r3 to 0

; this part is confusing, since some number came out of nowhere,
; maybe since we working with 0 and num+1 it might initialize array and index it

	lsl	r3, r9, #5 ; leftshift r9 (0) by 5 bit and store shifted value to r3
	orr	r3, r3, r8, lsr #27 ; bitwise or of r3 and r8 (num+1) that right shift by 27 bit and store value to r3
	lsl	r2, r8, #5  ; leftshift r8 (num+1) by 5 bit and store in r2
	mov	r2, r1 ; copy r1 to r2
	movs	r3, #0 ; clear r3 to 0
	mov	r4, r2 ; copy value from r2 (num+1)<<5 to r4
	mov	r5, r3 ; copy value from r3(0) to r5
	mov	r2, #0 ; clear r2 to 0
	mov	r3, #0 ; clear r3 to 0
	lsls	r3, r5, #5 ; left shift r5 (0) that shifted by 5 bit to r3
	orr	r3, r3, r4, lsr #27 ; bitwise or of r3 with r4 that shifted to right by 27 bit
	lsls	r2, r4, #5 ; left shift r4 (num+1)<<5 by 5 bit and store to r2
	mov	r3, r1 ; copy r1(n+1) to r3
	lsls	r3, r3, #2 ; left r3 by 2 (num+1)<<2 and store it in r3
	adds	r3, r3, #7 ; add r3 with 7 and store it to r3
	lsrs	r3, r3, #3 ; right shift r3 with 3 and store in r3
	lsls	r3, r3, #3 ; left shift r3 with 3 and store r3
	sub	sp, sp, r3 ; sp = sp-r3
	mov	r3, sp ; store r3 = sp
	adds	r3, r3, #3 ; add r3 = r3+3
	lsrs	r3, r3, #2 ; left shift r3 by 2 bit and store in r3
	lsls	r3, r3, #2 ; again
; until this part is quite reasonable

	str	r3, [r7, #16] ;store value of r3 into 16 bit offset from r7
	ldr	r3, [r7, #16] ; i think that r3 is to get the first element of array
	movs	r2, #0 ; make it equal to 0
	str	r2, [r3] ; store value of r2(0) to address store in r3 ( address of first item)
	ldr	r3, [r7, #16] ; load the r3 back
	movs	r2, #1 ; make r2 store 1
	str	r2, [r3, #4] ; store r2(1) to second element of array
	movs	r3, #2 ; make r3 = 2 (i think it is to initialize i = 2)
	str	r3, [r7, #8]  ; store value of r3 in 8 bytes offset from r7 (store value i to r7+8)
	b	.L6 ; go to .L6
.L7:
	ldr	r3, [r7, #8] ; get value from r7+8 (i)
	subs	r2, r3, #1 ;  r2 = i-1
	ldr	r3, [r7, #16] ; get address of array
	ldr	r2, [r3, r2, lsl #2] ; load value from first index of array offset by (i-1)*4 as size of int, so get fibs[i-1]
	ldr	r3, [r7, #8] ; get value from r7+8 (i)
	subs	r1, r3, #2 ; r2 = i-2
	ldr	r3, [r7, #16] ; get address of array
	ldr	r3, [r3, r1, lsl #2] ; load value from first index of array offset by (i-2)*4 as size of int, so get fibs[i-2]

	adds	r1, r2, r3 ; set it to be r1 = fibs[i-1] + fibs[i-2] 
	ldr	r3, [r7, #16] load first index of array
	ldr	r2, [r7, #8] load i
	str	r1, [r3, r2, lsl #2] store calculated value in the first index offset by (i*4) as fibs[i] = fibs[i-1] + fibs[i-2]
	ldr	r3, [r7, #8] ; load r7+8(i) to r3
	adds	r3, r3, #1 ; r3 = r3+1 (i = i+1)
	str	r3, [r7, #8] ; store it back in
.L6:
	ldr	r2, [r7, #8] ; load from r7+8 (i) to r2
	ldr	r3, [r7, #4] ; load from r7+4 (num) to r3
	cmp	r2, r3 ;compare r2 to r3 (i num)
	ble	.L7 ; if less than equal (should be comparing i and num, so)
	ldr	r3, [r7, #16]; load from r7+16(first index of array) to r3
	ldr	r2, [r7, #4] ; load from r7+4(num)
	ldr	r3, [r3, r2, lsl #2] ; get value of of first index of array offset by (num*4) as the last index so get fibs[num]
	mov	sp, r0 ; copy r0 to sp
	ldr	r1, .L10+8 ; load that specific memory to r1
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
