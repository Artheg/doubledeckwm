const std = @import("std");
const c = @import("c.zig");
const config = @import("config.zig");
const x = @import("x.zig");

pub const Screen = struct {};

pub fn main() !void {
    const xlib = x.Xlib.init();
    // if (display == null) {
    //     std.debug.print("No display", .{});
    //     std.os.exit(1);
    // }
    std.debug.print("Running DDWM", .{});
    for (config.keys) |key| {
        const code = c.XKeysymToKeycode(xlib.display, key.code);
        _ = c.XGrabKey(xlib.display, code, key.modifier, xlib.root, 1, c.GrabModeAsync, c.GrabModeAsync);
    }
    while (true) {
        std.debug.print("Running DDWM", .{});
    }
}
