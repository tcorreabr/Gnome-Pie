/* 
Copyright (c) 2011 by Simon Schneegans

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU General Public License as published by the Free
Software Foundation, either version 3 of the License, or (at your option)
any later version.

This program is distributed in the hope that it will be useful, but WITHOUT
ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
more details.

You should have received a copy of the GNU General Public License along with
this program.  If not, see <http://www.gnu.org/licenses/>. 
*/

namespace GnomePie {

/////////////////////////////////////////////////////////////////////////    
/// 
/////////////////////////////////////////////////////////////////////////

class PieList : Gtk.TreeView {

    /////////////////////////////////////////////////////////////////////
    /// The currently selected row.
    /////////////////////////////////////////////////////////////////////
    
    public signal void on_select(string id);
    
    private Gtk.ListStore data;
    
    private enum DataPos {ICON, ICON_NAME, NAME, ID}

    /////////////////////////////////////////////////////////////////////
    /// C'tor, constructs the Widget.
    /////////////////////////////////////////////////////////////////////

    public PieList() {
        GLib.Object();
        
        this.data = new Gtk.ListStore(4, typeof(Gdk.Pixbuf),   
                                         typeof(string),
                                         typeof(string),
                                         typeof(string));
                                         
        this.data.set_sort_column_id(DataPos.NAME, Gtk.SortType.ASCENDING);
        
        this.set_model(this.data);
        this.set_headers_visible(false);
        this.set_grid_lines(Gtk.TreeViewGridLines.NONE);
        this.width_request = 170;
        
        this.set_events(Gdk.EventMask.POINTER_MOTION_MASK);
        
        var main_column = new Gtk.TreeViewColumn();
            var icon_render = new Gtk.CellRendererPixbuf();
                icon_render.xpad = 4;
                icon_render.ypad = 4;
                main_column.pack_start(icon_render, false);
        
            var name_render = new Gtk.CellRendererText();
                name_render.ellipsize = Pango.EllipsizeMode.END;
                name_render.ellipsize_set = true;
                main_column.pack_start(name_render, true);
        
        base.append_column(main_column);
        
        main_column.add_attribute(icon_render, "pixbuf", DataPos.ICON);
        main_column.add_attribute(name_render, "markup", DataPos.NAME);
        
        // setup drag'n'drop
        Gtk.TargetEntry uri_source = {"text/uri-list", 0, 0};
        Gtk.TargetEntry[] entries = { uri_source };
        this.enable_model_drag_source(Gdk.ModifierType.BUTTON1_MASK, entries, Gdk.DragAction.LINK);
        //this.enable_model_drag_dest(entries, Gdk.DragAction.COPY | Gdk.DragAction.MOVE | Gdk.DragAction.LINK);
        this.drag_data_get.connect(this.on_dnd_source);
        this.drag_begin.connect_after(this.on_start_drag);
        //this.drag_motion.connect(this.on_drag_move);
        
        this.get_selection().changed.connect(() => {
            Gtk.TreeIter active;
            if (this.get_selection().get_selected(null, out active)) {
                string id = "";
                this.data.get(active, DataPos.ID, out id);
                this.on_select(id);
            }
        });
        
        reload_all();
    }
    
    public void reload_all() {
        Gtk.TreeIter active;
        string id = "";
        if (this.get_selection().get_selected(null, out active))
            this.data.get(active, DataPos.ID, out id);
    
        data.clear();
        foreach (var pie in PieManager.all_pies.entries) {
            this.load_pie(pie.value);
        }
        
        select(id);
    }
    
    public void select_first() {
        Gtk.TreeIter active;
        
        if(this.data.get_iter_first(out active) ) {
            this.get_selection().select_iter(active);
            string id = "";
            this.data.get(active, DataPos.ID, out id);
            this.on_select(id);
        } else {
            this.on_select("");
        }
    }
    
    public void select(string id) {
        this.data.foreach((model, path, iter) => {
            string pie_id;
            this.data.get(iter, DataPos.ID, out pie_id);
            
            if (id == pie_id) {
                this.get_selection().select_iter(iter);
                return true;
            }
            
            return false;
        });
    }
    
    // loads one given pie to the list
    private void load_pie(Pie pie) {
        if (pie.id.length == 3) {
            Gtk.TreeIter last;
            this.data.append(out last);
            var icon = new Icon(pie.icon, 24);
            this.data.set(last, DataPos.ICON, icon.to_pixbuf(), 
                                DataPos.ICON_NAME, pie.icon,
                                DataPos.NAME, pie.name,
                                DataPos.ID, pie.id); 
        }
    }
    
    private void on_dnd_source(Gdk.DragContext context, Gtk.SelectionData selection_data, uint info, uint time_) {
        Gtk.TreeIter selected;
        if (this.get_selection().get_selected(null, out selected)) {
            string id = "";
            this.data.get(selected, DataPos.ID, out id);
            selection_data.set_uris({"file://" + Paths.launchers + "/" + id + ".desktop"});
        }
    }
    
    private void on_start_drag(Gdk.DragContext ctx) {
        Gtk.TreeIter selected;
        if (this.get_selection().get_selected(null, out selected)) {
            string icon_name = "";
            this.data.get(selected, DataPos.ICON_NAME, out icon_name);
            
            var icon = new Icon(icon_name, 48);
            var pixbuf = icon.to_pixbuf();
            Gtk.drag_set_icon_pixbuf(ctx, pixbuf, icon.size()/2, icon.size()/2);
        }
        
    }
    
    private bool on_drag_move(Gdk.DragContext ctx, int x, int y, uint time) {
        //this.select_cursor_row(false);
        debug("hu");
        return true;
    }
}

}
