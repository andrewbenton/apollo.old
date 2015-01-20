namespace apollo.img.reg
{
    public class Landmarks
    {
        /* CONSTANTS */
        public const string head_rex_str = """^#\s*([^=\s]+)\s*=\s*([^\s]+)\s*$""";
        public const string data_rex_str = """^\s*([^,]+),([+-]?[0-9]*\.?[0-9]+),([+-]?[0-9]*\.?[0-9]+),([+-]?[0-9]*\.?[0-9]+),([01]),([01])\s*$""";

        /* MEMBERS */
        public HashTable<string, LandmarkPoint> landmarks;
        public string name;
        public int num_points;
        public bool valid;

        public Landmarks()
        {
            //doesn't do anything for now
            this.name = "";
            this.num_points = 0;
            this.landmarks = new HashTable<string, LandmarkPoint>(str_hash, str_equal);
            this.valid = true;
        }

        public Landmarks.from_fcsv(string file_name) throws FileError
        {
            //configure member variables
            this.valid = true;
            this.name = "";
            this.num_points = 0;
            this.landmarks = new HashTable<string, LandmarkPoint>(str_hash, str_equal);

            //local hashtable for header lines
            HashTable<string, string> headers = new HashTable<string, string>(str_hash, str_equal);
            var ios = FileStream.open(file_name, "r");

            if(ios == null)
            {
                this.valid = false;
                return;
            }

            string line = null;
            bool read_header = true; //set to false after encountering the columns header

            ios.read_line(); //throw out the first line saying that it's an FCSV

            Regex head_rex = null;
            Regex data_rex = null;

            try
            {
                head_rex = new Regex(head_rex_str);
                data_rex = new Regex(data_rex_str);
            }
            catch(Error e)
            {
                stdout.printf("Error: %s\n", e.message);
                critical("Encountered an error creating regular expressions for head and data lines.\n");
                return;
            }

            assert(head_rex != null && data_rex != null);

            MatchInfo match_info;

            while((line = ios.read_line()) != null)
            {
                if(read_header)
                {
                    if(head_rex.match(line, 0, out match_info))
                    {
#if DEBUG
                        stdout.printf("Header found: %s = %s\n", match_info.fetch(1), match_info.fetch(2));
#endif
                        headers[match_info.fetch(1)] = match_info.fetch(2);

                        if(match_info.fetch(1) == "name") this.name = match_info.fetch(2);
                        if(match_info.fetch(1) == "columns") read_header = false;
                    }
                    else
                    {
                        stderr.printf("Line: \"%s\" does not match the header format, '%s'.\n", line, head_rex.get_pattern());
                    }
                }
                else
                {
                    if(data_rex.match(line, 0, out match_info))
                    {
                        this.num_points++;
                        var point = new LandmarkPoint(
                                match_info.fetch(1), 
                                (float)double.parse(match_info.fetch(2)),
                                (float)double.parse(match_info.fetch(3)),
                                (float)double.parse(match_info.fetch(4)),
                                (match_info.fetch(5) == "1") ? true : false,
                                (match_info.fetch(6) == "1") ? true : false
                                );

                        this.landmarks[point.name] = point;
                    }
                    else
                    {
                        stderr.printf("Line: \"%s\" does not match the data format, '%s'.\n", line, data_rex.get_pattern());
                    }
                }
            }
        }

        public Landmarks clone()
        {
            var ret = new Landmarks();

            ret.name = this.name;
            ret.num_points = this.num_points;
            ret.valid = this.valid;

            var point_list = this.landmarks.get_values();

            for(uint i = 0; i < point_list.length(); i++)
            {
                var point = point_list.nth_data(i);
                ret.landmarks[point.name] = point;
            }

            return ret;
        }

        public void print(FileStream? fs = null)
        {
            if(fs == null) fs = stdout;
            var point_list = this.landmarks.get_values();
            fs.printf("Landmark set:\n");
            fs.printf("\tname: %s\n", this.name);
            fs.printf("\tnum_points: %d\n", this.num_points);
            fs.printf("\tpoints: (name, x, y, z, selected, visible)\n");
            for(uint i = 0; i < point_list.length(); i++)
            {
                var point = point_list.nth_data(i);
                stdout.printf("\t%s\n\t\t%f\n\t\t%f\n\t\t%f\n\t\t%s\n\t\t%s\n", point.name, point.x, point.y, point.z, point.selected.to_string(), point.visible.to_string());
            }
        }

        public class LandmarkPoint
        {
            public string name;
            public float x;
            public float y;
            public float z;
            public bool selected;
            public bool visible;

            internal LandmarkPoint(string name, float x, float y, float z, bool selected, bool visible)
            {
                this.name = name;
                this.x = x;
                this.y = y;
                this.z = z;
                this.selected = selected;
                this.visible  = visible;
            }
        }
    }
}
