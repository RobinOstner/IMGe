//
// Created by flosp on 26.11.2016.
//
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <limits.h>
#include <cmath>
#include <string>

// TODO: C-Funktion implementieren
// TODO: ASM-Funktion importieren

// TODO: Benchmark-Loop-Funktion implementieren

// TODO: Test-Funktion implementieren


//extern void _asm_do_nothing();

using namespace std;

int exeedLimit(int input){
    if(input<INT_MIN || input>INT_MAX){
        return 1;
    }
    return -1;
}

int invalidInput(char* input){
    //find out length
    int length=0;
    while(input[length]!= NULL){
        length++;
    }

    //check for invalid character
    for(int i=0;i<length;i++){
        if(input[i] < '0' || input[i] > '9'){
            return 1;
        }
    }

    if(input[0]==0 || (input[1] > '0'  && input[1]<='9')){
        return 1;
    }
    return -1;
}

//auflösung und bereich

int main(int argc, char **argv) {
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
        if(argc == 6) {

           for(int i=1;i<6;i++){
               if(invalidInput(argv[i])==1){
                   printf("\nFehlerhafte Eingabe. Bitte geben sie ein /main.c int int int int int. \nProgramm beendet \nErste Stelle");
                   return -1;
               }
           }

            for(int i=1;i<6;i++) {
                char *error = NULL;
                long current = strtol(argv[1], &error, 10);

                if (exeedLimit(current) == 1 || *error != '\0') {
                    printf("\nFehlerhafte Eingabe. Bitte geben sie ein /main.c int int int int int. \nProgramm beendet");
                    return -1;
                }
            }

            r_Start = atoi(argv[1]);
            r_End = atoi(argv[2]);
            i_Start= atoi(argv[3]);
            i_End = atoi(argv[4]);
            resolution = atoi(argv[5]);


            //Wenn res kleiner gleich 0 ist
            if(resolution <= 0){
                printf("\nFehlerhafte Eingabe: Bild sollte hoehere Aufloesung als <=0 haben. Programm beendet");
                return -1;
            }

        }else{
            printf("\nFehlerhafter Programmaufruf Programm beendet");
            return -1;
        }

        /*
         * Calculating Image Size
         */
        int deltaX = r_End - r_Start;
        int deltaY = i_End - i_Start;

        int totalPix = deltaX * deltaY;

        float totalToRes = totalPix /resolution;


        float resX = deltaX / sqrt(totalToRes);
        float resY = deltaY / sqrt(totalToRes);

        char *image = new char[resolution];

        printf("Aufloesung: %d\t%d\t%d\t%lf\t%lf\t%lf\n", deltaX,deltaY,totalPix,resX,resY, resX*resY);


        printf("Input of Program:\nr_Start: \t%d\nr_End: \t\t%d\ni_Start: \t%d\ni_End: \t\t%d\nresolution: \t%d\n", r_Start, r_End, i_Start, i_End, resolution);


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
        printf("\t %s loop_a N RUNS       ASM-Implementation mit Parameter N und RUNS Durchlaeufen ausfuehren\n",
               argv[0]);
        printf("\t %s loop_c N RUNS       C-Implementation mit Parameter N und RUNS Durchlaeufen ausfuehren\n",
               argv[0]);
        printf("\t %s loop_e N RUNS       Ausfuehrung von RUNS leeren Schleifendurchlaeufen (N wird ignoriert)\n",
               argv[0]);
    }

    printf("\n");

    return 0;
}