const std = @import("std");
const clap = @import("clap");
const zap = @import("zap");
const handlers = @import("handlers.zig");
const logic = @import("logic.zig");


pub fn main() anyerror!void {
  var gpa = std.heap.GeneralPurposeAllocator(.{}){};
  const allocator = gpa.allocator();
  defer {
    _ = gpa.deinit();
  }

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

  var snake = logic.Snake.init(allocator);

  try router.handle_func_unbound("/", handlers.root);
  try router.handle_func("/start", &snake, &logic.Snake.initGameState);
  try router.handle_func("/move", &snake, &logic.Snake.makeMove);

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
