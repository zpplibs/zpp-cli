const std = @import("std");
const builtin = @import("builtin");
const build_options = @import("build_options");

const zigmod = @import("zigmod");
const util = zigmod.util;

const CliError = error {
    UnknownCommand,
};

const commands = struct {
    const fetch = zigmod.commands_to_bootstrap.fetch;
    usingnamespace zigmod.commands_core;
};

fn printVersion() void {
    util.print("zpp {s} {s} {s}", .{
        build_options.version,
        @tagName(builtin.os.tag),
        @tagName(builtin.cpu.arch),
    });
}

fn printHelp(mod_only: bool) void {
    if (mod_only) {
        util.print("The available subcommands are:", .{});
    } else {
        util.print("The available commands are:", .{});
        util.print("  - help", .{});
        util.print("  - version", .{});
    }
    inline for (std.meta.declarations(commands)) |decl| {
        util.print("  - mod {s}", .{decl.name});
    }
    util.print("", .{});
    printVersion();
}

pub fn main() !void {
    const gpa = std.heap.c_allocator;

    const proc_args = try std.process.argsAlloc(gpa);
    const args = proc_args[1..];

    if (
        args.len == 0 or
        std.mem.eql(u8, args[0], "help") or
        std.mem.eql(u8, args[0], "--help") or
        std.mem.eql(u8, args[0], "-h")
    ) {
        printHelp(false);
        return;
    }
    
    if (
        std.mem.eql(u8, args[0], "version") or
        std.mem.eql(u8, args[0], "--version")
    ) {
        printVersion();
        return;
    }

    if (!std.mem.eql(u8, args[0], "mod")) {
        util.fail("Unknown command \"{s}\" for \"zpp\"", .{ args[0] });
        return CliError.UnknownCommand;
    }
    
    if (args.len == 1) {
        printHelp(true);
        return;
    }
    
    const offset: usize = 1;

    if (builtin.os.tag == .windows) {
        const win32 = @import("win32");
        const console = win32.system.console;
        const h_out = console.GetStdHandle(console.STD_OUTPUT_HANDLE);
        _ = console.SetConsoleMode(h_out, console.CONSOLE_MODE.initFlags(.{
            .ENABLE_PROCESSED_INPUT = 1, //ENABLE_PROCESSED_OUTPUT
            .ENABLE_LINE_INPUT = 1, //ENABLE_WRAP_AT_EOL_OUTPUT
            .ENABLE_ECHO_INPUT = 1, //ENABLE_VIRTUAL_TERMINAL_PROCESSING
        }));
    }
    
    try zigmod.init();
    defer zigmod.deinit();

    inline for (std.meta.declarations(commands)) |decl| {
        if (std.mem.eql(u8, args[offset], decl.name)) {
            const cmd = @field(commands, decl.name);
            try cmd.execute(args[offset+1..]);
            return;
        }
    }

    const prefix = try std.fmt.allocPrint(gpa, "zigmod-{s}", .{ args[offset] });
    defer gpa.free(prefix);
    
    var sub_cmd_args = std.ArrayList([]const u8).init(gpa);
    defer sub_cmd_args.deinit();
    
    try sub_cmd_args.append(prefix);
    for (args[offset+1..]) |item| try sub_cmd_args.append(item);
    const result = std.ChildProcess.exec(.{
        .allocator = gpa,
        .argv = sub_cmd_args.items,
    }) catch |e| switch (e) {
        error.FileNotFound => {
            util.fail(
                "Unknown command \"{s}\" for \"zpp mod\"",
                .{ args[offset] },
            );
        },
        else => return e,
    };
    try std.io.getStdOut().writeAll(result.stdout);
    try std.io.getStdErr().writeAll(result.stderr);
}
