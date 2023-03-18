const raylib = @import("raylib");
const types = @import("types.zig");

pub const playerBaseSize = 20.0;
pub const playerSpeed = 6.0;
pub const playerMaxShots = 10;

pub const meteorsSpeed = 2;
pub const maxBigMeteors = 4;
pub const maxMediumMeteors = 8;
pub const maxSmallMeteors = 16;

pub const screenWidth = 800;
pub const screenHeight = 450;

pub var gameOver = false;
pub var pause = false;
pub var victory = false;

pub var shipHeight: f32 = 0.0;

pub var player = types.Player {};
pub var shots = [_]types.Shoot {.{}} ** playerMaxShots;
pub var bigMeteors = [_]types.Meteor {.{}} ** maxBigMeteors;
pub var mediumMeteors = [_]types.Meteor {.{}} ** maxMediumMeteors;
pub var smallMeteors = [_]types.Meteor {} ** maxSmallMeteors;

pub var midMeteorsCount: i32 = 0;
pub var smallMeteorsCount: i32 = 0;
pub var destroyedMeteorsCount: i32 = 0;