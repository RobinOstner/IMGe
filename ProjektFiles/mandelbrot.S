;# TODO: Sinnvoller Funktionsname
.globl mandelbrot

.code 32

;# TODO: Funktionsparameter und Rueckgabewert dokumentieren
mandelbrot:  ;# TODO: Stackframe erstellen
  
  PUSH {r4-r10, lr}

  ;# Werteunterschied zwischen zwei Bildpunkte berechnen
  
  ;# Verschieben von resolution und umwandluing in float
  VMOV s0, r4
  VCVT.F32.U32 s0, s0

  ;# Verschieben von r_Start und i_end für schleifen beginn
  VMOV s3, r0
  VMOV s4, r3
  VCVT.F32.U32 s3, s3
  VCVT.F32.U32 s4, s4

  ;# s1 enthaelt dabei xstride und s2 enthält stride y also unterschied x richtung und y richtung
  ;# stride x Richtung
  SUB r9, r1, r0
  VMOV s1, r9
  VCVT.F32.U32 s1, s1
  VDIV.F32 s1, s1, s0
    
  ;# stride y Richtung
  SUB r8, r3, r2
  VMOV s2, r8
  VCVT.F32.U32 s2, s2
  VDIV.F32 s2, s2, s0

  ;# Schleife über den Imaginärteil entalng der Y achse
schleifeY:
	;# Schleifen abbruch überprüfen
	VCVT.U32.F32 s5, s4
	VMOV r6, s5
	CMP r6, r2
	beq end

   ;#Schleife über den Realteil entlang der xAchse
schleifeX:
	;# Schleifen abbruch überprüfen
	VCVT.U32.F32 s5, s3
	VMOV r7, s5
	CMP r7, r1
	beq xEnd

	;#Konvergenz an der Stelle Berechnen Zahl zwischen 0 und 9 basierend auf dem Konvergenzgrad
	;#evtl davor alles auf stack sichern um oli platz für berechnung zu geben
	MOV r10, #0
	VMOV s6, r10
	VCVT.F32.U32 s6, s6

	;#Konvertieren in integer zwischen 0 und 9 verschieben in r und von dort aus speichern in Array
	VCVT.U32.F32 s5, s6
	VMOV r10, s5
	STR r10, [r5]
	ADD r5, r5, #4

	;# erhoehen des laufwerts
	VADD.F32 s3, s3, s1 
	b schleifeX




xEnd:
	;# y um einen stride erhöhen und wieder bei y weitermachen
	VSUB.F32 s4, s4, s2
	b schleifeY


  
end:
  ;# TODO: Stack wiederherstellen
  BX lr
