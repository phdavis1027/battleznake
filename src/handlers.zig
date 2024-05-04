const std = @import("std");
const zap = @import("zap");
const types = @import("types.zig");


const not_found_logger = std.log.scoped(.not_found);
pub fn not_found(req: zap.Request) void {
  req.setStatus(zap.StatusCode.not_found);
  req.sendBody("Not found\n") catch return;

  not_found_logger.info("Not found: {s}", .{req.path.?});
}

const start_logger = std.log.scoped(.start);
pub fn start(r: zap.Request) void {
  const pga = std.heap.page_allocator;
  const board = std.json.parseFromSlice(types.Started, pga, r.body.?, .{.ignore_unknown_fields = true}) 
    catch |de_err| {
      r.setStatus(zap.StatusCode.bad_request);
      r.sendJson(
        \\ {
        \\   "error": "Invalid JSON"
        \\ }
      ) catch |reply_err| {
        start_logger.err("Failed to send error response: {}", .{reply_err});
        start_logger.err("Invalid JSON: error: {}", .{de_err});
        return;
      };


      start_logger.err("Invalid JSON: {}", .{de_err});
      return;
    };

  start_logger.info("Starting game: {}", .{board});
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

