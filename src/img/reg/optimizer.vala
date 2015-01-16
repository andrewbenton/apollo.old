namespace apollo.img.reg
{
    public interface Optimizer : Object
    {
        /**
         * Determines the score between the two volumes.  Optionally uses landmarks to modify the score.
         *
         * @param a First region to compare.  Order doesn't matter.
         * @param b Second region to compare. Order doesn't matter.
         * @param landmarks_a An optional landmarks parameter to modify the score. These are only for volume a.
         * @param landmarks_b An optional landmarks parameter to modify the score. These are only for volume b.
         * @return The overall score of the comparison
         */
        public abstract float score(Volume a, Volume b, Landmarks? landmarks_a = null, Landmarks? landmarks_b = null);

        /**
         * Attempts to improve upon the previous transformation 'xf' based on the region scores.
         *
         * @param xf The currently used xform
         * @return A new Xform that should hopefully provide a better result
         */
        public abstract Xform improve(Xform xf);

        //public abstract void good();

        //public abstract void bad();
    }
}
