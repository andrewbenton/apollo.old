namespace apollo.img.reg
{
    public class Volume
    {
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

            this.dim[0] = x;
            this.dim[1] = y;
            this.dim[2] = z;

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

            this.pix_type = PixType.UNDEFINED;
            this.pix_size = -1;

            int tmp = 0;
            int a = 0, b = 0, c = 0;

            float[9] dc = {0, 0, 0, 0, 0, 0, 0, 0, 0};
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

            if(this.pix_size == 4)
            {
                if(big_endian_input) endian4_big_to_native(d_buff);
                else                 endian4_little_to_native(d_buff);
            }
            else
            {
                if(big_endian_input) endian2_big_to_native(d_buff);
                else                 endian2_little_to_native(d_buff);
            }

            const float uint8maxf = (float)uint8.MAX;
            const float shortmaxf = (float)short.MAX;
            short s_temp = 0;
            uint idx = 0;

            switch(this.pix_type)
            {
                case PixType.FLOAT:
                    for(int x = 0; x < this.dim[0]; x++)
                    {
                        for(int y = 0; y < this.dim[1]; y++)
                        {
                            for(int z = 0; z < this.dim[2]; z++)
                            {
                                //this.data[x,y,z] = d_buff[idx];
                                Memory.copy(&this.data[x,y,z], &(d_buff[idx * sizeof(float)]), sizeof(float));
                                idx++;
                            }
                        }
                    }
                    break;
                case PixType.UCHAR:
                    for(int x = 0; x < this.dim[0]; x++)
                    {
                        for(int y = 0; y < this.dim[1]; y++)
                        {
                            for(int z = 0; z < this.dim[2]; z++)
                            {
                                this.data[x,y,z] = ((float)d_buff[idx])/uint8maxf;
                                idx++;
                            }
                        }
                    }
                    break;
                case PixType.SHORT:
                    for(int x = 0; x < this.dim[0]; x++)
                    {
                        for(int y = 0; y < this.dim[1]; y++)
                        {
                            for(int z = 0; z < this.dim[2]; z++)
                            {
                                Memory.copy(&s_temp, &(d_buff[idx * sizeof(short)]), sizeof(short));
                                this.data[x,y,z] = ((float)s_temp) / shortmaxf;
                            }
                        }
                    }
                    break;
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
#if 0
            stdout.printf("ret.step.length = %d\n", ret.step.length);
            stdout.printf("reg.proj.length = %d\n", ret.proj.length);
            stdout.printf("reg.dcos.length = %d\n", ret.dcos.length);
            stdout.printf("this.step.length = %d\n", this.step.length);
            stdout.printf("this.proj.length = %d\n", this.proj.length);
            stdout.printf("this.dcos.length = %d\n", this.dcos.length);
#endif
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

        public void write(string file_name)
        {
            FileStream ios = FileStream.open(file_name, "wb");

            if(ios == null)
            {
                stderr.printf("Volume: Failed to write to %s\n", file_name);
                exit(1);
            }

            string element_type;

            switch(this.pix_type)
            {
                case PixType.UCHAR:
                    element_type = "MET_UCHAR";
                    break;
                case PixType.SHORT:
                    element_type = "MET_SHORT";
                    break;
                case PixType.UINT32:
                    element_type = "MET_UINT";
                    break;
                case PixType.FLOAT:
                    element_type = "MET_FLOAT";
                    break;
                case PixType.VF_FLOAT_INTERLEAVED:
                    element_type = "MET_FLOAT";
                    break;
                default:
                    stderr.printf("Volume: Unhandled type: %s\n", this.pix_type.to_string());
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

            if(this.pix_type == PixType.VF_FLOAT_INTERLEAVED)
            {
                write_volume_data((void*)this.data, sizeof(float), 3 * this.n_pix, ios, true);
            }
            else
            {
                write_volume_data((void*)this.data, this.pix_size, this.n_pix, ios, true);
            }

            ios = null;
        }

        private void write_volume_data(void *buf, size_t size, size_t count, FileStream ios, bool force_little_endian)
        {
            if(big_endian())
            {
                uint8 tmp[4] = {0, 0, 0, 0};
                if(force_little_endian && size > 1)
                {
                    uint8[] buff = (uint8[])buf;
                    if(size == 2)
                    {
                        for(size_t i = 0; i < count; i++)
                        {
                            tmp[0] = buff[2*i+1];
                            tmp[1] = buff[2*i+1];
                            size_t rc = ios.write(tmp, 2);
                            if(rc != 2)
                            {
                                stdout.printf("Volume: file write error (rc = %lu)\n", rc);
                                exit(1);
                            }
                        }
                        return;
                    }
                    else if(size == 4)
                    {
                        for(size_t i = 0; i < count; i++)
                        {
                            //char tmp[4] = { buff[2*i + 3], buff[2*i + 1], buff[2*i + 1], buff[2*i + 0] };
                            tmp[0] = buff[2*i + 3];
                            tmp[1] = buff[2*i + 1];
                            tmp[2] = buff[2*i + 1];
                            tmp[3] = buff[2*i + 0];

                            size_t rc = ios.write(tmp, 4);
                            if(rc != 4)
                            {
                                stdout.printf("Volume: file write error (rc = %lu)\n", rc);
                                exit(1);
                            }
                        }
                        return;
                    }
                    else
                    {
                        stderr.printf("Volume: Cannot save pixel data size of %lu bytes\n", size);
                        exit(1);
                    }
                }
            }
            else
            {
                size_t rc = ios.write((uint8[])buf, size*count);
                if(rc != count)
                {
                    stdout.printf("Volume: file write error (rc = %lu)\n", rc);
                    exit(1);
                }
            }
        }
    }
}
