const std = @import("std");
const zap = @import("zap");

const types = @import("types.zig");
const logic = @import("logic.zig");


const not_found_logger = std.log.scoped(.not_found);
pub fn not_found(req: zap.Request) void {
  req.setStatus(zap.StatusCode.not_found);
  req.sendBody("Not found\n") catch return;

  not_found_logger.info("Not found: {s}", .{req.path.?});
}

const root_logger = std.log.scoped(.root);
pub fn root(r: zap.Request) void {
  r.setStatus(zap.StatusCode.ok);
  r.sendJson(
    \\ {
    \\   "author": "Phillip Davis"
    \\ }
  ) catch return;

  root_logger.info("Initializing snake", .{});
}
