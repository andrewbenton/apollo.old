namespace apollo.ai.behavioral
{
    public abstract class Node
    {
        public abstract bool configure();

        public abstract HashTable<string, string> properties { get; set; }

        public abstract NodeContext create_context();
    }
}
