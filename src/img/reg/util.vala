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
}
