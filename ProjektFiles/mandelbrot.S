.global mandelbrot

.code 32

mandelbrot: 

,# sichern der benötigten register laden der restlichen beiden werte vom stack
	PUSH {r4-r10, lr}
	ldr r4, [sp, #32]
	ldr r5, [sp, #36]
	
;#berechnen von deltaY, unterschied zwischen 2Pixeln in y Richtung	
	vmov s0, r2
	SUB r9, r3, r2
	vmov s1, r9
	vmov s4, r4

	vcvt.F32.S32 s0, s0
	VCVT.F32.U32 s1, s1	
	VCVT.F32.U32 s4, s4

	MOV r9, #1
	VMOV s5, r9
	VCVT.F32.U32 s5, s5
	VSUB.F32 s4, s4, s5

	VDIV.F32 s1, s1, s4

;#berechnen von deltaX, unterschied zwischen 2Pixeln in X Richtung	
	vmov s2, r0
	SUB r9, r1, r0
	vmov s3, r9
		
	VCVT.F32.S32 s2, s2
	VCVT.F32.U32 s3, s3
	

	VDIV.F32 s3, s3, s4	

	;#erstellen eines res*res*2*float(4) arrays zu speicherung der positionswerten
	mov r10, r4
	push {r0-r9};
	
	MUL r0, r10, r10
	LSL r0, #3
	bl malloc
	mov r10, r0
	pop{r0-r9}


;#durchlaufen der schleifen x und y Laufwerte stehen in r6 und r7, hier befüllen wir das array image mit den positionswerten
mov r6, #0
schleifeY:
	mov r7, #0
	vmov s4, s2 ;#holen von xstart

	schleifeX:
		
		;#s4 laufwertX s0 laufwerty
		VSTR r10, [s4]	
		ADD r10, #4
		VSTR r10, [s0]
		ADD r10, #4

		VADD.F32 s4, s3
		add r7, r7 , #1
		cmp r7, r4
		blt schleifeX

	VADD.F32 s0, s1
	add r6, r6, #1
	cmp r6, r4
	blt schleifeY


	;#
	;#
mov r10, #0
		VMOV s5, r10 ;#imag
		VCVT.F32.U32 s5, s5
				 
		VMOV.F32 s6, s5 ;#real
		mov r9, #20
		schleifeF:
			;#z^2
			VMUL.F32 s7, s5, s5		;#imag^2
			VMUL.F32 s5, s5, s6
			
			mov r10, #2
			VMOV s9, r10
			VCVT.F32.U32 s9, s9
			VMUL.F32 s5, s5, s9		;#imag ohne b


			VMUL.F32 s8, s6, s6		;#real^2
			VSUB.F32 s6, s8, s7		;#real ohne a
			VADD.F32 s6, s6, s4		;#real
			VADD.F32 s5, s5, s0		;#imag 

			;#Überprüfung ob wert größer 5
			VADD.F32 s9, s5, s6
			
			;#cutoff von der Menge entscheidung ob es divergiert oder konvergiert
			VMUL.F32 s10, s9, s9
			VCVT.U32.F32 s10, s10
			VMOV r10, s10
			cmp r10, #4
			mov r8, #57			
			bge schleifeabbruch

			
			
						
			mov r8, #48
			sub r9, r9, #1
			cmp r9, #0
			bge schleifeF

			schleifeabbruch:
			str r8, [r5]
			add r5, r5 , #1


	POP {r4-r10, lr}
	BX lr
