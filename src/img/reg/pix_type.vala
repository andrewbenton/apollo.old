namespace apollo.img.reg
{
    public enum PixType
    {
        UNDEFINED,
        UCHAR,
        UINT16,
        SHORT,
        UINT32,
        INT32,
        FLOAT,
        VF_FLOAT_INTERLEAVED,
        VF_FLOAT_PLANAR,
        UCHAR_VEC_INTERLEAVED;

        public string to_string()
        {
            switch(this)
            {
                case PixType.UNDEFINED:
                    return "UNDEFINED";
                case PixType.UCHAR:
                    return "UCHAR";
                case PixType.UINT16:
                    return "UINT16";
                case PixType.SHORT:
                    return "SHORT";
                case PixType.UINT32:
                    return "UINT32";
                case PixType.INT32:
                    return "INT32";
                case PixType.FLOAT:
                    return "FLOAT";
                case PixType.VF_FLOAT_INTERLEAVED:
                    return "VF_FLOAT_INTERLEAVED";
                case PixType.VF_FLOAT_PLANAR:
                    return "VF_FLOAT_PLANAR";
                case PixType.UCHAR_VEC_INTERLEAVED:
                    return "UCHAR_VEC_INTERLEAVED";
                default:
                    return "<<UNKNOWN>>";
            }
        }
    }
}
