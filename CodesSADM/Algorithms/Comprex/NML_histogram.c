#include "NML_histogram.h"



/*==========================================================================*/



histogram* new_histogram(int nof_bins, double epsilon, double delta)
{
    histogram* hg;

    hg = (histogram*)malloc(sizeof(histogram));

    hg->nof_bins = nof_bins;
    hg->cut = (double*)malloc((hg->nof_bins + 1) * sizeof(double));

    hg->epsilon = epsilon; // data accuracy
    hg->delta = delta; // cut point accuracy

    return hg;
}


void delete_histogram(histogram* hg)
{
    free(hg->cut);
    free(hg);
}


// attr must be sorted (increasing order)
double histogram_NML(histogram* hg, int max_nob, int N, double* attr)
{
    double range;
    int c;
    int nof_pc;
    double* potcut;
    int* H;
    double min, max;
    int j;
    double** BSC;
    int nob;
    int*** BHG;
    int last;
    int bestnob = -1;
    double bestSC;
    int cn;
    double dmin, dmax;

    dmin = attr[0];
    dmax = attr[N - 1];

    min = dmin - hg->epsilon / 2.0;
    max = dmax + hg->epsilon / 2.0;

    range = (max - min) + 1e-10;

    nof_pc = (int)(range / hg->delta) - 1;
    if(nof_pc < 1)
	die("histogram_NML", "No potential cut points", "");

    potcut = (double*)malloc((nof_pc) * sizeof(double));
    H = (int*)malloc((nof_pc + 1) * sizeof(int));

    for(c = 0; c < nof_pc; c++)
	potcut[c] = min + (c + 1) * hg->delta;

    if((nof_pc + 1) < max_nob)
	max_nob = nof_pc + 1;

    j = 0;
    for(c = 0; c < nof_pc; c++)
    {
	H[c] = j;
	while((j < N) && (attr[j] < potcut[c]))
	{
	    H[c]++;
	    j++;
	}
    }
    H[nof_pc] = N;


    // Dynamic programming starts
    BSC = (double**)malloc((nof_pc + 1) * sizeof(double*));
    for(c = 0; c <= nof_pc; c++)
	BSC[c] = (double*)malloc((max_nob + 1) * sizeof(double));

    BHG = (int***)malloc((nof_pc + 1) * sizeof(int**));
    for(c = 0; c <= nof_pc; c++)
    {
	BHG[c] = (int**)malloc((max_nob + 1) * sizeof(int*));

	BHG[c][0] = NULL;
        for(nob = 1; nob <= max_nob; nob++)
	    BHG[c][nob] = (int*)malloc((nof_pc) * sizeof(int));
    }

    for(c = 0; c <= nof_pc; c++)
    {
	double R;

	if(nof_pc == 0)
	    R = max - min;
	else
	    R = (c + 1) * hg->delta;

	BSC[c][0] = HUGE_DOUBLE;
	BSC[c][1] = -(double)H[c] * (log((double)(H[c]) * hg->epsilon) -
				     log((double)N * R));

        for(nob = 1; nob <= max_nob; nob++)
        {
	    int s;
            for(s = 0; s < nof_pc; s++)
		BHG[c][nob][s] = 0;
        }
    }

    last = nof_pc;
    bestnob = 1;
    bestSC = BSC[last][1];
    for(nob = 2; nob <= max_nob; nob++)
    {
	for(c = nob - 1; c <= nof_pc; c++)
	{
            double minSC = HUGE_DOUBLE;
            int mintau = -1;
	    int tau;
	    int s;

            for(tau = nob - 2; tau < c; tau++)
            {
		double SC = 0.0;

		if(H[c] > H[tau])
		{
		    double R;

		    if((c == nof_pc))
			R = max - potcut[tau];
		    else
			R = (double)(c - tau) * hg->delta;
		
		    SC = BSC[tau][nob - 1] - (double)(H[c] - H[tau]) *
			(log((double)(H[c] - H[tau]) * hg->epsilon) -
			 log((double)N * R));
		}
		else if(H[c] == H[tau])
		    SC = BSC[tau][nob - 1];
		else
		    die("histogram_NML", "H[c] < H[tau]", "");

		SC += histogram_szpan(H[c], nob) -
		    histogram_szpan(H[tau], nob - 1);
		SC += log((double)(nof_pc - nob + 2) / (double)(nob - 1));
		
		if(SC < minSC)
		{
		    minSC = SC;
		    mintau = tau;
		}
	    }

	    BSC[c][nob] = minSC;

            for(s = 0; s < nof_pc; s++)
		BHG[c][nob][s] = BHG[mintau][nob - 1][s];

	    BHG[c][nob][mintau] = 1;
	}

	if(BSC[last][nob] < bestSC)
	{
	    bestnob = nob;
	    bestSC = BSC[last][nob];
	}
    }

    
    cn = 1;
    hg->cut[0] = min;
    for(c = 0; c < nof_pc; c++)
    {
	if(BHG[last][bestnob][c] == 1)
	{
	    hg->cut[cn] = potcut[c];
	    cn++;
	}
    }

    if(cn != bestnob)
	die("histogram_NML", "cn != bestnob", "");

    hg->cut[bestnob] = max;
    hg->nof_bins = bestnob;


    free(potcut);
    free(H);

    for(c = 0; c <= nof_pc; c++)
	free(BSC[c]);
    free(BSC);

    for(c = 0; c <= nof_pc; c++)
    {
        for(nob = 1; nob <= max_nob; nob++)
	    free(BHG[c][nob]);
	
	free(BHG[c]);
    }
    free(BHG);

    return bestSC;
}


