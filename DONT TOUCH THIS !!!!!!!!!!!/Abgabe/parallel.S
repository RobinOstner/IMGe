.global parallel

.code 32

parallel:

;# sichern der benoetigten register
	PUSH {r0-r12, lr}


;#laden der restlichen beiden werte vom stack
	ldr r4, [sp, #56]
	ldr r5, [sp, #60]
	PUSH {r5}
;#berechnen von deltaX, unterschied zwischen 2Pixeln in x Richtung
	SUB r1, r1, r0 ;#xEnd-XStart
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

;#resolution*resolution-4 langlaufen, -4 weil wir ja von anfang an 4 Pixel befuellen
	MUL r2, r1, r1
	SUB r2, r2, #4

;#setup fuer simultane pixelberechnung mit early bailout fuer jeden einzelnen Pixel
;#r3-r6 enhalten die anzahl der bereits durchlaufenen wiederholungen fuer den jeweiligen pixel
	MOV r3, #0
	MOV r4, #0
	MOV r5, #0
	MOV r6, #0

;#r7 enthaelt die maximale Anzahl an erlaubten durchlaufen
	MOV r7, #20

;#r8-r11 beinhalten den zu speichernden pixel
	MOV r8, r0
	ADD r0, #3
	MOV r9, r0
	ADD r0, #3
	MOV r10, r0
	ADD r0, #3
	MOV r11, r0
	ADD r0, #3 ;#r0 enthaelt die adresse zum naechsten Pixel

;#befuellen der fpu register mit den ersten loopzahlen hierbei starten wir bei x y und nich tbei 0 0 lassen also den ersten durchlauf weg

;#s4-s7 beinhalten die x Koordinaten der 4Pixel
	VMOV.F32 s4, s0
	VMOV.F32 s5, s0
	VADD.F32 s5, s1 ;#pixel X Koordinate um 1 erhoehen
	VMOV.F32 s6, s5
	VADD.F32 s6, s1 ;#wiederum um 1 erhoehen
	VMOV.F32 s7, s6
	VADD.F32 s7, s1 ;#wiederum um 1 erhoehen
	;#in s30 speichern wir den naechsten x Wert
	VMOV.F32 s30, s7




;#s8-s11 beinhalten die y Koordinate der 4Pixel
	VMOV.F32 s8, s2
	VMOV.F32 s9, s2
	VMOV.F32 s10, s2
	VMOV.F32 s11, s2

;#q1 und q2 in real und imaginaerteil kopieren, quasi ersten schleifendurchlauf ueberspringen
	VMOV.F32 q3, q1
	VMOV.F32 q4, q2

;#die zahl 4 in s31 speichern, als abbruch wert/schwellwert
	VMOV.F32 s31, #4.0

;#schleife in welcher wir die berechnung durchfuehren
loop:

	;#schleife die solange die Formel durchlaeuft bis ein Pixel rausfaellt

		VMUL.F32 q5, q3, q4 ;#ab
		VADD.F32 q5, q5, q5	;#2ab von (real+ima)^2

		VMUL.F32 q3, q3, q3 ;# real^2
		VMUL.F32 q4, q4, q4 ;# ima^2

		VSUB.F32 q3, q3, q4 ;# real^2-ima^2
		VADD.F32 q3, q3, q1 ;# neuer realteil + real Konstant

		VADD.F32 q4, q5, q2 ;# 2ab + imaginaer Konstante

		;#konvergenzberechnung hier zu ende

		;#ueberpruefen auf pixel bailout
		;#in q5 dafuer auf ueberschreitung der Grenze achten
		VADD.F32 q5, q3, q4 ;# real + ima
		VMUL.F32 q6, q5, q5 ;# quadrieren um negative zahlen einfacher zu behandeln

		;#Pixel 1
		;#auf ueberschreiten der Grenze schauen
		VCMP.F32 s24, s31
		VMRS APSR_nzcv, FPSCR

		;#bei groesser early bailout
		bgt earlybailoutPX1
		cmp r3, r7 ;#hat der Pixel seine maximale Anzahl an durchlaufen erreicht
		bge maxBailoutPX1
jumpPX1:

		;#Pixel2 Vergleich auf bailouts
		VCMP.F32 s25, s31
		VMRS APSR_nzcv, FPSCR
		;#bei groesser early bailout
		bgt earlybailoutPX2
		cmp r4, r7 ;#hat der Pixel seine maximale Anzahl an durchlaufen erreicht
		blge maxBailoutPX2
jumpPX2:

	;#Pixel3 Vergleich auf bailouts
	VCMP.F32 s26, s31
	VMRS APSR_nzcv, FPSCR
	;#bei groesser early bailout
	bgt earlybailoutPX3
	cmp r5, r7 ;#hat der Pixel seine maximale Anzahl an durchlaufen erreicht
	blge maxBailoutPX3
jumpPX3:

	;#Pixel4 Vergleich auf bailouts
	VCMP.F32 s27, s31
	VMRS APSR_nzcv, FPSCR
	;#bei groesser early bailout
	bgt earlybailoutPX4
	cmp r6, r7 ;#hat der Pixel seine maximale Anzahl an durchlaufen erreicht
	blge maxBailoutPX4
jumpPX4:

		;#erhoehen der pixellaufwerte
		ADD r3, r3, #1
		ADD r4, r4, #1
		ADD r5, r5, #1
		ADD r6, r6, #1


	;#loop abbruch bedingung wenn res*res <=0
	CMP r2, #0
	bge loop ;#solange wie groesser gleich 0
	b end ;#zum ende wenn <0

;#
;#PIXEL 1 Funktionen
;#
earlybailoutPX1:
	MOV r12, #255 ;#early bailout fuehrt zu weiss
	STRB r12, [r8] ;#farbwert 1
	ADD r8, r8, #1
	STRB r12, [r8] ;#farbwert 2
	ADD r8, r8, #1
	PUSH {r11} ;# benoetigen 1 weitere register zum rechnen
	MOV r11, #12
	MUL r11, r11, r3
	SUB r12, r12, r11 ;#Grad der konvergenz je spaeter er aussteigt dest groesser wird der rotanteil
	STRB r12, [r8]
	POP {r11}
	b resetPX1

maxBailoutPX1:
	MOV r12, #0 ;#late bailout fuehrt zu schwarz
	STRB r12, [r8]
	ADD r8, r8, #1
	STRB r12, [r8]
	ADD r8, r8, #1
	STRB r12, [r8]
	b resetPX1

resetPX1:
	MOV r3, #-1 ;#Laufzeit zuruecksetzen auf -1 weil anschliessend ja die laufzeit um eines standardmaessig in der sschleife erhoeht wird
	;# neue werte in fpu register schreiben
	;# ueberpruefung auf zeilenumbruch
	bl checkNewLine

	VADD.F32 s30, s1  ;#currentX laufwert um 1 erhoehen
	VMOV.F32 s4, s30 ;#x Wert schreiben
	VMOV.F32 s12, s30 ;#P1 real schreiben
	VMOV.F32 s8, s2 ;#y Wert schreiben
	VMOV.F32 s16, s2 ;#P1 imaginaer schreiben

	;#speicheradresse fuer naechsten pixel erhoehen und setzen
	MOV r8, r0
	ADD r0, r0, #3
	b jumpPX1

	;#
	;#PIXEL 2 Funktionen
	;#
earlybailoutPX2:
	MOV r12, #255 ;#early bailout fuehrt zu weiss
	STRB r12, [r9] ;#farbwert 1
	ADD r9, r9, #1
	STRB r12, [r9] ;#farbwert 2
	ADD r9, r9, #1
	PUSH {r11} ;# benoetigen 1 weitere register zum rechnen
	MOV r11, #12
	MUL r11, r11, r4
	SUB r12, r12, r11 ;#Grad der konvergenz je spaeter er aussteigt dest groesser wird der rotanteil
	STRB r12, [r9]
	POP {r11}
	b resetPX2

	maxBailoutPX2:
		MOV r12, #0 ;#late bailout fuehrt zu schwarz
		STRB r12, [r9]
		ADD r9, r9, #1
		STRB r12, [r9]
		ADD r9, r9, #1
		STRB r12, [r9]
		b resetPX2

	resetPX2:
		MOV r4, #-1 ;#Laufzeit zuruecksetzen auf -1 weil anschliessend ja die laufzeit um eines standardmaessig in der sschleife erhoeht wird
		;# neue werte in fpu register schreiben
		;# ueberpruefung auf zeilenumbruch
		bl checkNewLine

		VADD.F32 s30, s1  ;#currentX laufwert um 1 erhoehen
		VMOV.F32 s5, s30 ;#x Wert schreiben
		VMOV.F32 s13, s30 ;#P1 real schreiben
		VMOV.F32 s9, s2 ;#y Wert schreiben
		VMOV.F32 s17, s2 ;#P1 imaginaer schreiben

		;#speicheradresse fuer naechsten pixel erhoehen und setzen
		MOV r9, r0
		ADD r0, r0, #3
		b jumpPX2

		;#
		;#PIXEL 3 Funktionen
		;#
earlybailoutPX3:
	MOV r12, #255 ;#early bailout fuehrt zu weiss
	STRB r12, [r10] ;#farbwert 1
	ADD r10, r10, #1
	STRB r12, [r10] ;#farbwert 2
	ADD r10, r10, #1
	PUSH {r11} ;# benoetigen 1 weitere register zum rechnen
	MOV r11, #12
	MUL r11, r11, r5
	SUB r12, r12, r11 ;#Grad der konvergenz je spaeter er aussteigt dest groesser wird der rotanteil
	STRB r12, [r10]
	POP {r11}
	b resetPX3

maxBailoutPX3:
	MOV r12, #0 ;#late bailout fuehrt zu schwarz
	STRB r12, [r10]
	ADD r10, r10, #1
	STRB r12, [r10]
	ADD r10, r10, #1
	STRB r12, [r10]
	b resetPX3

resetPX3:
	MOV r5, #-1 ;#Laufzeit zuruecksetzen auf -1 weil anschliessend ja die laufzeit um eines standardmaessig in der sschleife erhoeht wird
	;# neue werte in fpu register schreiben
	;# ueberpruefung auf zeilenumbruch
	bl checkNewLine

	VADD.F32 s30, s1  ;#currentX laufwert um 1 erhoehen
	VMOV.F32 s6, s30 ;#x Wert schreiben
	VMOV.F32 s14, s30 ;#P1 real schreiben
	VMOV.F32 s10, s2 ;#y Wert schreiben
	VMOV.F32 s18, s2 ;#P1 imaginaer schreiben

	;#speicheradresse fuer naechsten pixel erhoehen und setzen
	MOV r10, r0
	ADD r0, r0, #3
	b jumpPX3


				;#
				;#PIXEL 4 Funktionen
				;#
earlybailoutPX4:
	MOV r12, #255 ;#early bailout fuehrt zu weiss
	STRB r12, [r11] ;#farbwert 1
	ADD r11, r11, #1
	STRB r12, [r11] ;#farbwert 2
	ADD r11, r11, #1
	PUSH {r11} ;# benoetigen 1 weitere register zum rechnen
	MOV r11, #12
	MUL r11, r11, r6
	SUB r12, r12, r11 ;#Grad der konvergenz je spaeter er aussteigt dest groesser wird der rotanteil
	POP {r11}
	STRB r12, [r11]
	b resetPX4

maxBailoutPX4:
	MOV r12, #0 ;#late bailout fuehrt zu schwarz
	STRB r12, [r11]
	ADD r11, r11, #1
	STRB r12, [r11]
	ADD r11, r11, #1
	STRB r12, [r11]
	b resetPX4

resetPX4:
	MOV r6, #-1 ;#Laufzeit zuruecksetzen auf -1 weil anschliessend ja die laufzeit um eines standardmaessig in der sschleife erhoeht wird
	;# neue werte in fpu register schreiben
	;# ueberpruefung auf zeilenumbruch
	bl checkNewLine

	VADD.F32 s30, s1  ;#currentX laufwert um 1 erhoehen
	VMOV.F32 s7, s30 ;#x Wert schreiben
	VMOV.F32 s15, s30 ;#P1 real schreiben
	VMOV.F32 s11, s2 ;#y Wert schreiben
	VMOV.F32 s19, s2 ;#P1 imaginaer schreiben

	;#speicheradresse fuer naechsten pixel erhoehen und setzen
	MOV r11, r0
	ADD r0, r0, #3
	b jumpPX4

;#ueberprueft auf zeilenumbruch
checkNewLine:
	PUSH {r0-r4, lr}
	;# wenn r2%res = 0 dann neue zeile also y erhoehen und s30 auf xStart
	MOV r0, r2;# res*res in r0 und in r1 kommt res
	bl __aeabi_uidiv ;# udiv von 2 integern von gcc, da hier udiv oder sdiv nicht unetrstuezt werden
	MOV r12, r0 ;#zurueckschreiben der div in r3
	POP {r0-r4, lr}
	MLS r12, r12, r1, r2
	cmp r12, #0 ;# vergleichen auf zeilenumbruch
	VADDEQ.F32 s2, s2, s3 ;#y um einer erhoehen
	VMOVEQ.F32 s30, s0 ;#zuruecksetzen auf xStart
	VSUBEQ.F32 s30, s1 ;#auf -deltaX setzen um bei bei pixelaufaddierung auf 0 zu kommen

	;#check new line kann nur ausgefuehrt werden wenn ein pixelbailout exestiert daher erniedrigen wir hier die Anzahl der restlichen Pixel um 1
	SUB r2, r2, #1
	BX lr

;#ende des Programs alte register herstellen und zurueck ins c Programm
end:
	POP {r5}
	POP {r0-r12, lr}
	BX lr
