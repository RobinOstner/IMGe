.global mandelbrot

.code 32

mandelbrot: 

;#save old registers and get all input values
	PUSH {r4-r10, lr}
	ldr r4, [sp, #32]
	ldr r5, [sp, #36]

;#r6 is counter for loop along Y axis 
	mov r6, #0

;#calculating deltaY to know distance between two samplepoints	done in floating point unit
	vmov s0, r3
	SUB r9, r3, r2
	vmov s1, r9
	vmov s4, r4

	vcvt.F32.S32 s0, s0
	VCVT.F32.U32 s1, s1	
	VCVT.F32.U32 s4, s4

	;# eins von resolution abziehen weil wir bei 0 anfangen
	MOV r9, #1
	VMOV s5, r9
	VCVT.F32.U32 s5, s5
	VSUB.F32 s4, s4, s5

	VDIV.F32 s1, s1, s4

;##calculating deltaX to know distance between two samplepoints	done in floating point unit
	vmov s2, r0
	SUB r9, r1, r0
	vmov s3, r9
		
	VCVT.F32.S32 s2, s2
	VCVT.F32.U32 s3, s3
	

	VDIV.F32 s3, s3, s4	


;# iterieren über das array bzw über die samplepunkte entlang der zeilen von oben nach unten
schleifeY:
	;#r7 beinhaltet den laufwert für die zweite schleife entlang des realteils, und zurücksetzen der x koordinate
	mov r7, #0
	vmov s4, s2

	schleifeX:
		;# start bei realteil 0 und imaginär 0, Basis für Berechnung der Formel
		mov r10, #0
		VMOV s5, r10 ;#imag
		VCVT.F32.U32 s5, s5
				 
		VMOV.F32 s6, s5 ;#real
		mov r9, #20 ;#anzahl der maximalen Formelwiederholungen

		;# Anwendung der Formel
		schleifeF:
			;#z^2
			VMUL.F32 s7, s5, s5		;#imag^2
			
			VMUL.F32 s5, s5, s6		;# 2*a*b
			mov r10, #2
			VMOV s9, r10
			VCVT.F32.U32 s9, s9
			VMUL.F32 s5, s5, s9		;#imag ohne BConstant


			VMUL.F32 s8, s6, s6		;#real^2
			VSUB.F32 s6, s8, s7		;#real ohne AConstant
			VADD.F32 s6, s6, s4		;#realteile addierden
			VADD.F32 s5, s5, s0		;#imag teile addieren

			;#Überprüfung ob wert größer 5
			VADD.F32 s9, s5, s6
			
			;#cutoff von der Menge entscheidung ob es divergiert oder konvergiert je nachdem Farbwert setzen
			;#setze weiss
			VMUL.F32 s10, s9, s9
			VCVT.U32.F32 s10, s10
			VMOV r10, s10
			cmp r10, #4
			mov r8, #57			
			bge schleifeabbruch

			;# setzen schwarz	
			mov r8, #48
			sub r9, r9, #1
			cmp r9, #0
			bge schleifeF

			;# speichern in das array un array pointer um eines erhöhen
			schleifeabbruch:
			str r8, [r5]
			add r5, r5 , #1

		;# xwert um eines erhöhen und Laufwert schleifeX um eines erhöhen
		VADD.F32 s4, s3
		add r7, r7 , #1
		cmp r7, r4
		blt schleifeX

	;# ywert um eines erhöhen und Laufwert schleifeY um eines erhöhen
	VSUB.F32 s0, s1
	add r6, r6, #1
	cmp r6, r4
	blt schleifeY



	;# gesicherte werte wieder zurückschreiben und asm teil beenden
	POP {r4-r10, lr}
	BX lr
