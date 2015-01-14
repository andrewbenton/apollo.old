namespace apollo.img.reg
{
    public class Params
    {
        public string static_fn = null;
        public string moving_fn = null;
        public int[] region_size = null;
        public int max_iters;
        public int max_depth;
        public bool debug;
        public float tolerance;
        public float randomize;
        public string output_fn = null;
        public string outvec_fn = null;
        public string xform = null;
        public string landmarks_a = null;
        public string landmarks_b = null;
        public bool gui;

        public bool valid
        {
            get
            {
                if(this.static_fn == null) return false;
                if(this.moving_fn == null) return false;
                if(this.output_fn == null) return false;
                if(this.outvec_fn == null) return false;
                if(this.region_size.length != 3) return false;
                if(this.region_size[0] < 1 || this.region_size[1] < 1 || this.region_size[2] < 1) return false;
                if(this.tolerance <= 0) return false;
                if(this.randomize < 0 || this.randomize > 1) return false;
                if(this.max_iters <= 0) return false;
                if((this.landmarks_a == null && this.landmarks_b != null) || (this.landmarks_a != null && this.landmarks_b == null)) return false;
                return true;
            }
        }

        public Params(string[] args)
        {
            this.region_size = new int[3];
            this.region_size[0] = 1;
            this.region_size[1] = 1;
            this.region_size[2] = 1;
            this.tolerance = 0.95f;
            this.randomize = 0.95f;
            this.max_iters = 100; //default
            this.xform = "tps";
            this.debug = false;
            this.max_depth = 1;
            this.landmarks_a = null;
            this.landmarks_b = null;
            this.gui = false;

            int[] rgn_tmp = new int[3];
            int64 tmp_i64 = 0;
            double tmp_dbl = 0;

            for(int i = 1; i < args.length; i++)
            {
                switch(args[i])
                {
                    case "-s":
                    case "--static":
                        i++;
                        if(i < args.length) this.static_fn = args[i];
                        break;
                    case "-m":
                    case "--moving":
                        i++;
                        if(i < args.length) this.moving_fn = args[i];
                        break;
                    case "-r":
                    case "--regions":
                        i++;
                        if(i < args.length)
                        {
                            if(args[i].scanf("%d,%d,%d", &rgn_tmp[0], &rgn_tmp[1], &rgn_tmp[2]) == 3)
                            {
                                this.region_size[0] = rgn_tmp[0];
                                this.region_size[1] = rgn_tmp[1];
                                this.region_size[2] = rgn_tmp[2];
                            }
                        }
                        break;
                    case "-i":
                    case "--max-iters":
                        i++;
                        if(i < args.length) if(int64.try_parse(args[i], out tmp_i64)) this.max_iters = (int)tmp_i64;
                        break;
                    case "-t":
                    case "--tolerance":
                        i++;
                        if(i < args.length) if(double.try_parse(args[i], out tmp_dbl)) this.tolerance = (float)tmp_dbl;
                        break;
                    case "-c":
                    case "--random-chance":
                        i++;
                        if(i < args.length) if(double.try_parse(args[i], out tmp_dbl)) this.randomize = (float)tmp_dbl;
                        break;
                    case "-h":
                    case "--help":
                        this.show_help(args[0]);
                        exit(0);
                        break;
                    case "-o":
                    case "--output":
                        i++;
                        if(i < args.length) this.output_fn = args[i];
                        break;
                    case "-v":
                    case "--vectors":
                        i++;
                        if(i < args.length) this.outvec_fn = args[i];
                        break;
                    case "-x":
                    case "--xform":
                        i++;
                        if(i < args.length) this.xform = args[i];
                        break;
                    case "-a":
                    case "--landmarks-a":
                        i++;
                        if(i < args.length) this.landmarks_a = args[i];
                        break;
                    case "-b":
                    case "--landmarks-b":
                        i++;
                        if(i < args.length) this.landmarks_b = args[i];
                        break;
                    case "-g":
                    case "--gui":
                        this.gui = true;
                        break;
                    default:
                        stderr.printf("UNKNOWN ARGUMENT AT [%d]\n", i);
                        exit(-1);
                        break;
                }
            }
        }

        public void show_help(string name)
        {
            stdout.printf("Usage: %s\t-s [filename] --static [filename]\n", name);
            stdout.printf("\t\t\t-m [filename] --moving [filename]\n");
            stdout.printf("\t\t\t-r [x,y,z] --regions [x,y,z]\n");
            stdout.printf("\t\t\t-i [number] --max-iters [number]\n");
            stdout.printf("\t\t\t-t [float] --tolerance [float]\n");
            stdout.printf("\t\t\t-c [float] --random-chance-search [float]\n");
            stdout.printf("\t\t\t-o [filename] --output-volume\n");
            stdout.printf("\t\t\t-v [filename] --output-vectors\n");
            stdout.printf("\t\t\t-x [name] --xform\n");
            stdout.printf("\t\t\t-a [filename] --landmarks-a\n");
            stdout.printf("\t\t\t-b [filename] --landmarks-b\n");
            stdout.printf("\t\t\t-g --gui\n");
            stdout.printf("\t\t\t-G --no-gui\n");
            stdout.printf("\t\t\t-h --help\n");
            stdout.printf("\n");
            stdout.printf("\t\t\t-s --static               Set the path to the static image\n");
            stdout.printf("\t\t\t-m --moving               Set the path tothe moving image\n");
            stdout.printf("\t\t\t-r --regions              Set the number of regions to use in each direction\n");
            stdout.printf("\t\t\t-i --iters                Set the maximum number of iterations to perform\n");
            stdout.printf("\t\t\t-t --tolerance            Set the error tolerance\n");
            stdout.printf("\t\t\t-c --random-chance_search Set the chance of performing a random search instead of following the current direction\n");
            stdout.printf("\t\t\t-x --xform                Set the xform type to be used.  If the xform type is invalid, then an error will be thrown\n");
            stdout.printf("\t\t\t-a --landmarks-a          Set the path to the landmarks for image a.\n");
            stdout.printf("\t\t\t-b --landmarks-b          Set the path to the landmarks for image b.\n");
            stdout.printf("\t\t\t-g --gui                  Show a gui window of the image as it is updated.\n");
            stdout.printf("\t\t\t-h --help                 Show the help dialog, then exit\n");
        }
    }
}
