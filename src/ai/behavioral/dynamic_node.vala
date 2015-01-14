namespace apollo.ai.behavioral
{
    [CCode(has_target="false")]
    public delegate Node NodeCreationFunction(HashTable<string, string> properties);
    [CCode(has_target="false")]
    public delegate string NodeNameFunction();

    public class DynamicNode
    {
        public string name;
        public NodeCreationFunction ncf;
        public Module mod;

        public void DynamicNode(string file)
        {
            void *temp;
            this.name = null;
            this.ncf  = null;
            this.mod  = Module.open(file, ModuleFlags.BIND_LAZY);

            //return full nulls if this fails
            if(mod == null) return;

            //return full nulls if the name can't be resolved
            if(!mod.symbol("get_name", out temp))
            {
                this.mod  = null;
            }
            var nnf = (NodeNameFunction)temp;
            this.name = nnf();

            //return full nulls if the name can't be resolved
            if(!mod.symbol("create_node", out temp))
            {
                this.mod  = null;
                this.name = null;
            }
            this.ncf = (NodeCreationFunction)temp;
        }
    }
}
