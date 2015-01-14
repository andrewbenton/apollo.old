namespace apollo.img.reg
{
    public interface Xform : Object
    {
        public abstract InterpType interp { get; set; }
        public abstract Volume xform(Volume input);
        public abstract Xform  clone();
        public abstract void   print();
    }
}
