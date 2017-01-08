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
#include <time.h>
#include <stdlib.h>
#include <limits.h>
#include <math.h>
#include <string.h>

// TODO: C-Funktion implementieren
// TODO: ASM-Funktion importieren

// TODO: Benchmark-Loop-Funktion implementieren

// TODO: Test-Funktion implementieren
using namespace std;

extern void mandelbrot(unsigned int r_start, unsigned int r_end, unsigned int i_start, unsigned int i_end, unsigned int res, unsigned char *img);

int exeedLimit(int input) {
	if (input<INT_MIN || input>INT_MAX) {
		return 1;
	}
	return -1;
}

int invalidInput(char* input) {
	//find out length
	int length = 0;
	while (input[length] != '\0') {
		length++;
	}

	//check for invalid character
	for (int i = 0; i<length; i++) {
		if (input[i] < '0' || input[i] > '9') {
			return 1;
		}
	}

	if (input[0] == 0 && (input[1] > '0'  && input[1] <= '9')) {
		return 1;
	}
	return -1;
}



void createBMP(unsigned char* image_data, int w, int h) {
	FILE *f;





	unsigned char bmpfileheader[14] = { 'B','M', 0,0,0,0, 0,0,0,0, 54,0,0,0 };
	unsigned char bmpinfoheader[40] = { 40,0,0,0, 0,0,0,0, 0,0,0,0, 1,0, 24,0 };
	unsigned char bmpcontent[3] = { 255,0,0 };
	unsigned char bmppad[1] = { 0 };

	int padSize = (4 - 3 * w % 4) % 4;
	int sizeData = w*h * 3 + h*padSize;
	int filesize = sizeData + sizeof(bmpfileheader) + sizeof(bmpinfoheader);

	/* Construct header with filesize part */
	bmpfileheader[2] = (unsigned char)(filesize);
	bmpfileheader[3] = (unsigned char)(filesize >> 8);
	bmpfileheader[4] = (unsigned char)(filesize >> 16);
	bmpfileheader[5] = (unsigned char)(filesize >> 24);

	bmpinfoheader[4] = (unsigned char)(w);
	bmpinfoheader[5] = (unsigned char)(w >> 8);
	bmpinfoheader[6] = (unsigned char)(w >> 16);
	bmpinfoheader[7] = (unsigned char)(w >> 24);
	bmpinfoheader[8] = (unsigned char)(h);
	bmpinfoheader[9] = (unsigned char)(h >> 8);
	bmpinfoheader[10] = (unsigned char)(h >> 16);
	bmpinfoheader[11] = (unsigned char)(h >> 24);

	bmpfileheader[20] = (unsigned char)(sizeData);
	bmpfileheader[21] = (unsigned char)(sizeData >> 8);
	bmpfileheader[22] = (unsigned char)(sizeData >> 16);
	bmpfileheader[23] = (unsigned char)(sizeData >> 24);

	f = fopen("baked_Mandelbrot.bmp", "wb");
	fwrite(bmpfileheader, 1, 14, f);
	fwrite(bmpinfoheader, 1, 40, f);


	//jede reihe muss ein vielfaches von 4 sein, beim speichern 1 reihe in den buffer schreiben
	//anschließend über reihe iterieren und schreiben und mit paddding auffüllen

	//gesamtanzahl an sample punkten = länge array
	//xRes = width, yRes = height

	// array in assemblee von oben links nach unten rechts befüllen
	int i, j;
	for (i = w*(h - 1); i >= 0; i = i - w) {
		//i gibt startpunkt in array

		//j iteriet über die Zeile
		for (j = 0; j<w; j++) {
			bmpcontent[0] = (int)(255 * (image_data[i + j] - 48) / (float)9);
			bmpcontent[1] = (int)(255 * (image_data[i + j] - 48) / (float)9);
			bmpcontent[2] = (int)(255 * (image_data[i + j] - 48) / (float)9);
			fwrite(bmpcontent, 1, 3, f);
		}

		//insert padding

		//bmppad evtl auf 1 anhängen
		for (int x = padSize; x>0; x--) {
			fwrite(bmppad, 1, 1, f);
		}
	}



	fclose(f);
}

int main(int argc, char **argv) {
	
	//TODO: Commandline-Parameter parsen
	if (argc >0) {
		//zeitmessung beginn bei erfolgreichen ausführen des Programmes
		//Startzeipunkt setzen
		time_t start;
		time(&start);


		/*
		* Parsing commandline arguments and checking for valid input
		* @param r_Start, r_End: Realteil start und Ende
		* @param i_STart, i_End: Imaginärteil Start und Ende
		* @param resolution: Auflösung des Bildes am Ende
		*/
		int r_Start, r_End, i_Start, i_End, resolution;

		//Kommandozeilen Argumente Anzahl checken bei flascher Anzahl beenden.
		if (argc == 6) {

			printf("parsing started\n");


			for (int i = 1; i<6; i++) {

				if (invalidInput(argv[i]) == 1) {
					printf("\nFehlerhafte Eingabe. Bitte geben sie ein /main.c int int int int int. \nProgramm beendet \nErste Stelle");
					return -1;
				}
			}

			for (int i = 1; i<6; i++) {

				char *error = NULL;
				long current;

				if (atoi(argv[i]) != 0) {
					current = strtol(argv[1], &error, 10);
				}

				if (exeedLimit(current) == 1 || *error != '\0') {
					printf("\nFehlerhafte Eingabe. Bitte geben sie ein /main.c int int int int int. \nProgramm beendet");
					return -1;
				}
			}

			r_Start = atoi(argv[1]);
			r_End = atoi(argv[2]);
			i_Start = atoi(argv[3]);
			i_End = atoi(argv[4]);
			resolution = atoi(argv[5]);


			//Wenn res kleiner gleich 0 ist
			if (resolution <= 0) {
				printf("\nFehlerhafte Eingabe: Bild sollte hoehere Aufloesung als <=0 haben. Programm beendet");
				return -1;
			}

		}
		else {
			printf("\nFehlerhafter Programmaufruf Programm beendet");
			return -1;
		}


		unsigned char image[resolution*resolution]; // = new unsigned char[resolution*resolution];

		printf("Input of Program:\nr_Start: \t%d\nr_End: \t\t%d\ni_Start: \t%d\ni_End: \t\t%d\nresolution: \t%d\n", r_Start, r_End, i_Start, i_End, resolution);

		printf("Parsing done\n");
		printf("Starting to calculate Image");

		/*
		* Filling image with asm Method
		*/
		mandelbrot(r_Start, r_End, i_Start, i_End, resolution, image);


		/*
		* Creating BMP FILE
		*/
		createBMP(image, resolution, resolution);

		//Endzeit des algorithmus
		time_t end;
		time(&end);
		//berechnen der Zeitdifferenz
		start = end - start;
		printf("Das Programm lief %d s", start);

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
