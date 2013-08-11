namespace FiveOrMore
{
    public class FiveOrMoreApp : Gtk.Application
    {
        private Gtk.ApplicationWindow window;
        private Settings settings;
        private Gtk.Builder builder;
        private History history;
        private Size[] sizes;
        private GlinesBoard board;

        private Gtk.Dialog preferences_dialog;

        private const GLib.ActionEntry[] action_entries =
        {
            { "new-game", new_game_cb },
            { "scores", scores_cb },
            { "preferences", preferences_cb },
            { "help", help_cb },
            { "about", about_cb },
            { "quit", quit_cb }
        };

        public FiveOrMoreApp ()
        {
            Object (application_id: "org.gnome.five-or-more", flags: ApplicationFlags.FLAGS_NONE);

            add_action_entries (action_entries, this);
        }

        protected override void startup ()
        {
            base.startup ();

            settings = new Settings ("org.gnome.five-or-more");

            builder = new Gtk.Builder ();
            try
            {
                 builder.add_from_resource ("/org/gnome/five-or-more/ui/five-or-more.ui");
                 builder.add_from_resource ("/org/gnome/five-or-more/ui/five-or-more-preferences.ui");
            }
            catch (GLib.Error e)
            {
                GLib.warning ("Could not load UI: %s", e.message);
            }

            sizes = new Size[3];
            sizes[0] = { "small", _("Small"), 7, 7, 5, 3 };
            sizes[1] = { "medium", _("Medium"), 9, 9, 7, 3 };
            sizes[2] = { "large", _("Large"), 20, 15, 7, 7 };

            var menu = new Menu ();

            var section = new Menu ();
            menu.append_section (null, section);
            section.append (_("_New Game"), "app.new-game");
            section.append (_("_Scores"), "app.scores");
            section.append (_("_Preferences"), "app.preferences");

            section = new Menu ();
            menu.append_section (null, section);
            section.append (_("_Help"), "app.help");
            section.append (_("_About"), "app.about");

            section = new Menu ();
            menu.append_section (null, section);
            section.append (_("_Quit"), "app.quit");
            set_app_menu (menu);

            window = (Gtk.ApplicationWindow) builder.get_object ("glines_window");
            add_window (window);

            history = new History (Path.build_filename (Environment.get_user_data_dir (), "five-or-more", "history"));
            history.load ();

            setup_new_game ();
        }

        public override void activate ()
        {
            window.present ();
        }

        private void new_game_cb ()
        {
            setup_new_game ();
        }

        private void setup_new_game ()
        {
            var size = get_current_size ();
            board = new GlinesBoard(size.columns, size.rows, size.ncolors, size.npieces);
            board.gameover.connect ((o) => this.scores_cb());

            var view2d = new View2D (board);

            var box = (Gtk.Box) builder.get_object ("vbox");
            box.foreach(c => box.remove (c));

            box.add (view2d);
            view2d.show ();
        }

        private void scores_cb ()
        {
            var dialog = new ScoreDialog (history);
            dialog.modal = true;
            dialog.transient_for = window;

            dialog.run ();
            dialog.destroy ();
        }

        private void preferences_cb ()
        {
            stdout.printf ("preferences\n");
            if (preferences_dialog == null)
                preferences_dialog = (Gtk.Dialog) builder.get_object ("preferences_dialog");
            preferences_dialog.transient_for = window;
            
            preferences_dialog.run();
            preferences_dialog.destroy ();
        }

        private void help_cb ()
        {
            try
            {
                Gtk.show_uri (window.get_screen (), "ghelp:five-or-more", Gtk.get_current_event_time ());
            }
            catch (GLib.Error e)
            {
                GLib.warning ("Unable to open help: %s", e.message);
            }
        }

        private void about_cb ()
        {
            const string authors[] = { "Robert Szokovacs (original author)", "Szabolcs B\xc3\xa1n (original author)", "Thomas Andersen (port to vala)", null };
            const string documenters[] = { "Tiffany Antopolski", "Lanka Rathnayaka", null };

            Gtk.show_about_dialog (window,
                                   "program-name", _("Five or More"),
                                   "logo-icon-name", "five-or-more",
                                   "version", Config.VERSION,
                                   "comments", _("GNOME port of the once-popular Color Lines game"),
                                   "copyright", "Copyright \xc2\xa9 1997-2012 Free Software Foundation, Inc.",
                                   //"license-type", Gtk.License.GPL_3_0,
                                   "wrap-license", false,
                                   "authors", authors,
                                   "documenters", documenters,
                                   "translator-credits", _("translator-credits"),
                                   "website", "http://live.gnome.org/Five%20or%20more",
                                   "website-label", _("Five or More web site"),
                                   null);
        }
        
        private void quit_cb ()
        {
            window.destroy ();
        }

        private Size get_current_size ()
        {
            var id = settings.get_string ("size");
            for (var i = 0; i < sizes.length; i++)
            {
                if (sizes[i].id == id)
                    return sizes[i];
            }

            return sizes[0];
        }
    }
}

public struct Size
{
    public string id;
    public string name;
    public int columns;
    public int rows;
    public int ncolors;
    public int npieces;
}