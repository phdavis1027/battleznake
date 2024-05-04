const std = @import("std");
const clap = @import("clap");
const zap = @import("zap");
const handlers = @import("handlers.zig");


pub fn main() anyerror!void {
  const allocator = std.heap.page_allocator;

  // const init_log = std.log.scoped(.init);

  const params = comptime clap.parseParamsComptime(
      \\-p, --port <u16>       Which port to listen on. 
      \\-h, --help             Print this help message.
  );

  var diag = clap.Diagnostic{};
  var res = clap.parse(clap.Help, &params, clap.parsers.default, .{
    .diagnostic = &diag,
    .allocator = allocator,
  }) catch |err| {
    diag.report(std.io.getStdErr().writer(), err) catch {};
    return err;
  };
  defer res.deinit();

  var router = zap.Router.init(allocator, .{
    .not_found = handlers.not_found
  }); 

  try router.handle_func_unbound("/", handlers.root);
  try router.handle_func_unbound("/start", handlers.start);
  try router.handle_func_unbound("/move", handlers.move);

  var listener = zap.HttpListener.init(.{
    .port = res.args.port.?,
    .on_request = router.on_request_handler(),
    .log = true,
  });

  try listener.listen();

  // start worker threads
  zap.start(.{
      .threads = 2,

      // Must be 1 if state is shared
      .workers = 1,
  });
}
