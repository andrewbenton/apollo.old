namespace apollo.ai.behavioral
{
    public abstract class NodeContext
    {
#if 0
        public abstract void call();

        public abstract StatusValue check(out string next);
#endif

        public abstract StatusValue call(out string next);

        public abstract void send(StatusValue status);
    }
}
