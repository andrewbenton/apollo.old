namespace apollo.ai.behavioral
{
    public class BehavioralTreeSet
    {
        private HashTable<string, string> tree_map;
        private HashTable<string, Node> node_map;
        
        public BehavioralTreeSet()
        {
            this.tree_map = new HashTable<string, string>(str_hash, str_equal);
            this.node_map = new HashTable<string, Node>(str_hash, str_equal);
        }

        public Node @get(string node_name)
        {
            return this.node_map[node_name];
        }

        public bool contains(string node_name)
        {
            return (this.node_map[node_name] != null);
        }

        public void register_tree(string tree_name, string root)
        {
            this.tree_map[tree_name] = root;
        }
    }
}
