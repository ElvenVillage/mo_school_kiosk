#include "my_application.h"

#include <flutter_linux/flutter_linux.h>
#ifdef GDK_WINDOWING_X11
#include <gdk/gdkx.h>
#endif

#include "flutter/generated_plugin_registrant.h"

struct _MyApplication {
  GtkApplication parent_instance;
  char** dart_entrypoint_arguments;
};

G_DEFINE_TYPE(MyApplication, my_application, GTK_TYPE_APPLICATION)


static FlBinaryMessenger *binaryMessenger;
static FlEventChannel *globalEvents;

static void zoom_scale_changed(GtkGesture *gesture, gdouble scale, gpointer data) {
  // printf("ZOOM CHANGED FROM C");
  GdkEventSequence *sequence = gtk_gesture_get_last_updated_sequence(gesture);
  const GdkEvent *event = gtk_gesture_get_last_event(gesture, sequence);
  g_autoptr(FlValue) map = fl_value_new_map();
  fl_value_set_string(map, "event", fl_value_new_string("zoom changed"));
  fl_value_set_string(map, "scale", fl_value_new_float(scale));
  fl_value_set_string(map, "x", fl_value_new_float(event->button.x));
  fl_value_set_string(map, "y", fl_value_new_float(event->button.y));
  fl_event_channel_send(globalEvents, map, nullptr, nullptr);
}


// Implements GApplication::activate.
static void my_application_activate(GApplication* application) {
  MyApplication* self = MY_APPLICATION(application);
  GtkWindow* window =
      GTK_WINDOW(gtk_application_window_new(GTK_APPLICATION(application)));

  // Use a header bar when running in GNOME as this is the common style used
  // by applications and is the setup most users will be using (e.g. Ubuntu
  // desktop).
  // If running on X and not using GNOME then just use a traditional title bar
  // in case the window manager does more exotic layout, e.g. tiling.
  // If running on Wayland assume the header bar will work (may need changing
  // if future cases occur).
  gboolean use_header_bar = TRUE;
#ifdef GDK_WINDOWING_X11
  GdkScreen* screen = gtk_window_get_screen(window);
  if (GDK_IS_X11_SCREEN(screen)) {
    const gchar* wm_name = gdk_x11_screen_get_window_manager_name(screen);
    if (g_strcmp0(wm_name, "GNOME Shell") != 0) {
      use_header_bar = FALSE;
    }
  }
#endif
  if (use_header_bar) {
    GtkHeaderBar* header_bar = GTK_HEADER_BAR(gtk_header_bar_new());
    gtk_widget_show(GTK_WIDGET(header_bar));
    gtk_header_bar_set_title(header_bar, "LMS KIOSK");
    gtk_header_bar_set_show_close_button(header_bar, TRUE);
    gtk_window_set_titlebar(window, GTK_WIDGET(header_bar));
  } else {
    gtk_window_set_title(window, "LMS KIOSK");
  }

  gtk_widget_add_events (GTK_WIDGET(window), GDK_TOUCH_MASK | GDK_TOUCHPAD_GESTURE_MASK);

  GtkGesture *zoom = gtk_gesture_zoom_new(GTK_WIDGET(window));
  g_signal_connect (G_OBJECT (zoom), "scale-changed", G_CALLBACK (zoom_scale_changed), NULL);
  gtk_event_controller_set_propagation_phase (GTK_EVENT_CONTROLLER (zoom), GTK_PHASE_CAPTURE);
  // g_object_weak_ref (G_OBJECT (window), (GWeakNotify) g_object_unref, zoom);



  gtk_window_set_default_size(window, 960, 540);
  gtk_window_fullscreen(window);
  gtk_widget_show(GTK_WIDGET(window));
  


  g_autoptr(FlDartProject) project = fl_dart_project_new();
  fl_dart_project_set_dart_entrypoint_arguments(project, self->dart_entrypoint_arguments);

  FlView* view = fl_view_new(project);
  gtk_widget_show(GTK_WIDGET(view));
  gtk_container_add(GTK_CONTAINER(window), GTK_WIDGET(view));

  fl_register_plugins(FL_PLUGIN_REGISTRY(view));

  binaryMessenger = fl_engine_get_binary_messenger(fl_view_get_engine(view));
  g_autoptr(FlStandardMethodCodec) globalEventCodec = fl_standard_method_codec_new();
  globalEvents = fl_event_channel_new(binaryMessenger,
                                        "ru.nintegra/kiosk.dovuz/events",
                                        FL_METHOD_CODEC(globalEventCodec));

  gtk_widget_grab_focus(GTK_WIDGET(view));
}

// Implements GApplication::local_command_line.
static gboolean my_application_local_command_line(GApplication* application, gchar*** arguments, int* exit_status) {
  MyApplication* self = MY_APPLICATION(application);
  // Strip out the first argument as it is the binary name.
  self->dart_entrypoint_arguments = g_strdupv(*arguments + 1);

  g_autoptr(GError) error = nullptr;
  if (!g_application_register(application, nullptr, &error)) {
     g_warning("Failed to register: %s", error->message);
     *exit_status = 1;
     return TRUE;
  }

  g_application_activate(application);
  *exit_status = 0;

  return TRUE;
}

// Implements GObject::dispose.
static void my_application_dispose(GObject* object) {
  MyApplication* self = MY_APPLICATION(object);
  g_clear_pointer(&self->dart_entrypoint_arguments, g_strfreev);
  g_clear_object(&globalEvents);
  G_OBJECT_CLASS(my_application_parent_class)->dispose(object);
}

static void my_application_class_init(MyApplicationClass* klass) {
  G_APPLICATION_CLASS(klass)->activate = my_application_activate;
  G_APPLICATION_CLASS(klass)->local_command_line = my_application_local_command_line;
  G_OBJECT_CLASS(klass)->dispose = my_application_dispose;
}

static void my_application_init(MyApplication* self) {}

MyApplication* my_application_new() {
  return MY_APPLICATION(g_object_new(my_application_get_type(),
                                     "application-id", APPLICATION_ID,
                                     "flags", G_APPLICATION_NON_UNIQUE,
                                     nullptr));
}
