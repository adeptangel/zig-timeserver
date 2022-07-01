const network = @import("zig-network/network.zig");
const std = @import("std");
const cTime = @cImport(@cInclude("time.h"));

pub fn main() !void {
    try timeserver();
}

fn timeserver() !void {
    var gpa = std.heap.GeneralPurposeAllocator(.{}){};
    defer _ = gpa.deinit();
    const alloc = gpa.allocator();

    var sock = try network.Socket.create(.ipv4, .tcp);
    defer sock.close();

    try sock.bindToPort(9999);

    try sock.listen();

    while (true) {
        var client = try sock.accept();
        defer client.close();

        std.debug.print("Client connected from {}\n", .{try client.getLocalEndPoint()});

        const currentTime: i64 = std.time.timestamp();
        // var nowBuf: [8]u8 = undefined;
        // const now = cTime.strftime(nowBuf, 8, "%H:%M:%S", currentTime);
        
        _ = try client.send(try std.fmt.allocPrint(alloc, "{}", .{currentTime}));
    }
}
