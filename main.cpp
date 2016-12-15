//
// Created by flosp on 26.11.2016.
//
#include <stdio.h>
#include <time.h>
#include <stdlib.h>
#include <cmath>

// TODO: C-Funktion implementieren
// TODO: ASM-Funktion importieren

// TODO: Benchmark-Loop-Funktion implementieren

// TODO: Test-Funktion implementieren


//extern void _asm_do_nothing();


//auflösung und bereich

int main(int argc, char **argv) {
    if (argc >5) {
        //zeitmessung beginn bei erfolgreichen ausführen des Programmes

        //Startzeipunkt setzen
        time_t start;
        time(&start);


        /*
         * @param r_Start, r_End: Realteil start und Ende
         * @param i_STart, i_End: Imaginärteil Start und Ende
         * @param resolution: Auflösung des Bildes am Ende
         */
        unsigned int r_Start, r_End, i_Start, i_End, resolution;




        //Kommandozeilen argument
        if(argc == 6) {
            r_Start = atoi(argv[1]);
            r_End = atoi(argv[2]);
            i_Start= atoi(argv[3]);
            i_End = atoi(argv[4]);
            resolution = atoi(argv[5]);


            /*
             * ToDO evtl flascher Input behandlung
             */
            if(resolution == 0){
                printf("Fehlerhafte Eingabe Programm beendet");
                return -1;
            }

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