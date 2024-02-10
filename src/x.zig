const c = @import("c.zig");
const std = @import("std");

pub const Xlib = struct {
    display: *c.Display = undefined,
    root: c.Window = undefined,
    screen: i32 = 0,
    xbuttonStart: ?c.XButtonEvent,
    cursor: u64 = undefined,

    pub fn init() Xlib {
        const display = c.XOpenDisplay(null) orelse @panic("no display");
        const screen = c.XDefaultScreen(display);
        const cursor = c.XCreateFontCursor(display, @intCast(screen));
        const root = c.XRootWindow(display, screen);

        var windowAttributes = std.mem.zeroes(c.XSetWindowAttributes);
        windowAttributes.event_mask = c.SubstructureNotifyMask | c.SubstructureRedirectMask | c.KeyPressMask | c.EnterWindowMask | c.FocusChangeMask | c.PropertyChangeMask | c.PointerMotionMask | c.NoEventMask;
        windowAttributes.cursor = cursor;

        _ = c.XChangeWindowAttributes(display, root, c.CWEventMask | c.CWCursor, &windowAttributes);
        _ = c.XSelectInput(display, root, windowAttributes.event_mask);
        _ = c.XSync(display, 0);

        return Xlib{ .display = display, .screen = screen, .root = root, .xbuttonStart = null, .cursor = cursor };
        // Self.display = c.XOpenDisplay(null) orelse @panic("No display");
        // Self.screen = c.XDefaultScreen(Self.display);
        // Self.root = c.XRootWindow(Self.display, Self.screen);
    }
};
