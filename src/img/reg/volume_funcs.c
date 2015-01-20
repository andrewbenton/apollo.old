#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <math.h>

#if (OPENMP_FOUND)
#include <omp.h>
#endif

#include <glib.h>

void apollo_img_reg_simple_diff_cuda(guint64 len, float* da, float* db, float* dr)
{

}

void apollo_img_reg_simple_diff_phi(guint64 len, float* da, float* db, float* dr)
{
    guint64 i;
    int num_threads = g_get_num_processors();
    #pragma omp sections
    {
        #pragma omp section
        {
            #pragma offload target(mic : target_id) mandatory \
            in(len, da : length(len), db : length(len)) \
            out(dr : length(len))
            {
                #pragma omp parallel for \
                num_threads(num_threads) \
                shared(len, da, db, dr)
                for(i = 0; i < len; i++)
                {
                    dr[i] = fabs(da[i] - db[i]);
                }
            }
        }
    }
}

void apollo_img_reg_simple_diff_omp(guint64 len, float* da, float* db, float* dr)
{
#if (FOUND_OPENMP)
printf("diff being run with OMP");
#endif
    guint64 i;
    int num_threads = g_get_num_processors();
    #pragma omp sections
    {
        #pragma omp section
        {
            #pragma omp parallel for \
                num_threads(num_threads) \
                shared(len, da, db, dr)
            for(i = 0; i < len; i++)
            {
                dr[i] = fabs(da[i] - db[i]);
            }
        }
    }
}

void apollo_img_reg_simple_diff_sti(guint64 len, float* da, float* db, float* dr)
{
    guint64 i;
    for(i = 0; i < len; i++)
    {
        dr[i] = fabs(da[i] - db[i]);
    }
}
