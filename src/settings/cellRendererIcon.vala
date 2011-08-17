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

// need to subclass Gtk.CellRenderer because Gtk.CellRendererPixbuf
// can't receive click events
public class CellRendererIcon : Gtk.CellRenderer {

    private IconSelectWindow select_window = null;
    private Gtk.CellRendererPixbuf renderer = null;
    
    // forward CellRendererPixbuf's interface
    public bool follow_state {
        get { return renderer.follow_state; }
        set { renderer.follow_state = value; }
    }
    
    public GLib.Icon gicon {
        owned get { return renderer.gicon; }
        set { renderer.gicon = value; }
    }
    
    public string icon_name { 
        owned get { return renderer.icon_name; }
        set { renderer.icon_name = value; }
    }
    
    public Gdk.Pixbuf pixbuf {
        owned get { return renderer.pixbuf; }
        set { renderer.pixbuf = value; }
    }
    
    public Gdk.Pixbuf pixbuf_expander_closed {
        owned get { return renderer.pixbuf_expander_closed; }
        set { renderer.pixbuf_expander_closed = value; }
    }
    
    public Gdk.Pixbuf pixbuf_expander_open {
        owned get { return renderer.pixbuf_expander_open; }
        set { renderer.pixbuf_expander_open = value; }
    }
    
    public string stock_detail { 
        owned get { return renderer.stock_detail; }
        set { renderer.stock_detail = value; }
    }
    
    public string stock_id { 
        owned get { return renderer.stock_id; }
        set { renderer.stock_id = value; }
    }
    
    public uint stock_size {
        get { return renderer.stock_size; }
        set { renderer.stock_size = value; }
    }

    // c'tor
    public CellRendererIcon() {
        this.select_window = new IconSelectWindow();  
        this.renderer = new Gtk.CellRendererPixbuf();
    
        this.select_window.on_select.connect((icon) => {
            this.icon_name = icon;
        });
    }
    
    public override void get_size (Gtk.Widget widget, Gdk.Rectangle? cell_area,
                               out int x_offset, out int y_offset,
                               out int width, out int height) {

        renderer.get_size(widget, cell_area, out x_offset, out y_offset, out width, out height);
    }
    
    public override void render (Gdk.Window window, Gtk.Widget widget,
                             Gdk.Rectangle bg_area,
                             Gdk.Rectangle cell_area,
                             Gdk.Rectangle expose_area,
                             Gtk.CellRendererState flags) {
        renderer.render(window, widget, bg_area, cell_area, expose_area, flags);
    }
    
    public override unowned Gtk.CellEditable start_editing(
        Gdk.Event event, Gtk.Widget widget, string path, Gdk.Rectangle bg_area, 
        Gdk.Rectangle cell_area, Gtk.CellRendererState flags) {
        
        select_window.show();
        select_window.active_icon = this.icon_name;
            
        return null;
    }
}

}