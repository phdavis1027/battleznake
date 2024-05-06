const zap = @import("zap");
const types = @import("types.zig");
const std = @import("std");

pub const Snake = struct {
  const Self = @This();

  allocator: std.mem.Allocator,
  games: std.StringHashMap(*types.CellBoard),

  pub fn init(allocator: std.mem.Allocator) !Self {
    return .{
      .allocator = allocator,
      .games = std.StringHashMap(*types.CellBoard).init(allocator),
    };
  }

  const start_logger = std.log.scoped(.start);
  pub fn initGameState(self: *Self, req: zap.Request) void {
    var started = std.json.parseFromSlice(types.Started, self.allocator, req.body.?, .{.ignore_unknown_fields = true}) 
      catch |de_err| {
        req.setStatus(zap.StatusCode.bad_request);
        req.sendJson(
          \\ {
          \\   "error": "Invalid JSON"
          \\ }
        ) catch |reply_err| {
          start_logger.err("Failed to send error response: {}", .{reply_err});
          start_logger.err("Invalid JSON: {s}, error: {}", .{req.body.?, de_err});
          return;
        };


        start_logger.err("Invalid JSON: {}", .{de_err});
        return;
      };

    self.initGameStateInner(&started.value, &req);
  }

  pub fn initGameStateInner(self: *Self, started: *types.Started, req: *const zap.Request) void {
    const cellBoard = self.allocator.alloc(types.CellBoard, 1) catch |mem_err| {
      req.setStatus(zap.StatusCode.internal_server_error);
      req.sendJson(
        \\ {
        \\   "error": "Failed to allocate memory"
        \\ }
      ) catch |reply_err| {
        start_logger.err("Failed to send error response: {}", .{reply_err});
        start_logger.err("Failed to allocate memory: {}", .{mem_err});
        return;
      };

      start_logger.err("Failed to allocate memory: {}", .{mem_err});
      return;
    };
    
    self.games.putNoClobber(started.game.id, &cellBoard[0]) catch |put_err| {
      req.setStatus(zap.StatusCode.internal_server_error);
      req.sendJson(
        \\ {
        \\   "error": "Failed to store game state"
        \\ }
      ) catch |reply_err| {
        start_logger.err("Failed to send error response: {}", .{reply_err});
        start_logger.err("Failed to store game state: {}", .{put_err});
        return;
      };

      start_logger.err("Failed to store game state: {}", .{put_err});
      return;
    };

    // Initialize the cell board
    const board: *types.CellBoard =  @ptrCast(&cellBoard[0]);
    const dims = started.board.width * started.board.height;
    var i: i32 = 0;
    while (i < dims) : (i += 1) {
      board.cells.append(types.Cell {
        .snakeId = 0,
        .nextIdx = 0,
        .food = false,
        .hazard = false,
      }) catch |append_err| {
        req.setStatus(zap.StatusCode.internal_server_error);
        req.sendJson(
          \\ {
          \\   "error": "Failed to append cell"
          \\ }
        ) catch |reply_err| {
          start_logger.err("Failed to send error response: {}", .{reply_err});
          start_logger.err("Failed to append cell: {}", .{append_err});
          return;
        };

        start_logger.err("Failed to append cell: {}", .{append_err});
        return;
      };
    }

    for (started.board.snakes) |snake| {
      std.debug.print("{s}", .{snake.id});
    }

    for (started.board.food) |food| {
      std.debug.print("{}", .{food});
    }

    for (started.board.hazards) |hazard| {
      std.debug.print("{}", .{hazard});
    }
  }

  const move_logger = std.log.scoped(.move);
  pub fn makeMove(self: *Self, req: zap.Request) void { 
    var moveIn = std.json.parseFromSlice(types.MoveIn, self.allocator, req.body.?, .{.ignore_unknown_fields = true}) 
      catch |de_err| {
        req.setStatus(zap.StatusCode.bad_request);
        req.sendJson(
          \\ {
          \\   "error": "Invalid JSON"
          \\ }
        ) catch |reply_err| {
          move_logger.err("Failed to send error response: {}", .{reply_err});
          move_logger.err("Invalid JSON: {s}, error: {}", .{req.body.?, de_err});
          return;
        };


        move_logger.err("Invalid JSON: {}", .{de_err});
        return;
      };
    
    self.makeMoveInner(&moveIn.value);
  }

  pub fn makeMoveInner(self: *Self, moveIn: *types.MoveIn) void {
    self.updateGameState(moveIn);

  }

  pub fn updateGameState(_: *Self, _: *types.MoveIn) void {
  }
};
