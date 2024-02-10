const std = @import("std");
const c = @import("c.zig");
const config = @import("config.zig");
const x = @import("x.zig");

pub const Deck = struct {};
pub const Workspace = struct {};
pub const Screen = struct {};

var xlib: x.Xlib = undefined;
// Screen -> Workspaces -> Decks -> Windows
// The idea is to have two decks side-by-side
// New windows are being added to the "active" (focused) deck.
// If there's only one window in total on the screen then this window is maximized

pub fn main() !void {
    xlib = x.Xlib.init();
    std.debug.print("starting doubledeckwm\n", .{});
    for (config.keys) |key| {
        const code = c.XKeysymToKeycode(xlib.display, key.code);
        _ = c.XGrabKey(xlib.display, code, key.modifier, xlib.root, 1, c.GrabModeAsync, c.GrabModeAsync);

        _ = c.XGrabButton(xlib.display, 1, c.Mod1Mask, xlib.root, 1, c.ButtonPressMask | c.ButtonReleaseMask | c.PointerMotionMask, c.GrabModeAsync, c.GrabModeAsync, c.None, c.None);
        _ = c.XGrabButton(xlib.display, 3, c.Mod1Mask, xlib.root, 1, c.ButtonPressMask | c.ButtonReleaseMask | c.PointerMotionMask, c.GrabModeAsync, c.GrabModeAsync, c.None, c.None);
        // XGrabButton(dpy, 3, Mod1Mask, DefaultRootWindow(dpy), True,
        //         ButtonPressMask|ButtonReleaseMask|PointerMotionMask, GrabModeAsync, GrabModeAsync, None, None);
    }
    while (true) {
        if (c.XPending(xlib.display) <= 0) {
            continue;
        }

        std.debug.print("RUNNIN\n", .{});
        var e: c.XEvent = std.mem.zeroes(c.XEvent);
        _ = c.XNextEvent(xlib.display, &e);

        switch (e.type) {
            // c.ButtonPress => onButtonPress(xlib.display, &e),
            c.KeyPress => try onKeyPress(xlib.display, &e),
            c.EnterNotify => try onEnterNotify(xlib.display, &e),
            c.MotionNotify => try onMotionNotify(xlib.display, &e),
            else => std.debug.print("Event: {}\n", .{&e.type}),
        }
    }
}

// fn onButtonPress(display: *c.Display, e: *c.XEvent) void {
//     // const attr = std.mem.zeroes(c.XWindowAttributes);
//     // _ = c.XGetWindowAttributes(display, e.xbutton.subwindow, &attr);
//     xlib.xbuttonStart = e.xbutton;
// }

fn onMotionNotify(display: *c.Display, e: *c.XEvent) !void {
    std.debug.print("e: MotionNotify", .{});
    try config.spawnWithShell(config.Arg{ .String = "notify-send onMotionNotify" });
    _ = c.XSetInputFocus(display, e.xcrossing.window, c.PointerRoot, c.CurrentTime);
    _ = c.XRaiseWindow(display, e.xcrossing.window);
}

fn onEnterNotify(display: *c.Display, e: *c.XEvent) !void {
    std.debug.print("e: EnterNotify", .{});
    try config.spawnWithShell(config.Arg{ .String = "notify-send onEnterNotify" });
    _ = c.XSetInputFocus(display, e.xcrossing.window, c.PointerRoot, c.CurrentTime);
    _ = c.XRaiseWindow(display, e.xcrossing.window);
}

fn onKeyPress(display: *c.Display, e: *c.XEvent) !void {
    if (e.xkey.subwindow != 0) {
        _ = c.XRaiseWindow(display, e.xkey.subwindow);
        try config.spawnWithShell(config.Arg{ .String = "play /home/artheg/bell.mp3" });
    }
    const event = e.xkey;
    const keysym = c.XKeycodeToKeysym(display, @intCast(event.keycode), 0);

    for (config.keys) |key| {
        if (event.state == key.modifier and keysym == key.code) {
            switch (key.action) {
                .withArg => try key.action.withArg(key.arg.?),
                .noArg => try key.action.noArg(),
            }
            break;
        }
    }
}
