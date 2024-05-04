const std = @import("std");

pub const Started = struct {
  game: Game,
  turn: i32,
  board: Board,
  you: Snake,
};

pub const Ruleset = struct {
  name: []const u8,
  version: []const u8,
  settings: RulesetSettings,
};

pub const RulesetSettings = struct {
  foodSpawnChance: i32,
  minimumFood: i32,
  hazardDamagePerTurn: i32,
  royale: RoyaleSettings,
  squads: SquadsSettings,
};

pub const RoyaleSettings = struct {
  shrinkEveryNTurns: i32,
};

pub const SquadsSettings = struct {
  allowBodyCollisions: bool,
  sharedElimination: bool,
  sharedHealth: bool,
  sharedLength: bool,
};

pub const Game = struct {
  id: []const u8,
  ruleset: Ruleset,
  map: []const u8,
  timeout: i32,
  source: []const u8,
};

pub const Point = struct {
  x: i32,
  y: i32,
};

pub const Board = struct {
  height: i32,
  width: i32,
  food: std.ArrayList(Point),
  hazards: std.ArrayList(Point),
  snakes: std.ArrayList(Snake),
};

// Ignore shout and customizations
pub const Snake = struct { 
  id: []const u8,
  name: []const u8,
  health: i32,
  body: std.ArrayList(Point),
  head: Point,
  length: i32,
  latency: []const u8,
  squad: []const u8,
};
