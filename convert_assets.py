import os
import subprocess
import shutil
import xml.etree.ElementTree as ET
import re

try:
    from PIL import Image
    HAS_PILLOW = True
except ImportError:
    HAS_PILLOW = False
    print("WARNING: Pillow not installed. Auto-resize disabled. Run: pip install Pillow")

def get_tool_path(tool_name: str) -> str:
    tool_path = shutil.which(tool_name)
    if tool_path: return tool_path
    linux_path = f"/opt/devkitpro/tools/bin/{tool_name}"
    if os.path.exists(linux_path): return linux_path
    win_path = f"C:\\devkitPro\\tools\\bin\\{tool_name}.exe"
    if os.path.exists(win_path): return win_path
    return tool_name

def main():
    os.makedirs("assets/romfs/haxe3ds", exist_ok=True)
    with open("assets/romfs/haxe3ds/version", "w") as f: 
        f.write("")

    if not os.path.exists("assets"):
        print("No 'assets' directory found. Skipping conversion.")
        return

    excluded_files = {
        os.path.normpath("assets/resources/audio.wav"),
        os.path.normpath("assets/romfs/resources/audio.wav"),
        os.path.normpath("resources/audio.wav"),
        os.path.normpath("audio.wav"),
        os.path.normpath("assets/resources/icon.png"),
        os.path.normpath("assets/resources/banner.png")
    }
    looped_files = { os.path.normpath("assets/sounds/home.ogg") }

    tex3ds_path = get_tool_path("tex3ds")
    cwavtool_path = get_tool_path("cwavtool")
    mkbcfnt_path = get_tool_path("mkbcfnt")
    
    print(f"Using tex3ds at: {tex3ds_path}")
    print(f"Using cwavtool at: {cwavtool_path}")
    print(f"Using mkbcfnt at: {mkbcfnt_path}")

    sprite_sheets = []
    other_files = []
    font_files = []
    processed_pngs = set()

    for root, dirs, files in os.walk("assets"):
        for file in files:
            file_path = os.path.join(root, file)
            name, ext = os.path.splitext(file)
            ext = ext.lower()
            if ext == ".xml":
                png_path = os.path.join(root, name + ".png")
                if os.path.exists(png_path):
                    sprite_sheets.append((root, name, file_path, png_path))
                    processed_pngs.add(os.path.normpath(png_path))

    for root, dirs, files in os.walk("assets"):
        for file in files:
            file_path = os.path.join(root, file)
            name, ext = os.path.splitext(file)
            ext = ext.lower()
            if ext == ".png" and os.path.normpath(file_path) not in processed_pngs:
                sprite_sheets.append((root, name, None, file_path))

    for root, dirs, files in os.walk("assets"):
        for file in files:
            file_path = os.path.join(root, file)
            name, ext = os.path.splitext(file)
            ext = ext.lower()
            if ext in [".mp3", ".wav", ".ogg"]:
                other_files.append((root, name, ext, file_path))
            elif ext in [".ttf", ".otf"]:
                font_files.append((root, name, ext, file_path))

    for root, name, xml_path, png_path in sprite_sheets:
        if os.path.normpath(png_path) in excluded_files: continue

        t3x_name = name + ".t3x"
        t3x_path = os.path.join(root, t3x_name)
        cea_path = os.path.join(root, name + ".cea") if xml_path else None
        
        print(f"\nProcessing image: {name} (in {root})")
        scale_x, scale_y = 1.0, 1.0
        MAX_TEX_SIZE = 1024
        
        if HAS_PILLOW and os.path.exists(png_path):
            try:
                img = Image.open(png_path).convert("RGBA")
                orig_w, orig_h = img.size
                if orig_w > MAX_TEX_SIZE or orig_h > MAX_TEX_SIZE:
                    scale = min(MAX_TEX_SIZE / orig_w, MAX_TEX_SIZE / orig_h)
                    new_w, new_h = max(1, int(orig_w * scale)), max(1, int(orig_h * scale))
                    img = img.resize((new_w, new_h), Image.LANCZOS)
                    scale_x, scale_y = new_w / orig_w, new_h / orig_h
                img.save(png_path)
            except Exception as e:
                print(f"  WARNING: Pillow error: {e}")

        tex3ds_success = False
        try:
            subprocess.run([tex3ds_path, os.path.abspath(png_path), "-o", os.path.abspath(t3x_path), "-f", "rgba8"], check=True)
            tex3ds_success = True
        except Exception as e:
            print(f"  ERROR: tex3ds failed. ({e})")
            
        cea_generated = (xml_path is None)
        if xml_path:
            try:
                tree = ET.parse(xml_path)
                cea_lines, anim_counters = [], {}
                for subtex in tree.getroot().findall(".//SubTexture"):
                    x, y = float(subtex.get("x", "0")), float(subtex.get("y", "0"))
                    w, h = float(subtex.get("width", "0")), float(subtex.get("height", "0"))
                    fx, fy = float(subtex.get("frameX", "0")), float(subtex.get("frameY", "0"))
                    fw, fh = float(subtex.get("frameWidth", str(w))), float(subtex.get("frameHeight", str(h)))

                    if scale_x != 1.0 or scale_y != 1.0:
                        x, y, w, h = round(x*scale_x), round(y*scale_y), round(w*scale_x), round(h*scale_y)
                        fx, fy, fw, fh = round(fx*scale_x), round(fy*scale_y), round(fw*scale_x), round(fh*scale_y)

                    frame_name = subtex.get("name")
                    match = re.search(r'^(.*?)(?:[_\-])?(\d+)$', frame_name)
                    if match:
                        anim_name = match.group(1).rstrip('_-')
                        idx = anim_counters.get(anim_name, 0)
                        anim_counters[anim_name] = idx + 1
                        cea_lines.append(f"{t3x_name}?{int(x)}?{int(y)}?{int(w)}?{int(h)}?{int(fx)}?{int(fy)}?{int(fw)}?{int(fh)}?{anim_name}-{idx}")
                    else:
                        cea_lines.append(f"{t3x_name}?{int(x)}?{int(y)}?{int(w)}?{int(h)}?{int(fx)}?{int(fy)}?{int(fw)}?{int(fh)}?{frame_name}-0")
                
                with open(cea_path, "w", encoding="utf-8") as f: f.write("\n".join(cea_lines) + "\n")
                cea_generated = True
            except Exception as e:
                print(f"  ERROR: XML parse failed: {e}")
        
        if tex3ds_success and cea_generated:
            if os.path.exists(png_path): os.remove(png_path)
            if xml_path and os.path.exists(xml_path): os.remove(xml_path)

    for root, name, ext, file_path in font_files:
        if not os.path.exists(file_path): continue
        bcfnt_path = os.path.join(root, name + ".bcfnt")
        print(f"\nProcessing font: {name} (in {root})")
        try:
            subprocess.run([mkbcfnt_path, file_path, "-o", bcfnt_path], check=True)
            os.remove(file_path)
            print(f"  SUCCESS: Converted to BCFNT.")
        except Exception as e: 
            print(f"  ERROR: mkbcfnt failed. ({e})")

    for root, name, ext, file_path in other_files:
        if not os.path.exists(file_path): continue
        if ext == ".mp3" and os.path.normpath(file_path) not in excluded_files:
            out_path = os.path.join(root, name + ".ogg")
            try:
                subprocess.run(["ffmpeg", "-y", "-i", file_path, "-q:a", "4", out_path], check=True)
                os.remove(file_path)
                file_path = out_path
                ext = ".ogg"
            except Exception as e: print(f"Error ffmpeg: {e}")
            
        if ext in [".wav", ".ogg"] and os.path.normpath(file_path) not in excluded_files:
            out_path = os.path.join(root, name + ".cwav")
            try:
                cmd = [cwavtool_path, "-i", file_path, "-o", out_path]
                if os.path.normpath(file_path) in looped_files: cmd.extend(["-ls", "0", "-le", "end"])
                subprocess.run(cmd, check=True)
                if ext == ".wav": os.remove(file_path)
            except Exception as e: print(f"Error cwavtool: {e}")

if __name__ == "__main__":
    main()
