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
        if (c.XPending(xlib.display) <= 0) {
            continue;
        }

        const e: c.XEvent = std.mem.zeroes(c.XEvent);
        _ = c.XNextEvent(xlib.display, &e);

        switch (e.type) {
            c.KeyPress => onKeyPress(xlib.display, &e),
            else => continue,
        }
    }
}

fn onKeyPress(display: c.Display, e: *c.XEvent) void {
    const event = e.xkey;
    const keysym = c.XKeycodeToKeysym(display, @intCast(event.keycode), 0);

    for (config.keys) |key| {
        if (event.state == key.modifier and keysym == key.code) {
            key.action();
            break;
        }
    }
}
