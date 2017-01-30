.global mandelbrot

.code 32

mandelbrot: 

;# sichern der benötigten register laden der restlichen beiden werte vom stack
	PUSH {r4-r12, lr}
	ldr r4, [sp, #40]
	ldr r5, [sp, #44]
	
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
	
	pop {r0-r9}
	push {r12}
	mov r12, r10
	


;#durchlaufen der schleifen x und y Laufwerte stehen in r6 und r7, hier befüllen wir das array image mit den positionswerten
mov r6, #0
schleifeY:
	mov r7, #0
	vmov s4, s2 ;#holen von xstart

	schleifeX:
		
		;#s4 laufwertX s0 laufwerty
		
		VSTR.F32 s4, [r10]	;#real
		ADD r10, #4
		VSTR.F32 s0, [r10] ;#ima
		ADD r10, #4

		;#schleife und currentX um eines erhöhen auf abbruch überprüfen
		VADD.F32 s4, s3
		add r7, r7 , #1
		cmp r7, r4
		blt schleifeX

	;#schleife und currenty um eines erhöhen auf abbruch überprüfen
	VADD.F32 s0, s1
	add r6, r6, #1
	cmp r6, r4
	blt schleifeY

	;#parallele berechnung 
	
	;# wie oft müssen wir parallel berechnen
	;# 4 pixel in q register
	mov r0, r5 ;#pointer zum bildarray
	mov r1, r4 ;#resolution
	
	MUL r1, r1, r1
	LSR r1, #2


	VPUSH {q0-q5}
	;# modulo 4 berechnen für überhang letzen pixel
	mov r6, #0
	mov r7, r10 ;#offset für array

	mov r11, #4
	VMOV s31, r11
	vcvt.f32.u32 s31, s31
	
	
loopParallel:
	
	VLD1.F32 {d0[1]}, [r7]
	add r7, r7, #2
	VLD1.F32 {d2[1]}, [r7]
	add r7, r7, #2
	VLD1.F32 {d0[0]}, [r7]
	add r7, r7, #2
	VLD1.F32 {d2[0]}, [r7]
	add r7, r7, #2

	break:

	VLD2.32 {d0,d2}, [r7] ;#laden der Positionswerte aus dem arrays, q0 real, q1 ima
	add r7, r7, #4
	VLD2.32 {d1,d3}, [r7]
	add r7, r7, #4

	;#erster schleifendurchlauf hier wird ja (0+0i)^2+Konstante gerechnet also kann an direkt Konstantereinschreiben
	VMOV.F32 d4, d0
	VMOV.F32 d5, d1
	VMOV.F32 d6, d2
	VMOV.F32 d7, d3

	;#VLD2.32 {q2,q3}, [r7] ;#erster schleifendurchlauf hier wird ja (0+0i)^2+Konstante gerechnet also kann an direkt Konstantereinschreiben
	;#add r7, r7, #8

	mov r8, #20
	mov r9, #4 ;# Token system um das dauerhafte laufen von schleifen zu verhindern

	;#schleifendurchläufe für die Pixel
	mov r2, #21
	mov r3, #21
	mov r4, #21
	mov r5, #21


	;#parallele berechnung der Konvergenz
	schleifeF:
		;#berechnung von 2ab
		VMUL.f32 q4, q2, q3 ;#ab
		VADD.f32 q4, q4, q4 ;#2

		VMUL.f32 q2, q2, q2 ;#real*real
		VMUL.f32 q3, q3, q3 ;#ima*ima  -> abziehen 

		VSUB.f32 q2, q2, q3 ;#real^2-ima^2
		VADD.f32 q2, q2, q0 ;# + real Konstante

		VADD.f32 q3, q4, q1 ;#2ab + ima Konstante

		;#vergleichen auf abbruchkriterium
		VADD.f32 q4, q2, q3 ;# addieren von real und imaginärteil
		VMUL.f32 q4, q4 ,q4 ;# quadrieren von real und imaginärteil
		;#128 ist q4.d0 ->  its q4.d0.s0 = s16
		
		;#speicher der anzahl der Runden die gemacht wurden in den jeweiligen register, und 1 Token rausnehmen um frühzeitigen abbruch herbei zu führen
		;#wenn der token bereits gesetzt wurde dann wird geskippt		
		cmp r2, #21		
		VCMPGE.f32 s16, s31
		SUBGE r2, r2, r8
		SUBGE r9, r9, #1

		cmp r3, #21		
		VCMPGE.f32 s17, s31
		SUBGE r3, r3, r8
		SUBGE r9, r9, #1

		cmp r4, #21		
		VCMPGE.f32 s18, s31
		SUBGE r4, r4, r8
		SUBGE r9, r9, #1

		cmp r5, #21		
		VCMPGE.f32 s19, s31
		SUBGE r5, r5, r8
		SUBGE r9, r9, #1

		cmp r9, #0
		ble endschleifeF

	sub r8, #1
	cmp r8, #0
	bge schleifeF
	
endschleifeF:
	;#speichern der 4 Pixel
	push {r6-r10}
	;#1,2 farbwert allg konvergenz 0 oder 255
	;#3 Farbwert 255-i*12
	;# b g r, r0 pointer bildarray
	mov r9, #12

	;#Pixel 0	
	cmp r2, #21
	MOV r6, #0
	ADDLT r6, r6, #255 
	STR r6, [r0]
	ADD r0, r0, #1
	STR r6, [r0]
	ADD r0, r0, #1

	MOV r6, #255
	MUL r8, r2, r9
	SUB r6, r6, r8
	STR r6, [r0]
	ADD r0, r0, #1

	;#Pixel 1	
	cmp r3, #21
	MOV r6, #0
	ADDLT r6, r6, #255 
	STR r6, [r0]
	ADD r0, r0, #1
	STR r6, [r0]
	ADD r0, r0, #1

	MOV r6, #255
	MUL r8, r3, r9
	SUB r6, r6, r8
	STR r6, [r0]
	ADD r0, r0, #1

		;#Pixel 2
	cmp r4, #21
	MOV r6, #0
	ADDLT r6, r6, #255 
	STR r6, [r0]
	ADD r0, r0, #1
	STR r6, [r0]
	ADD r0, r0, #1

	MOV r6, #255
	MUL r8, r4, r9
	SUB r6, r6, r8
	STR r6, [r0]
	ADD r0, r0, #1

		;#Pixel 3
	cmp r5, #21
	MOV r6, #0
	ADDLT r6, r6, #255 
	STR r6, [r0]
	ADD r0, r0, #1
	STR r6, [r0]
	ADD r0, r0, #1

	MOV r6, #255
	MUL r8, r5, r9
	SUB r6, r6, r8
	STR r6, [r0]
	ADD r0, r0, #1
	;#
	POP {r6-r10}
	;#
	
	;#schleifenabbruchbedingung von loopParallel
	add r6, r6, #1	
	cmp r6, r1
	;#bge end
	blt loopParallel

end:
	VPOP {q0-q5}
	;#
	;#
	POP {r12}
	mov r0, r12
	bl free

	
	POP {r4-r12, lr}
	BX lr
