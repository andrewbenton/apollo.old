namespace apollo.img.reg
{
    public class Volume
    {

#if USE_CUDA
        [CCode(has_target="false", cname="apollo_img_reg_simple_diff_cuda")]
        private static extern void apollo_img_reg_simple_diff_cuda(int64 len, float* da, float* db, float* dr);
#endif

#if USE_PHI
        [CCode(has_target="false", cname="apollo_img_reg_simple_diff_phi")]
        private static extern void apollo_img_reg_simple_diff_phi(int64 len, float* da, float* db, float* dr);
#endif

#if USE_OMP
        [CCode(has_target="false", cname="apollo_img_reg_simple_diff_omp")]
        private static extern void apollo_img_reg_simple_diff_omp(int64 len, float* da, float* db, float* dr);

#endif

        [CCode(cname="apollo_img_reg_simple_diff_sti")]
        private static extern void apollo_img_reg_simple_diff_sti(int64 len, float* da, float* db, float* dr);

        public float[,,] data;

        public int[] dim;
        public float[] offset;
        public float[] spacing;

        public float[] step;
        public float[] proj;

        public ulong n_pix;
        public ulong pix_size;

        public PixType pix_type;

        public float[] dcos;
        public bool has_dcos = false;

        public Volume(int x, int y, int z)
        {
            this.dim = new int[3];
            this.offset = new float[3];
            this.spacing = new float[3];
            this.step = new float[9];
            this.proj = new float[9];
            this.dcos = new float[9];
            {
                for(int i = 0; i < this.dcos.length; i++) this.dcos[i] = 0;
                this.dcos[0] = 1;
                this.dcos[4] = 1;
                this.dcos[8] = 1;
            }

            this.dim[0] = x;
            this.dim[1] = y;
            this.dim[2] = z;

            this.n_pix = this.dim[0] * this.dim[1] * this.dim[2];

            this.data = new float[this.dim[0], this.dim[1], this.dim[2]];
        }

        public Volume.from_mha(string file_name)
        {
            this.dim = new int[3];
            this.offset = new float[3];
            this.spacing = new float[3];
            this.step = new float[9];
            this.proj = new float[9];
            this.dcos = new float[9];
            {
                //set default dcos values
                for(int i = 0; i < this.dcos.length; i++) this.dcos[i] = 0;
                this.dcos[0] = 1;
                this.dcos[4] = 1;
                this.dcos[8] = 1;
            }

            this.pix_type = PixType.UNDEFINED;
            this.pix_size = -1;

            int tmp = 0;
            int a = 0, b = 0, c = 0;

            float[9] dc = {1, 0, 0, 0, 1, 0, 0, 0, 1};
            bool have_dcos = false;

            bool big_endian_input = false;

            //set defaults
            this.data = new float[this.dim[0], this.dim[1], this.dim[2]];
            //now read the actual data
            FileStream ios = FileStream.open(file_name, "rb");

            if(ios == null)
            {
                stderr.printf("Volume: Cannot locate file: %s\n", file_name);
                exit(1);
            }

            string line;

            //while there is a line to read
            while((line = ios.read_line()) != null)
            {
                line._strip(); //trim in place
                if(line == null) continue;

#if DEBUG
                stdout.printf("Volume: line = \"%s\"\n", line);
#endif

                if("ElementDataFile = LOCAL" == line) break;
                if(line.scanf("DimSize = %d %d %d", &a, &b, &c) == 3) 
                {
                    this.dim[0] = a;
                    this.dim[1] = b;
                    this.dim[2] = c;
                    this.n_pix = (ulong)this.dim[0] * (ulong)this.dim[1] * (ulong)this.dim[2];
                    continue;
                }
                if(line.scanf("Offset = %g %g %g", &this.offset[0], &this.offset[1], &this.offset[2]) == 3) continue;
                if(line.scanf("ElementSpacing = %g %g %g", &this.spacing[0], &this.spacing[1], &this.spacing[2]) == 3) continue;
                if(line.scanf("TransformMatrix = %g %g %g %g %g %g %g %g %g", &dc[0], &dc[3], &dc[6], &dc[1], &dc[4], &dc[7], &dc[2], &dc[5], &dc[8]) == 9)
                {
                    have_dcos = true;
                    continue;
                }
                if(line.scanf("ElementNumberOfChannels = %d", &tmp) == 1) 
                {
#if DEBUG
                    stdout.printf("Volume: using Interleaved element type\n");
#endif
                    if(this.pix_type == PixType.UNDEFINED || this.pix_type == PixType.FLOAT) 
                    {
                        this.pix_type = PixType.VF_FLOAT_INTERLEAVED;
                        this.pix_size = 3 * sizeof(float);
                        stdout.printf("Refusing to handle VF_FLOAT_INTERLEAVED.  Exiting...\n");
                        exit(1);
                    }
                    continue;
                }
                if(line == "ElementType = MET_FLOAT")
                {
#if DEBUG
                    stdout.printf("Volume: using ElementType = MET_FLOAT\n");
#endif
                    if(this.pix_type == PixType.UNDEFINED)
                    {
                        this.pix_type = PixType.FLOAT;
                        this.pix_size = sizeof(float);
                    }
                    continue;
                }
                if(line == "ElementType = MET_SHORT")
                {
#if DEBUG
                    stdout.printf("Volume: using ElementType = MET_SHORT\n");
#endif
                    if(this.pix_type == PixType.UNDEFINED)
                    {
                        this.pix_type = PixType.SHORT;
                        this.pix_size = sizeof(short);
                    }
                    continue;
                }
                if(line == "ElementType = MET_UCHAR")
                {
#if DEBUG
                    stdout.printf("Volume: using ElementType = MET_UCHAR\n");
#endif
                    this.pix_type = PixType.UCHAR;
                    this.pix_size = sizeof(uint8);
                    stdout.printf("Refusing to handle UCHAR.  Exiting...\n");
                    exit(1);
                    continue;
                }
                if(line == "BinaryDataByteOrderMSB = TRUE")
                {
                    big_endian_input = true;
                }
            }

            if(this.has_dcos)
            {
                for(int i = 0; i < 9; i++)
                    this.dcos[i] = dc[i];
            }

            if(this.pix_size < 1)
            {
                stdout.printf("Unable to interpret this mha data\n");
                stdout.printf("Exiting...\n");
                exit(1);
            }

            this.data = new float[this.dim[0], this.dim[1], this.dim[2]];
            size_t bytes_read = 0;

            uint8[] d_buff = new uint8[this.n_pix * this.pix_size];
            if((bytes_read = ios.read(d_buff, this.pix_size)) != this.n_pix)
            {
                stderr.printf("Volume.from_mha: Unexpected early end of volume data.\n");
                stderr.printf("\tExpected: %llu elements, Received: %llu\n\tExiting...\n", this.n_pix, (ulong)bytes_read);
                exit(1);
            }

            if(big_endian_input ^ big_endian())
            {
                stdout.printf("DOING BIG <-> LITTLE swap.  Current format is %s\n", big_endian() ? "BIG" : "LITTLE");
                if(this.pix_size == 4) endian4_swap((uint8*)d_buff, d_buff.length);
                else if(this.pix_size == 2) endian2_swap((uint8*)d_buff, d_buff.length);
            }

            const float uint8maxf = (float)uint8.MAX;
            short s_temp = 0;
            uint idx = 0;
            uint stride = 0;
#if DEBUG
            const uint show_gap = 1000000;
            short s_min_value = short.MAX;
            short s_max_value = short.MIN;
#endif

            switch(this.pix_type)
            {
                // IEEE float
                case PixType.FLOAT:
                    stride = (uint)sizeof(float);
                    for(int z = 0; z < this.dim[2]; z++)
                    {
                        for(int y = 0; y < this.dim[1]; y++)
                        {
                            for(int x = 0; x < this.dim[0]; x++)
                            {
                                Memory.copy(&this.data[x,y,z], &(d_buff[idx * sizeof(float)]), sizeof(float));
#if DEBUG
                                if(idx % show_gap == 0)
                                {
                                    stdout.printf("Volume[%4d,%4d,%4d] = %f , %f\n", x, y, z, this.data[x,y,z], this.data[x,y,z]);
                                }
#endif
                                idx += stride;
                            }
                        }
                    }
                    break;
                //unsigned 8 bit int
                case PixType.UCHAR:
                    stride = (uint)sizeof(uint8);
                    for(int z = 0; z < this.dim[2]; z++)
                    {
                        for(int y = 0; y < this.dim[1]; y++)
                        {
                            for(int x = 0; x < this.dim[0]; x++)
                            {
                                this.data[x,y,z] = ((float)d_buff[idx])/uint8maxf;
#if DEBUG
                                if(idx % show_gap == 0)
                                {
                                    stdout.printf("Volume[%4d,%4d,%4d] = %f , %x\n", x, y, z, this.data[x,y,z], d_buff[idx]);
                                }
#endif
                                idx += stride;
                            }
                        }
                    }
                    break;
                //signed 16bit int
                case PixType.SHORT:
                    stride = (uint)sizeof(short);
                    short *s_buff = (short*)d_buff;
                    for(int z = 0; z < this.dim[2]; z++)
                    {
                        for(int y = 0; y < this.dim[1]; y++)
                        {
                            for(int x = 0; x < this.dim[0]; x++)
                            {
                                s_temp = (short)(d_buff[idx+0] << 0) | (short)(d_buff[idx+1] << 8);

                                this.data[x,y,z] = (float)(s_buff[idx / stride]);

#if DEBUG
                                if(idx % show_gap == 0)
                                {
                                    stdout.printf("Volume[%4d,%4d,%4d] = %f , %d\n", x, y, z, this.data[x,y,z], s_temp);
                                }

                                if(s_temp < s_min_value) s_min_value = s_temp;
                                if(s_temp > s_max_value) s_max_value = s_temp;
#endif
                                idx += stride;
                            }
                        }
                    }
#if DEBUG
                    stdout.printf("Volume: s_min_value: %d\nVolume: s_max_value: %d\n", s_min_value, s_max_value);
#endif
                    break;
                //something else, IDFC for now
                default:
                    stderr.printf("Volume.from_mha: Unhandled PixType.%s\nExiting...\n", this.pix_type.to_string());
                    exit(1);
                    break;
            }

            ios = null;
        }

        public Volume meta_clone()
        {
            Volume ret = new Volume(this.dim[0], this.dim[1], this.dim[2]);
            ret.n_pix = this.n_pix;
            ret.pix_size = this.pix_size;
            ret.has_dcos = this.has_dcos;
            ret.pix_type = this.pix_type;
            for(int d = 0; d < 3; d++)
            {
                //ret.dim[d] = this.dim[d];
                ret.offset[d] = this.offset[d];
                ret.spacing[d] = this.spacing[d];
            }
            for(int i = 0; i < 9; i++)
            {
                ret.step[i] = this.step[i];
                ret.proj[i] = this.proj[i];
                ret.dcos[i] = this.dcos[i];
            }
            return ret;
        }

        public static Volume diff(Volume a, Volume b)
        {
            assert(a.dim[0] == b.dim[0] && a.dim[1] == b.dim[1] && a.dim[2] == b.dim[2]);

            var res = a.meta_clone();

            int64 len = a.dim[0] * a.dim[1] * a.dim[2];

            //create dim for passing to OMP/PHI/CUDA
            int[] dim = new int[3];
            for(int i = 0; i < 3; i++) dim[i] = a.dim[i];

            //create simple pointers for OMP/PHI/CUDA
            float *da = (float*)a.data;
            float *db = (float*)b.data;
            float *dr = (float*)res.data;

#if USE_CUDA
            apollo_img_reg_simple_diff_cuda(len, da, db, dr);
#elif USE_PHI
            apollo_img_reg_simple_diff_phi(len, da, db, dr);
#elif USE_OMP
            apollo_img_reg_simple_diff_omp(len, da, db, dr);
#else
            apollo_img_reg_simple_diff_sti(len, da, db, dr);
#endif

            return res;
        }

        public void write(string file_name)
        {
            FileStream ios = FileStream.open(file_name, "wb");

            if(ios == null)
            {
                stderr.printf("Volume: Failed to write to %s\n", file_name);
                exit(1);
            }

            string element_type = "MET_FLOAT";
            switch(this.pix_type)
            {
                case PixType.UCHAR:
                    element_type = "MET_UCHAR";
                    break;
                case PixType.SHORT:
                    element_type = "MET_SHORT";
                    break;
                //case PixType.UINT32:
                //    element_type = "MET_UINT";
                //    break;
                case PixType.FLOAT:
                    element_type = "MET_FLOAT";
                    break;
                //case PixType.VF_FLOAT_INTERLEAVED:
                //    element_type = "MET_FLOAT";
                //    break;
                default:
                    stderr.printf("Volume: Unhandled type: %s. Exiting...\n", this.pix_type.to_string());
                    exit(1);
                    return;
            }

            ios.printf("ObjectType = Image\nNDims = 3\nBinaryData = True\nBinaryDataByteOrderMSB = False\nTransformMatrix = %g %g %g %g %g %g %g %g %g\nOffset = %g %g %g\nCenterOfRotation = 0 0 0\nElementSpacing = %g %g %g\nDimSize = %d %d %d\nAnatomicalOrientation = RAI\n%sElementType = %s\nElementDataFile = LOCAL\n", 
                    this.dcos[0], this.dcos[1], this.dcos[2], this.dcos[3], this.dcos[4], this.dcos[5], this.dcos[6], this.dcos[7], this.dcos[8], 
                    this.offset[0], this.offset[1], this.offset[2],
                    this.spacing[0], this.spacing[1], this.spacing[2],
                    this.dim[0], this.dim[1], this.dim[2],
                    ((this.pix_type == PixType.VF_FLOAT_INTERLEAVED) ? "ElementNumberOfChannels = 3\n" : ""),
                    element_type);

            ios.flush();

            uint8[] converted_data = convert_data();

            write_volume_data(converted_data, ios);

            ios = null;
        }

        //convert data from vala [x,y,z] to mha [z,y,x] and size
        private uint8[] convert_data()
        {
            int x, y, z;
            ulong odo = 0; //One D Offset
            uint8[] ret;
            uint8 uchar_val;
            short short_val;
            float float_val;

            //uint8 buff[4] = {0, 0, 0, 0}; //copy data to this before moving to uint8 ret array
            switch(this.pix_type)
            {
                //8 bit unsigned int
                case PixType.UCHAR:
                    ret = new uint8[this.n_pix * sizeof(uint8)];
                    for(z = 0; z < this.dim[2]; z++)
                    {
                        for(y = 0; y < this.dim[1]; y++)
                        {
                            for(x = 0; x < this.dim[0]; x++)
                            {
                                //convert to uint8
                                uchar_val = (uint8)(this.data[x,y,z] * uint8.MAX);
                                Memory.copy(&(ret[odo]), &uchar_val, sizeof(uint8));
#if DEBUG
                                if((odo / this.pix_size) % 1000000 == 0)
                                {
                                    stdout.printf("[%4d,%4d,%4d] = %5.3f, 0x%2x\n", x, y, z, this.data[x,y,z], uchar_val);
                                }
#endif
                                odo += sizeof(uint8);
                            }
                        }
                    }
                    break;
                //16 bit signed int
                case PixType.SHORT:
                    ret = new uint8[this.n_pix * sizeof(short)];
                    for(z = 0; z < this.dim[2]; z++)
                    {
                        for(y = 0; y < this.dim[1]; y++)
                        {
                            for(x = 0; x < this.dim[0]; x++)
                            {
                                if(this.data[x,y,z] < 0.5f)
                                {
                                    short_val = short.MIN + (short)(this.data[x,y,z] * short.MAX);
                                }
                                else
                                {
                                    short_val = (short)((this.data[x,y,z] - 0.5f) * 2 * short.MAX);
                                }
                                Memory.copy(&(ret[odo]), &short_val, sizeof(short));
#if DEBUG
                                if((odo / this.pix_size) % 1000000 == 0)
                                {
                                    stdout.printf("[%4d,%4d,%4d] = %5.3f, %5d\n", x, y, z, this.data[x,y,z], short_val);
                                }
#endif
                                odo += sizeof(short);
                            }
                        }
                    }
                    break;
                case PixType.FLOAT:
                    ret = new uint8[this.n_pix * sizeof(float)];
                    for(z = 0; z < this.dim[2]; z++)
                    {
                        for(y = 0; y < this.dim[1]; y++)
                        {
                            for(x = 0; x < this.dim[0]; x++)
                            {
                                float_val = this.data[x,y,z];
                                Memory.copy(&(ret[odo]), &float_val, sizeof(float));
#if DEBUG
                                if((odo / this.pix_size) % 1000000 == 0)
                                {
                                    stdout.printf("[%4d,%4d,%4d] = %5.3f\n", x, y, z, this.data[x,y,z]);
                                }
#endif
                                odo += sizeof(float);
                            }
                        }
                    }
                    break;
                default:
                    stderr.printf("Volume.write: Unhandled type.  Cannot convert to: %s. Exiting...\n", this.pix_type.to_string());
                    exit(1);
                    return new uint8[4]; //unreachable
                    //break;
            }

            return ret;
        }

        private void write_volume_data(uint8[] data, FileStream ios)
        {
            //swap if needed, only if the system is big endian
            if(big_endian())
            {
                if(this.pix_size == 2)
                {
                    endian2_swap((void*)data, data.length);
                }
                else if(this.pix_size == 4)
                {
                    endian4_swap((void*)data, data.length);
                }
                else
                {
                    stderr.printf("Volume.write: Unhandled pixel size: %lu.  Exiting...\n", this.pix_size);
                    exit(1);
                }
            }

#if DEBUG
            stdout.printf("Volume.write: Size of binary to write: %ul\n", data.length);
#endif

            ios.write(data);
        }
    }
}
