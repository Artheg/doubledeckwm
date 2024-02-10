const std = @import("std");
const c = @import("c.zig");

pub const Arg = union { String: [:0]const u8 };

pub const ActionType = enum { withArg, noArg };

pub const ActionFunc = union(ActionType) { withArg: *const fn (arg: Arg) anyerror!void, noArg: *const fn () anyerror!void };

const ActionDef = struct { modifier: u32, code: c.KeySym, action: ActionFunc, arg: ?Arg };

const ModKey = c.Mod4Mask;

// Mod + l/h    Cycle through decks
// Mod + j/k    Cycle through focused deck's windows
// Mod + f      Toggle fullscreen of the active window
// S-Mod + l/h  Cycle through workspaces
// Mod + i/d    Increase/decrease gaps
// S-Mod + c    Close window
pub const keys = [_]ActionDef{
    ActionDef{ .modifier = c.Mod4Mask | c.ShiftMask, .code = c.XK_c, .action = ActionFunc{ .noArg = closeWindow }, .arg = null },
    spawnWithMod(c.XK_space, "rofi -show combi -modes combi -combi-modes \"window,drun,run\""),
    spawnWithMod(c.XK_Return, "st"),
    spawnWithMod(c.XK_p, "power"),
};

fn closeWindow() anyerror!void {
    std.debug.print("close window\n", .{});
}

fn spawn(key: c.KeySym, cmd: [:0]const u8) ActionDef {
    return ActionDef{ .modifier = 0, .code = key, .action = ActionFunc{ .withArg = spawnWithShell }, .arg = Arg{ .String = cmd } };
}

fn spawnWithMod(key: c.KeySym, cmd: [:0]const u8) ActionDef {
    return ActionDef{ .modifier = ModKey, .code = key, .action = ActionFunc{ .withArg = spawnWithShell }, .arg = Arg{ .String = cmd } };
}

pub fn spawnWithShell(arg: Arg) !void {
    const cmd = arg.String;
    std.debug.print("cmd: {s}\n", .{cmd.ptr});
    const pid = std.os.linux.fork();
    if (pid == 0) {
        // const args = [_:null]?[*:0]const u8{ "sh", "-c", cmd.ptr, null };
        const argv = &[_][]const u8{ "sh", "-c", cmd };
        const allocator = std.heap.page_allocator;
        const runResult = try std.ChildProcess.run(.{ .allocator = allocator, .argv = argv });
        if (runResult.stderr.len > 0) {
            std.debug.print("error: {s}", .{runResult.stderr});
        }
        // const env = std.c.environ;
        // _ = std.os.execvpeZ("sh", &args, env) catch {};
        std.os.exit(127);
    }
}
