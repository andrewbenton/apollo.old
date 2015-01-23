using Gtk;
using apollo.img.reg;

namespace apollo.img.reg.visual
{
    public class MviewGroup : Object
    {
        //public MviewTab label;
        public MviewPage page;
        public Notebook parent;

        public MviewGroup(Notebook parent, apollo.img.reg.Volume vol, string name)
        {
            this.parent = parent;
            //this.label = new MviewTab(this, name);
            //this.page = new MviewPage(file_name);
            this.page = new MviewPage(vol);

            //this.idx = this.parent.append_page(this.page, this.label);
            var button = new Button.from_icon_name("window-close", IconSize.BUTTON);
            var label = new Label(name);
            button.clicked.connect(() =>
                    {
                    this.close();
                    });

            this.parent.append_page(this.page, label);
            //this.parent.append_page(this.page, button);
        }

        public void close()
        {
            var idx = this.parent.page_num(this.page);

            this.parent.remove_page(idx);
        }
    }
}
