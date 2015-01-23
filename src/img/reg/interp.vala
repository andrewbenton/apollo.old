namespace apollo.img.reg
{
    public class Interpolate
    {
#if DEBUG
        public static long idx = 0;
#endif

        [CCode(has_target=false)]
        public delegate void interp_func(float[] disp, int[] xyz, Volume input, Volume output);

        public static void nearest_neighbor(float[] disp, int[] xyz, Volume input, Volume output)
        {
            int dest[3] = {0, 0, 0};
            //dest[0] = xyz[0] + (int)Math.floorf(disp[0]);
            //dest[1] = xyz[1] + (int)Math.floorf(disp[1]);
            //dest[2] = xyz[2] + (int)Math.floorf(disp[2]);
            dest[0] = (int)Math.roundf((float)xyz[0] + disp[0]);
            dest[1] = (int)Math.roundf((float)xyz[1] + disp[1]);
            dest[2] = (int)Math.roundf((float)xyz[2] + disp[2]);
            if((dest[0] < 0) || 
               (dest[1] < 0) ||
               (dest[2] < 0) ||
               (dest[0] >= input.dim[0]) ||
               (dest[1] >= input.dim[1]) ||
               (dest[2] >= input.dim[2]))
            {
                output.data[xyz[0], xyz[1], xyz[2]] = 0f;
#if DEBUG
                if((((xyz[0] * input.dim[1] * input.dim[2]) + (xyz[1] * input.dim[2]) + xyz[2]) % 1000000) == 0)
                {
                    stdout.printf("Replacing value %f with %f\n", input.data[xyz[0], xyz[1], xyz[2]], 0f);
                }
#endif
            }
            else
            {
                output.data[xyz[0], xyz[1], xyz[2]] = input.data[dest[0], dest[1], dest[2]];
#if DEBUG
                if((((xyz[0] * input.dim[1] * input.dim[2]) + (xyz[1] * input.dim[2]) + xyz[2]) % 1000000) == 0)
                {
                    stdout.printf("Replacing value %f with %f\n", input.data[xyz[0], xyz[1], xyz[2]], output.data[xyz[0], xyz[1], xyz[2]]);
                }
#endif
            }


        }

        public static void trilinear(float[] disp, int[] xyz, Volume input, Volume output)
        {
            float val = 0f;
            float florf[3] = {0, 0, 0};
            float ceilf[3] = {0, 0, 0};
            int   flori[3] = {0, 0, 0};
            florf[0] = Math.floorf(disp[0]);
            florf[1] = Math.floorf(disp[1]);
            florf[2] = Math.floorf(disp[2]);
            //set values for 
            flori[0] = (int)florf[0];
            flori[1] = (int)florf[1];
            flori[2] = (int)florf[2];
            //properly set the values to be from [0-1]
            florf[0] = disp[0] - florf[0];
            florf[1] = disp[1] - florf[1];
            florf[2] = disp[2] - florf[2];
            ceilf[0] = 1 - florf[0];
            ceilf[1] = 1 - florf[1];
            ceilf[2] = 1 - florf[2];
            //calculate the value
            val += ceilf[0] * ceilf[1] * ceilf[2] * input.data[flori[0]+1, flori[1]+1, flori[2]+1];
            val += ceilf[0] * ceilf[1] * florf[2] * input.data[flori[0]+1, flori[1]+1, flori[2]+0];
            val += ceilf[0] * florf[1] * ceilf[2] * input.data[flori[0]+1, flori[1]+0, flori[2]+1];
            val += ceilf[0] * florf[1] * florf[2] * input.data[flori[0]+1, flori[1]+0, flori[2]+0];
            val += florf[0] * ceilf[1] * ceilf[2] * input.data[flori[0]+0, flori[1]+1, flori[2]+1];
            val += florf[0] * ceilf[1] * florf[2] * input.data[flori[0]+0, flori[1]+1, flori[2]+0];
            val += florf[0] * florf[1] * ceilf[2] * input.data[flori[0]+0, flori[1]+0, flori[2]+1];
            val += florf[0] * florf[1] * florf[2] * input.data[flori[0]+0, flori[1]+0, flori[2]+0];
#if DEBUG
            if((((xyz[0] * input.dim[1] * input.dim[2]) + (xyz[1] * input.dim[2]) + xyz[2]) % 1000000) == 0)
            {
                stdout.printf("Replacing value %f with %f\n", input.data[xyz[0], xyz[1], xyz[2]], val);
            }
#endif
            output.data[xyz[0], xyz[1], xyz[2]] = val;
        }
    }
}
