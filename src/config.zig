const c = @import("c.zig");

const ActionDef = struct {
    modifier: u32,
    code: c.KeySym,
    action: *const fn () void,
};

const ModKey = c.Mod4Mask;

pub const keys = [_]ActionDef{ActionDef{ .modifier = ModKey, .code = c.XK_space, .action = openRofi }};

pub fn openRofi() void {}
