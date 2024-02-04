const std = @import("std");
const c = @import("c.zig");

const ActionDef = struct {
    modifier: u32,
    code: c.KeySym,
    action: *const fn () void,
};

const ModKey = c.Mod4Mask;

pub const keys = [_]ActionDef{ActionDef{ .modifier = ModKey, .code = c.XK_space, .action = openRofi }};

fn spawnWithShell(cmd: [:0]const u8) void {
    std.debug.print("cmd: {s}\n", .{cmd.ptr});
    const pid = std.os.linux.fork();
    if (pid == 0) {
        const env = std.c.environ;
        const args = [_:null]?[*:0]const u8{ "sh", "-c", cmd.ptr, null };
        _ = std.os.execvpeZ("sh", &args, env) catch {};
        std.os.exit(127);
    }
}

pub fn openRofi() void {
    spawnWithShell("rofi -show combi -modes combi -combi-modes \"window,drun,run\"");
}
