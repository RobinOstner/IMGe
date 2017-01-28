#include <stdio.h>
#include <stdlib.h>
#include <string.h>


//Linux
#include <time.h>


extern void single(unsigned int r_start, unsigned int r_end, unsigned int i_start, unsigned int i_end, unsigned int res, unsigned char *img);

extern void parallel(unsigned int r_start, unsigned int r_end, unsigned int i_start, unsigned int i_end, unsigned int res, unsigned char *img);

/*
*Speichern eines Arrays in eine BMP-Datei
*/
void createBMP(unsigned char* image_data, int w, int h) {
	FILE *f;

//header und infoheader nach wikipedia definition
	unsigned char bmpfileheader[14] = { 'B','M', 0,0,0,0, 0,0,0,0, 54,0,0,0 };
	unsigned char bmpinfoheader[40] = { 40,0,0,0, 0,0,0,0, 0,0,0,0, 1,0, 24,0 };


	int padSize = (4 - 3 * w % 4) % 4; //wird benötigt bei ungeraden auflösungen
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

//tatsächliches öffnen des files
	f = fopen("baked_Mandelbrot.bmp", "wb");

//die beiden header werden zuerst geschrieben
	fwrite(bmpfileheader, 1, 14, f);
	fwrite(bmpinfoheader, 1, 40, f);

//schreiben des Bildes
	fwrite(image_data, w*h,3, f);
	fclose(f);
}

//sehr genauer Zeitstempel in nanosekunden bereich
double secondes()
{
	struct timespec now;
	clock_gettime(CLOCK_MONOTONIC, &now);
	return now.tv_sec + now.tv_nsec / 1000000000.0;
}

//checked den String auf fehlerhafte eingaben buchstaben oder zeichen nicht zwischen 0 und 9
int invalidInput(char* input) {
	//find out length
	int length = 0;
	while (input[length] != '\0') {
		length++;
	}


	//check for invalid character
	for (int i = 0; i<length; i++) {
		if ((input[i] < '0' || input[i] > '9') && input[i] != '-') {
			return 1;
		}
	}

//auf führende null hin überprüfen führt ansonsten zu fehlern
	if (length>1 && input[0] == '0') {
		return 1;
	}
	return -1;
}

int main(int argc, char **argv)
{

	/*
	* Parsing commandline arguments and checking for valid input
	* @param r_Start, r_End: Realteil start und Ende
	* @param i_STart, i_End: Imagin�rteil Start und Ende
	* @param resolution: Aufl�sung des Bildes am Ende
	*/
	int r_Start = 0, r_End = 0, i_Start = 0, i_End = 0, resolution = 0;

	//Kommandozeilen Argumente Anzahl checken bei flascher Anzahl beenden.
	if (argc == 6) {
		/*starting time tracking
		 *
		 *time1 and time2 makeup total time the program run
		 *time3 and time4 are only for the calculation
		 */
		double time1, time2, time3, time4;
		time1 = secondes();

		/*
		* Parsing command line arguments
		*/
		printf("parsing started\n");

		for (int i = 1; i<6; i++) {

			if (invalidInput(argv[i]) == 1) {
				printf("\nFehlerhafte Eingabe. Bitte geben sie ein /main.c int int int int int. \nProgramm beendet \n");
				return -1;
			}
		}

		r_Start = atoi(argv[1]);
		r_End = atoi(argv[2]);
		i_Start = atoi(argv[3]);
		i_End = atoi(argv[4]);
		resolution = atoi(argv[5]);

		if(r_End < r_Start || i_End < i_Start){
			printf("Achtung das Ende kann nicht vor dem Start liegen\n");
			return -1;
		}

		if(resolution<0){
			printf("Die Auflösung ist negativ, dass ist nicht möglich\n");
			return -1;
		}

		//ueberprüfen ob resolution dem Kriterium 2^n fuer n >= 2 entspricht
		int res_copy = resolution;

		while(res_copy >2){
			res_copy = res_copy / 2;
		}
		if(res_copy != 2){
			printf("Die Auflösung entsrpicht nicht dem Kriterium  2^n fuer n >= 2\n");
			return -1;
		}

		printf("Input of Program:\nr_Start: \t%d\nr_End: \t\t%d\ni_Start: \t%d\ni_End: \t\t%d\nresolution: \t%d\n", r_Start, r_End, i_Start, i_End, resolution);

		printf("Parsing done\n");

		printf("Wolle sie die parallele oder single Version ausfürhen:\n Für parallel bitte 0 eingeben für Single bitte 1\n");

		char choice;
		choice = getchar();
		printf("%d\n", choice);

		if((int) choice != 48 && (int)choice != 49){
			printf("Fehlerhafte Eingabe. Programm bitte neu starten\n");
			return -1;
		}
	/*	while(choice != 'a' || choice != 'b' ){
			printf("Keine 0 oder 1\n");
			scanf("%cs", choice);
		}*/

		/*
		* Starting main task
		*/
		unsigned char* image = malloc(sizeof(unsigned char)*resolution*resolution*3);
		/*
		* Filling image in assembler
		*/

		printf("Starting to calculate Image\n");

		if(choice == '0'){
			printf("Parallel gestartet\n");
			time3 = secondes();
			parallel(r_Start, r_End, i_Start, i_End, resolution, image);
			time4 = secondes();
		}else{
			printf("Single gestartet\n");
			time3 = secondes();
			single(r_Start, r_End, i_Start, i_End, resolution, image);
			time4 = secondes();
	  }
		printf("Ended to calculate Image\n");
		printf("Die Berechnungszeit betrug: %f s\n", time4 - time3);
		/*
		* creating the bmp file
		*/
		printf("Starting to write Data to File\n");
		createBMP(image, resolution, resolution);
		free(image);
		printf("Ended to write Data to File\n");

		/*ending time tracking printing time*/
		time2 = secondes();
		double duration_all = time2 - time1;
		printf("Die Gesamtlaufzeit betrug: %f s\n", duration_all);
	}
	return 0;
}
