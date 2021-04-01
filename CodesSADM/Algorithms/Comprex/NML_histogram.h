#ifndef NML_HISTOGRAM_H
#define NML_HISTOGRAM_H


#include <stdio.h>
#include <stdlib.h>
#include <math.h>


#define HUGE_DOUBLE 1E200;


typedef enum {false, true} boolean;


typedef struct
{
    int nof_bins;
    double* cut;
    double epsilon;
    double delta;
} histogram;


extern histogram* new_histogram(int, double, double);
extern void delete_histogram(histogram*);
extern double histogram_NML(histogram*, int, int, double*);
extern double histogram_szpan(int, int);
extern boolean is_numeric(char*, double*);
extern void die(char*, char*, char*);


#endif
