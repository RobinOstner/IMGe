.global single

.code 32

single: 

	;# Sichern der benoetigten Register
	PUSH {r4-r10, lr}

	;# Laden der restlichen beiden Uebergabewerte vom Stack
	ldr r4, [sp, #32]
	ldr r5, [sp, #36]

	;# Berechnen der Schrittgröße in Y-Richtung (deltaY)	
	vmov s0, r3
	SUB r9, r3, r2	;# iEnd - iStart / Differenz
	vmov s1, r9
	vmov s4, r4

	vcvt.F32.S32 s0, s0
	VCVT.F32.U32 s1, s1	
	VCVT.F32.U32 s4, s4

	MOV r9, #1
	VMOV s5, r9
	VCVT.F32.U32 s5, s5
	VSUB.F32 s4, s4, s5		;# Resolution - 1 um auf richtige Schrittanzahl zu kommen

	VDIV.F32 s1, s1, s4		;# Schrittgröße in Y-Richtung / deltaY

;#deltaX
	vmov s2, r0
	SUB r9, r1, r0		;# rEnd - rStart
	vmov s3, r9
		
	VCVT.F32.S32 s2, s2
	VCVT.F32.U32 s3, s3
	

	VDIV.F32 s3, s3, s4	;# Schrittgröße in X-Richtung / deltaX
	

	;# Counter für Y-Schleife initialisieren
	mov r6, #0

schleifeY:

	mov r7, #0		;# Counter für X-Schleife auf 0 setzen
	vmov s4, s2		;# Aktuelle X-Position auf xStart zurücksetzen

	schleifeX:
		
		;# Grundwerte für Berechnung müssen mit 0 initialisiert werden s5 = imaginär, s6 = real
		mov r10, #0
		VMOV s5, r10			;#imag
		VCVT.F32.U32 s5, s5
				 
		VMOV.F32 s6, s5			;#real
		mov r9, #20				;# Maximale Anzahl an Durchläufen
		schleifeF:
			;#z^2
			VMUL.F32 s7, s5, s5		;# imag^2

			VMUL.F32 s5, s5, s6		;# imag * real
			
			mov r10, #2
			VMOV s9, r10
			VCVT.F32.U32 s9, s9
			VMUL.F32 s5, s5, s9		;# 2 * imag * real


			VMUL.F32 s8, s6, s6		;#real^2

			VSUB.F32 s6, s8, s7		;# real^2 - imag^2

			VADD.F32 s6, s6, s4		;# Neuer Realteil + PositionskonstanteX
			VADD.F32 s5, s5, s0		;# Neuer Imaginärteil + PositionskonstanteY

			;#Überprüfung ob wert größer 5
			VADD.F32 s9, s5, s6
			
			;#cutoff von der Menge wenn Wert größer 4 / Entscheidung ob es divergiert oder konvergiert
			;# Quadrat macht behandlung von negativen Zahlen einfacher
			VMUL.F32 s10, s9, s9
			VCVT.U32.F32 s10, s10
			VMOV r10, s10
			cmp r10, #4
			mov r8, #57				;# Weiß ist Standard Wert
			bge schleifeabbruch		;# Schwarz Schreiben wird übersprungen wenn Wert größer 4

			mov r8, #48				;# Nur wenn Wert kleiner 4 wird Schwarz gespeichert
			sub r9, r9, #1			;# Schleifencounter verringern
			cmp r9, #0
			bge schleifeF

			schleifeabbruch:
			str r8, [r5]			;# Pixel wird gespeichert
			add r5, r5 , #1			;# Pointer verschieben

		VADD.F32 s4, s3		;# deltaX auf aktuelle X-Position addieren
		add r7, r7 , #1		;# Schleifencounter erhöhen
		cmp r7, r4
		blt schleifeX

	VSUB.F32 s0, s1		;# deltaY von aktueller Y-Position abziehen
	add r6, r6, #1		;# Schleifencounter erhöhen
	cmp r6, r4
	blt schleifeY


	;# Stack wiederherstellen
	POP {r4-r10, lr}
	BX lr
