const std = @import("std");

pub const Started = struct {
  game: Game,
  turn: i32,
  board: Board,
  you: Snake,
};

pub const Ruleset = struct {
  name: []u8,
  version: []u8,
  settings: RulesetSettings,
};

pub const RulesetSettings = struct {
  foodSpawnChance: i32,
  minimumFood: i32,
  hazardDamagePerTurn: i32,
  hazardMap: []u8,
  royale: RoyaleSettings,
  squad: SquadsSettings,
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
  id: []u8,
  ruleset: Ruleset,
  map: []u8,
  timeout: i32,
  source: []u8,
};

pub const Point = struct {
  x: i32,
  y: i32,
};

pub const Board = struct {
  height: i32,
  width: i32,
  food: []Point,
  hazards: []Point,
  snakes: []Snake,
};

// Ignore shout and customizations
pub const Snake = struct { 
  id: []u8,
  name: []u8,
  latency: []u8,
  health: i32,
  body: []Point,
  head: Point,
  length: i32,
  squad: []u8,
};

pub const MoveIn = struct {
  game: Game,
  turn: i32,
  board: Board,
  you: Snake,
};

pub const CellBoard = struct {
  cells: std.ArrayList(Cell)  
};

// TODO: Considering how you can pack this 
// as much as possible
pub const Cell = struct {
  snake_id: u8,
  next_idx: u8,
  food: bool,
  hazard: bool,
};
