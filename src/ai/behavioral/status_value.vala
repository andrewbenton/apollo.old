namespace apollo.ai.behavioral
{
    public enum StatusValue
    {
        SUCCESS,
        FAILURE,
        RUNNING,
        CALL_DOWN;

        public string to_string()
        {
            switch(this)
            {
                case StatusValue.SUCCESS:
                    return "SUCCESS";
                case StatusValue.FAILURE:
                    return "FAILURE";
                case StatusValue.RUNNING:
                    return "RUNNING";
                case StatusValue.CALL_DOWN:
                    return "CALL_DOWN";
                default:
                    return "UNKNOWN";
            }
        }
    }
}
