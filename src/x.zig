const c = @import("c.zig");
pub const Xlib = struct {
    display: *c.Display = undefined,
    root: c.Window = undefined,
    screen: i32 = 0,

    pub fn init() Xlib {
        const display = c.XOpenDisplay(null) orelse @panic("no display");
        const screen = c.XDefaultScreen(display);
        return Xlib{
            .display = display,
            .screen = screen,
            .root = c.XRootWindow(display, screen),
        };
        // Self.display = c.XOpenDisplay(null) orelse @panic("No display");
        // Self.screen = c.XDefaultScreen(Self.display);
        // Self.root = c.XRootWindow(Self.display, Self.screen);
    }
};
