namespace apollo.ai.behavioral
{
    public class TreeContext
    {
        public Queue<NodeContext> stack;
        public string root;
        public BehavioralTreeSet bts;
        public int max_iters;

        public TreeContext(BehavioralTreeSet bts, string root, int max_iters)
        {
            this.stack = new Queue<NodeContext>();
            this.root = root;
            this.bts = bts;
            this.max_iters = max_iters;
        }

        public StatusValue run()
        {
            if(this.stack.is_empty())
            {
                this.stack.push_tail(bts[root].create_context());
            }

            int i = 0;
            NodeContext nc = null;
            StatusValue status = StatusValue.SUCCESS; //dummy initial value
            string next = null;
            Node n = null;

            while(this.stack.get_length() > 0 && i++ < this.max_iters)
            {
                nc = this.stack.peek_head();

                status = nc.call(out next);

                switch(status)
                {
                    case StatusValue.SUCCESS:
                    case StatusValue.FAILURE:
                        this.stack.pop_head();
                        if(this.stack.get_length() > 0)
                        {
                            this.stack.peek_head().send(status);
                        }
                        else
                        {
                            return status;
                        }
                        break;
                    case StatusValue.RUNNING:
                        return status;
                    case StatusValue.CALL_DOWN:
                        n = this.bts[next];
                        assert(n != null);
                        this.stack.push_head(n.create_context());
                        break;
                }

            }

            return StatusValue.RUNNING;
        }
    }
}
