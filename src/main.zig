const std = @import("std");
const c = @import("c.zig");
const config = @import("config.zig");
const x = @import("x.zig");


pub const Deck = struct{};
pub const Workspace = struct {};
pub const Screen = struct {};
// Screen -> Workspaces -> Decks -> Windows
// The idea is to have two decks side-by-side
// New windows are being added to the "active" (focused) deck.
// If there's only one window in total on the screen then this window is maximized

pub fn main() !void {
    const xlib = x.Xlib.init();
    for (config.keys) |key| {
        const code = c.XKeysymToKeycode(xlib.display, key.code);
        _ = c.XGrabKey(xlib.display, code, key.modifier, xlib.root, 1, c.GrabModeAsync, c.GrabModeAsync);
    }
    while (true) {
        if (c.XPending(xlib.display) <= 0) {
            continue;
        }

        var e: c.XEvent = std.mem.zeroes(c.XEvent);
        _ = c.XNextEvent(xlib.display, &e);

        switch (e.type) {
            c.KeyPress => onKeyPress(xlib.display, &e),
            else => continue,
        }
    }
}

fn onKeyPress(display: *c.Display, e: *c.XEvent) void {
    const event = e.xkey;
    const keysym = c.XKeycodeToKeysym(display, @intCast(event.keycode), 0);

    for (config.keys) |key| {
        if (event.state == key.modifier and keysym == key.code) {
            key.action(key.arg);
            break;
        }
    }
}
