/*
 * Method of loading and using modules is a modified version of what is available at www.valadoc.org/#!api=gmodule-2.0/GLib.Module
 * Author: Andrew Benton
 * Date: 2014-01-07
 */

namespace apollo.img.reg
{
    public interface XformMethod : Object
    {
        public abstract void registered(XformMethodLoader loader);
        public abstract string get_name();
        public abstract Xform get_xform(Params parms, Volume stat, Volume moving);
        public abstract Optimizer get_optimizer(Params parms, Volume stat, Volume moving);
    }

    private class PluginInfo : Object
    {
        public Module module;
        public Type gtype;

        public PluginInfo(Type type, owned Module module)
        {
            this.module = (owned)module;
            this.gtype = type;
        }
    }

    public class XformMethodLoader : Object
    {
        [CCode(has_target="false")]
        private delegate Type RegisterPluginFunction(Module module);

        private XformMethod[] plugins = new XformMethod[0];
        private PluginInfo[] infos = new PluginInfo[0];

        public XformMethod load(string path) throws PluginError
        {
            if(Module.supported() == false)
            {
                throw new PluginError.NOT_SUPPORTED("Plugins are not supported by this configuration.");
            }

            Module module = Module.open(path, ModuleFlags.BIND_LAZY);
            if(module == null)
            {
                throw new PluginError.FAILED(Module.error());
            }

            void *function;
            module.symbol("register_plugin", out function);
            if(function == null)
            {
                throw new PluginError.NO_REGISTRATION_FUNCTION("register_plugin() not found in %s".printf(path));
            }

            RegisterPluginFunction register_plugin = (RegisterPluginFunction)function;
            Type type = register_plugin(module);
            if(type.is_a(typeof(XformMethod)) == false)
            {
                throw new PluginError.UNEXPECTED_TYPE("Unexpected type");
            }

            PluginInfo info = new PluginInfo(type, (owned)module);
            infos += info;

            XformMethod plugin = (XformMethod)Object.new(type);
            plugins += plugin;
            plugin.registered(this);

            return plugin;
        }
    }

    public errordomain PluginError
    {
        NOT_SUPPORTED,
        UNEXPECTED_TYPE,
        NO_REGISTRATION_FUNCTION,
        FAILED
    }
}
