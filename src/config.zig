const std = @import("std");
const c = @import("c.zig");

pub const Arg = union {
    String: [:0]const u8,
};

const ActionDef = struct { modifier: u32, code: c.KeySym, action: *const fn (arg: Arg) void, arg: Arg };

const ModKey = c.Mod4Mask;

// Mod + l/h    Cycle through decks
// Mod + j/k    Cycle through focused deck's windows
// Mod + f      Toggle fullscreen of the active window
// S-Mod + l/h  Cycle through workspaces
// Mod + i/d    Increase/decrease gaps
// S-Mod + c    Close window
pub const keys = [_]ActionDef{
    spawnWithMod(c.XK_space, "rofi -show combi -modes combi -combi-modes \"window,drun,run\""),
    spawnWithMod(c.XK_Return, "st"),
};

fn spawnWithMod(key: c.KeySym, cmd: [:0]const u8) ActionDef {
    return ActionDef{ .modifier = ModKey, .code = key, .action = spawnWithShell, .arg = Arg{ .String = cmd } };
}

fn spawnWithShell(arg: Arg) void {
    const cmd = arg.String;
    std.debug.print("cmd: {s}\n", .{cmd.ptr});
    const pid = std.os.linux.fork();
    if (pid == 0) {
        const env = std.c.environ;
        const args = [_:null]?[*:0]const u8{ "sh", "-c", cmd.ptr, null };
        _ = std.os.execvpeZ("sh", &args, env) catch {};
        std.os.exit(127);
    }
}
