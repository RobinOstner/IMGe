/**
 *
 * ASP Rahmenprogramm
 *
 *
 * 1. Dateiname anpassen
 *   - default.c z.B. in main.c umbenennen
 *       Im Makefile Dateinamen ersetzen nicht vergessen!
 *   - nop.S z.B. in gauss.S umbennen
 *       Im Makefile Dateinamen ersetzen nicht vergessen!
 *   - Um sicherzugehen, dass Ihr Programm kompiliert, tippen Sie in der
 *     Kommandozeile `make`.
 *
 *
 * 2. Rahmenprogramm implementieren
 *   - Siehe Blatt 4, H1
 *
 * 3. Projekt implementieren 
 *   - Implementieren Sie als Platzhalter fuer die
 *     Projektimplementierung den Gauss-Schleifen-Algorithmus oder einen
 *     anderen der behandelten Summationalgorithmen mit Uebergabe der Parameter
 *     auf der Kommandozeile:
 *       1. Implementieren Sie den Algorithmus in C in dieser Datei in
 *          einer Funktion "int gauss_c(int n)" 
 *       2. Implementieren Sie den Algorithmus in
 *          Assembler in Ihrer Assembler-Datei in einer Funktion "_gauss_asm"
 *
 *   - Kommentieren Sie Ihre Implementation, insbesondere den Assembler-Teil!
 *   - Testen Sie Ihre Implementation. Vergleichen Sie dabei die Ergebnisse der
 *     Algorithmus in C, in Assembler, und vorberechnete Referenzwerte!
 *   - Benchmarken Sie die C-Version gegen die Assembler-Version indem Sie den
 *     "time" oder "perf stat -e cycles" Befehl benutzen.
 *   - Die "Usage"-Ausgabe die in der main-Funktion implementiert ist soll
 *     Ihnen als Anregung fuer die Implementierung der verschiedenen
 *     Ausfuehrungsmodi fuer Test und Benchmarking in einem Programm dienen.
 *
**/

#include <stdio.h>

// TODO: C-Funktion implementieren
// TODO: ASM-Funktion importieren

// TODO: Benchmark-Loop-Funktion implementieren

// TODO: Test-Funktion implementieren


int main(int argc, char **argv) {
	printf("\nDefault hello\n\n");

	//TODO: Commandline-Parameter parsen
	if (argc > 1) {

	} else {
		printf("Usage: %s MODE [args...]\n", argv[0]);
		printf("\t %s eval N              Auswertung des Algorithmus mit Parameter N\n", argv[0]);
		printf("\t %s test                Testlauf zur Ueberpruefung der Korrektheit\n", argv[0]);
		printf("\t %s loop_a N RUNS       ASM-Implementation mit Parameter N und RUNS Durchlaeufen ausfuehren\n", argv[0]);
		printf("\t %s loop_c N RUNS       C-Implementation mit Parameter N und RUNS Durchlaeufen ausfuehren\n", argv[0]);
		printf("\t %s loop_e N RUNS       Ausfuehrung von RUNS leeren Schleifendurchlaeufen (N wird ignoriert)\n", argv[0]);
	}

	printf("\n");

	return 0;
}
