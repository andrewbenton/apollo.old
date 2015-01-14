namespace apollo.img.reg
{
    [CCode(cname="exit")]
    public extern void exit(int exit_code);

    public bool little_endian()
    {
        int n = 1;
        int *np = &n;
        char *r = (char*)np;
        return (*r == 1);
    }

    public bool big_endian()
    {
        int n = 1;
        int *np = &n;
        char *r = (char*)np;
        return (*r != 1);
    }

    public float rbf3(uint x, uint y, uint z, float i, float j, float k)
    {
        float r = Math.sqrtf(
            Math.powf(i - (float)x, 2) + 
            Math.powf(j - (float)y, 2) +
            Math.powf(k - (float)z, 2));

        return Math.powf(r, 2) * Math.logf(Math.powf(r, 2));
    }

    void endian2_swap(void* buf, ulong len)
    {
        uint8[] buff = (uint8[])buf;
        uint8   temp = 0;

        for(ulong i = 0; i < len; i++)
        {
            temp = buff[2*i+0];
            buff[2*i+0] = buff[2*i+1];
            buff[2*i+1] = temp;
        }
    }

    void endian2_big_to_native(uint8[] data)
    {
        if(little_endian())
        {
            endian2_swap((void*)data, data.length);
        }
    }

    void endian2_little_to_native(uint8[] data)
    {
        if(big_endian())
        {
            endian2_swap((void*)data, data.length);
        }
    }

    void endian4_swap(void* buf, ulong len)
    {
        uint8[] buff = (uint8[])buf;
        uint8   temp[4] = {0, 0, 0, 0};

        for(ulong i = 0; i < len; i++)
        {
            temp[0] = buff[4*i+0];
            temp[1] = buff[4*i+1];
            temp[2] = buff[4*i+2];
            temp[3] = buff[4*i+3];

            buff[4*i+0] = temp[3];
            buff[4*i+1] = temp[2];
            buff[4*i+2] = temp[1];
            buff[4*i+3] = temp[0];
        }
    }

    void endian4_big_to_native(uint8[] data)
    {
        if(little_endian())
        {
            endian4_swap((void*)data, data.length);
        }
    }

    void endian4_little_to_native(uint8[] data)
    {
        if(big_endian())
        {
            endian4_swap((void*)data, data.length);
        }
    }
}
