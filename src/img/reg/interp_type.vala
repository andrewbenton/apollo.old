namespace apollo.img.reg 
{
    public enum InterpType
    {
        NEAREST_NEIGHBOR,
        TRILINEAR;

        public string to_string()
        {
            switch(this)
            {
                case InterpType.NEAREST_NEIGHBOR:
                    return "NEAREST_NEIGHBOR";
                case InterpType.TRILINEAR:
                    return "TRILINEAR";
                default:
                    return "<UNKNOWN>";
            }
        }
    }
}