double histogram_szpan(int N, int K)
{
    double szpan = 0.0;

    if(N == 0 || K == 1)
        return 0.0;

    szpan += (((double)K - 1.0) / 2.0) * log((double)N / 2.0);
    szpan += log(exp(lgamma(0.5)) / exp(lgamma((double)K / 2.0)));
    szpan += (exp(lgamma((double)K / 2.0)) * (double)K * sqrt(2.0)) /
        (3.0 * exp(lgamma((double)K / 2.0 - 0.5)) * sqrt((double)N));
    szpan += ((3.0 + (double)K * ((double)K - 2.0) *
	       (2.0 * (double)K + 1.0)) / 36.0 -
	      (exp(2.0 * lgamma((double)K / 2.0)) * (double)K * (double)K) /
	      (9.0 * exp(2.0 * lgamma((double)K / 2.0 - 0.5)))) / (double)N;

    return szpan;
}


int double_compar(const void* a_ptr, const void* b_ptr)
{
    double a, b;

    a = *((double*)a_ptr);
    b = *((double*)b_ptr);

    if(a < b)
	return -1;
    else if(a > b)
	return 1;
    else
	return 0;
}


boolean is_numeric(char* str, double* val)
{
    char* endptr;
    
    *val = strtod(str, &endptr);

    if(*endptr != 0)
        return false;
    else
        return true;
}


void die(char* mod, char* msg, char* arg)
{
    fprintf(stderr, "[%s]: %s %s\n", mod, msg, arg);
    exit(1);
}


int main(int argc, char** argv)
{
    histogram* hg;
    int max_nof_bins;
    int j;
    double* attr;
    int c;
    double epsilon;
    double delta;
    char* datafile;
    int N;
    FILE* fp;
    char str[1024];
    double d;
    int nd;
    double bestSC;

    if(argc != 5)
    {
        fprintf(stderr,
		"Usage: %s datafile max_nof_bins epsilon delta\n",
		argv[0]);
        exit(1);
    }

    datafile = argv[1];
    max_nof_bins = atoi(argv[2]);
    epsilon = atof(argv[3]);
    delta = atof(argv[4]);

    if(delta < epsilon)
        die("main", "Delta < epsilon", "");

    if((fp = fopen(datafile, "r")) == NULL)
        die("main", "Could not find datafile", datafile);

    N = 0;
    while((nd = fscanf(fp, "%s", str)) != EOF)
    {
	if(is_numeric(str, &d) == true)
            N++;
    }
    rewind(fp);

    //printf("N %d\n", N);
    fflush(stdout);

    attr = (double*)malloc(N * sizeof(double));
    j = 0;
    while((nd = fscanf(fp, "%s", str)) != EOF)
    {
	if(is_numeric(str, &d) == true)
	{
	    attr[j] = floor(d * (1.0 / epsilon) + 0.5) * epsilon;
	    j++;
	}
    }

    qsort(attr, N, sizeof(double), double_compar);

    hg = new_histogram(max_nof_bins, epsilon, delta);
    
    bestSC = histogram_NML(hg, max_nof_bins, N, attr);
    //printf("Optimal value of SC: %10.8f\n", bestSC);

    //printf("Number of bins: %d\n", hg->nof_bins);

    //printf("Cut points:\n");
    FILE *out;
    out = fopen( "cuts.txt", "w" );
    for(c = 0; c <= hg->nof_bins; c++)
      fprintf(out,"%8.6f%c", hg->cut[c], (c == hg->nof_bins) ? '\n' : ' ');

    fclose(out);
    free(attr);

    delete_histogram(hg);

    return 0;
}

