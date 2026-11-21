package deltarune.assets;

using StringTools;

class JsonUtil {
    public static function trimKeys(v:Dynamic):Dynamic {
        if (v == null) return null;
        if (Std.isOfType(v, Array)) {
            var a:Array<Dynamic> = v;
            for (i in 0...a.length) a[i] = trimKeys(a[i]);
            return a;
        }
        if (Std.isOfType(v, String)) return v;
        if (Reflect.isObject(v)) {
            var out:Dynamic = {};
            for (k in Reflect.fields(v)) {
                Reflect.setField(out, k.trim(), trimKeys(Reflect.field(v, k)));
            }
            return out;
        }
        return v;
    }
}
