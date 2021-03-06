.global mandelbrot

.code 32

mandelbrot: 
	PUSH {r4-r10, lr}
	ldr r4, [sp, #32]
	ldr r5, [sp, #36]


	mov r6, #0
;#deltaY	
	vmov s0, r3
	SUB r9, r3, r2
	vmov s1, r9
	vmov s4, r4

	vcvt.F32.U32 s0, s0
	VCVT.F32.U32 s1, s1	
	VCVT.F32.U32 s4, s4

	VDIV.F32 s1, s1, s4

;#deltaX
	vmov s2, r0
	sub r9, r1, r0
	vmov s3, r9
	
	VCVT.F32.U32 s2, s2
	VCVT.F32.U32 s3, s3

	VDIV.F32 s3, s3, s4	


schleifeY:
	mov r7, #0
	vmov s4, s2

	schleifeX:
		

		VMOV.F32 s5, #0 ;#imag
		VMOV.F32 s6, #0 ;#real
		mov r9, #10
		schleifeF:
			;#z^2
			VMUL.F32 s7, s5, s5		;#imag^2
			VMUL.F32 s5, s5, s6
			VMUL.F32 s5, s5, #2		;#imag ohne b
			VMUL.F32 s8, s6, s6		;#real^2
			VSUB.F32 s6, s8, s7		;#real ohne a
			VADD.F32 s6, s6, s4		;#real
			VADD.F32 s5, s5, s0		;#imag 

			;#�berpr�fung ob wert gr��er 5
			VADD.F32 s9, s5, s6
			cmp s9, #5
			mov r8, #57
			
			bge schleifeabbruch

			mov r8, #48
			sub r9, r9, #1
			cmp r9, #0
			bge schleifeF

			schleifeabbruch:
			str r8, [r5]
			add r5, r5 , #1

		VADD.F32 s4, s3
		add r7, r7 , #1
		cmp r7, r4
		blt schleifeX

	VSUB.F32 s0, s1
	add r6, r6, #1
	cmp r6, r4
	blt schleifeY




	POP {r4-r10, lr}
	BX lr
