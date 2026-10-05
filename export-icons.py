import os
import gi
gi.require_version('Gimp', '3.0')
from gi.repository import Gimp, Gio

# Determine paths relative to the project root
base_dir = os.getcwd()
xcf_path = os.path.abspath(os.path.join(base_dir, "icon-spacetime.xcf"))
icon_dir = os.path.abspath(os.path.join(base_dir, "assets", "icon"))

if not os.path.exists(xcf_path):
    # Try script directory fallback
    script_dir = os.path.dirname(os.path.abspath(__file__)) if '__file__' in locals() else base_dir
    xcf_path = os.path.abspath(os.path.join(script_dir, "icon-spacetime.xcf"))
    icon_dir = os.path.abspath(os.path.join(script_dir, "assets", "icon"))

print(f"Loading {xcf_path}...")
file_in = Gio.File.new_for_path(xcf_path)

# Helper function to configure and save
def save_icon(image, layers, bg_visible, fg_visible, filename):
    layer_map = {l.get_name(): l for l in layers}
    layer_map['Background'].set_visible(bg_visible)
    layer_map['Foreground'].set_visible(fg_visible)
    
    out_path = os.path.join(icon_dir, filename)
    file_out = Gio.File.new_for_path(out_path)
    success = Gimp.file_save(Gimp.RunMode.NONINTERACTIVE, image, file_out)
    print(f"Exported {filename}: {success}")

# 1. Export icon.png
image = Gimp.file_load(Gimp.RunMode.NONINTERACTIVE, file_in)
layers = image.get_layers()
save_icon(image, layers, bg_visible=True, fg_visible=True, filename="icon.png")
image.delete()

# 2. Export foreground.png
image = Gimp.file_load(Gimp.RunMode.NONINTERACTIVE, file_in)
layers = image.get_layers()
save_icon(image, layers, bg_visible=False, fg_visible=True, filename="foreground.png")
image.delete()

# 3. Export background.png
image = Gimp.file_load(Gimp.RunMode.NONINTERACTIVE, file_in)
layers = image.get_layers()
save_icon(image, layers, bg_visible=True, fg_visible=False, filename="background.png")
image.delete()
