.global mandelbrot

.code 32

mandelbrot:

;# sichern der benötigten register
	PUSH {r0-r12, lr}
	

;#laden der restlichen beiden werte vom stack
	ldr r4, [sp, #56]
	ldr r5, [sp, #60]
	PUSH {r5}
;#berechnen von deltaX, unterschied zwischen 2Pixeln in x Richtung	
	SUB r1, r3, r2 ;#xEnd-XStart
	SUB r3, r3, r2 ;#yEnd-yStart

	MOV r6, #1 
	SUB r6, r4, r6 ;#1 von resolution abziehen weil wir ja bei 0 anfangen
	
	VMOV s0, r0 ;#xStart in fpu schreiben
	VMOV s1, r1 ;#verschieben von xEnd-xStart und resolution in fpu
	VMOV s2, r2 ;#verschieben von yStart

	VMOV s3, r3 ;#verschieben von yEnd-yStart
	VMOV s4, r6 ;#verschieben von resolution-1 
	

;#konvertieren von resolution, xStart, xStart-xEnd in f32
	VCVT.F32.S32 s0, s0
	VCVT.F32.S32 s1, s1	
	VCVT.F32.S32 s2, s2
	VCVT.F32.S32 s3, s3
	VCVT.F32.S32 s4, s4

;#Teilen von beiden End-Start durch resolution um deltas zu erhalten
	VDIV.F32 s1, s1, s4 
	VDIV.F32 s3, s3, s4

;#alles bis auf pointer zum array und resolution kann weggeschmissen werden
	MOV r0, r5
	MOV r1, r4
	
;#resolution*resolution-4 langlaufen, -4 weil wir ja von anfang an 4 Pixel befüllen
	MUL r2, r1, r1
	SUB r2, r2, #4

;#setup für simultane pixelberechnung mit early bailout für jeden einzelnen Pixel
;#r3-r6 enhalten die anzahl der bereits durchlaufenen wiederholungen für den jeweiligen pixel
	MOV r3, #0
	MOV r4, #0
	MOV r5, #0
	MOV r6, #0

;#r7 enthält die maximale Anzahl an erlaubten durchläufen
	MOV r7, #20

;#r8-r11 beinhalten den zu speichernden pixel
	MOV r8, r0
	ADD r0, #3
	MOV r9, r0
	ADD r0, #3
	MOV r10, r0
	ADD r0, #3
	MOV r11, r0
	ADD r0, #3 ;#r0 enthält die adresse zum nächsten Pixel
	
;#befüllen der fpu register mit den ersten loopzahlen hierbei starten wir bei x y und nich tbei 0 0 lassen also den ersten durchlauf weg

;#s4-s7 beinhalten die x Koordinaten der 4Pixel
	VMOV.F32 s4, s0
	VMOV.F32 s5, s0
	VADD.F32 s5, s1 ;#pixel X Koordinate um 1 erhöhen
	VMOV.F32 s6, s5
	VADD.F32 s6, s1 ;#wiederum um 1 erhöhen  
	VMOV.F32 s7, s6
	VADD.F32 s7, s1 ;#wiederum um 1 erhöhen 
	;#in s30 speichern wir den nächsten x Wert
	VMOV.F32 s30, s7
	


;#s8-s11 beinhalten die y Koordinate der 4Pixel
	VMOV.F32 s8, s2
	VMOV.F32 s9, s2
	VMOV.F32 s10, s2
	VMOV.F32 s11, s2

;#q1 und q2 in real und imaginärteil kopieren, quasi ersten schleifendurchlauf überspringen 
	VMOV.F32 q3, q1
	VMOV.F32 q4, q2

;#die zahl 4 in s31 speichern, als abbruch wert/schwellwert
	VMOV.F32 s31, #4.0 

;#schleife in welcher wir die berechnung durchführen
loop:

	#schleife die solange die Formel durchläuft bis ein Pixel rausfällt
	
		VMUL.F32 q5, q3, q4 ;#ab 
		VADD.F32 q5, q5, q5	;#2ab von (real+ima)^2

		VMUL.F32 q3, q3, q3 ;# real^2
		VMUL.F32 q4, q4, q4 ;# ima^2

		VSUB.F32 q3, q3, q4 ;# real^2-ima^2
		VADD.F32 q3, q3, q1 ;# neuer realteil + Konstant

		VADD.F32 q4, q4, q5 ;# 2ab + imaginär Konstante

		;#konvergenzberechnung hier zu ende

		;#überprüfen auf pixel bailout
		;#in q5 dafür auf überschreitung der Grenze achten
		VADD.F32 q5, q3, q4 ;# real + ima 
		VMUL.F32 q6, q5, q5 ;# quadrieren um negative zahlen einfacher zu behandeln
			
		;#Pixel 1
		;#auf überschreiten der Grenze schauen
		VCMP.F32 s24, s31
		VMRS APSR_nzcv, FPSCR
		
		;#bei größer early bailout
		blgt earlybailoutPX1
		cmp r3, r7 ;#hat der Pixel seine maximale Anzahl an durchläufen erreicht
		blge maxBailoutPX1

		;#erhöhen der pixellaufwerte
		ADD r3, r3, #1
		;#ADD r4, r4, #1
		;#ADD r5, r5, #1
		;#ADD r6, r6, #1
		
		
	;#loop abbruch bedingung wenn res*res <=0	
	CMP r2, #0
	bgt loop ;#solange wie größer 0
	ble end ;#zum ende wenn <=0

earlybailoutPX1:
	MOV r12, #255 ;#early bailout führt zu weiß
	STR r12, [r8] ;#farbwert 1
	ADD r8, r8, #1 
	STR r12, [r8] ;#farbwert 2
	ADD r8, r8, #1
	PUSH {r11} ;# benötigen 1 weitere register zum rechnen 
	MOV r11, #12
	MUL r11, r11, r3
	SUB r12, r12, r11 ;#Grad der konvergenz je später er aussteigt dest größer wird der rotanteil
	MOV r12, #255
	STR r12, [r8]
	POP {r11}
	b resetPX1

maxBailoutPX1:
	MOV r12, #0 ;#late bailout führt zu schwarz
	STR r12, [r8]
	ADD r8, r8, #1
	STR r12, [r8]
	ADD r8, r8, #1
	STR r12, [r8]	
	b resetPX1

resetPX1:
	MOV r3, #-1 ;#Laufzeit zurücksetzen auf -1 weil anschließend ja die laufzeit um eines standardmäßig in der sschleife erhöht wird
	;# neue werte in fpu register schreiben
	PUSH {lr}
	;# überprüfung auf zeilenumbruch
	bl checkNewLine
	POP {lr}

	VADD.F32 s30, s1  ;#currentX laufwert um 1 erhöhen
	VMOV.F32 s4, s30 ;#x Wert schreiben
	VMOV.F32 s12, s30 ;#P1 real schreiben
	VMOV.F32 s8, s2 ;#y Wert schreiben
	VMOV.F32 s16, s2 ;#P1 imaginär schreiben

	;#speicheradresse für nächsten pixel erhöhen und setzen
	MOV r8, r0
	ADD r0, r0, #3
	bx lr

;#überprüft auf zeilenumbruch
checkNewLine:
	PUSH {r0-r4, lr}
	

	;# wenn r2%res = 0 dann neue zeile also y erhöhen und s30 auf xStart 
	
	MOV r0, r2;# res*res in r0 und in r1 kommt res
	bl __aeabi_uidiv ;# udiv von 2 integern von gcc, da hier udiv oder sdiv nicht unetrstüzt werden
	MOV r12, r0 ;#zurückschreiben der div in r3 
	POP {r0-r4, lr}
	MLS r12, r12, r1, r2
	cmp r12, #0 ;# vergleichen auf zeilenumbruch
	VADDEQ.F32 s2, s2, s3 ;#y um einer erhöhen
	VMOVEQ.F32 s30, s0 ;#zurücksetzen auf xStart
	VSUBEQ.F32 s30, s1 ;#auf -deltaX setzen um bei bei pixelaufaddierung auf 0 zu kommen

	;#check new line kann nur ausgeführt werden wenn ein pixelbailout exestiert daher erniedrigen wir hier die Anzahl der restlichen Pixel um 1
	SUB r2, r2, #1
	BX lr

;#ende des Programs alte register herstellen und zurück ins c Programm
end: 
	POP {r5}
	POP {r0-r12, lr}
	BX lr


