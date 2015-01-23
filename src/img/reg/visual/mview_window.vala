using Gtk;
using apollo.img.reg;

namespace apollo.img.reg.visual
{
    public class MviewWindow : Gtk.Window
    {
        private Notebook nb;
        private HashTable<string, MviewGroup> groups;

        public MviewWindow()
        {
            Object();
            this.nb = new Notebook();
            this.add(this.nb);
            this.groups = new HashTable<string, MviewGroup>(str_hash, str_equal);
        }

        public bool open_mha(string file_name, string? tab_name = null)
        {
            var vol = new apollo.img.reg.Volume.from_mha(file_name);

            var g = new MviewGroup(this.nb, vol, tab_name ?? file_name);

            this.groups[tab_name ?? file_name] = g;

            return true;
        }

        public void open_volume(string tab_name, apollo.img.reg.Volume vol)
        {
            var g = new MviewGroup(this.nb, vol, tab_name);

            this.groups[tab_name] = g;
        }
    }
}
