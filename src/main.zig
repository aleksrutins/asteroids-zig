const std = @import("std");
const math = std.math;

const raylib = @import("raylib");
const globals = @import("globals.zig");

pub fn main() void {
    raylib.InitWindow(globals.screenWidth, globals.screenHeight, "hello world!");
    initGame();
    raylib.SetTargetFPS(60);

    defer raylib.CloseWindow();

    while (!raylib.WindowShouldClose()) {
        raylib.BeginDrawing();
        defer raylib.EndDrawing();
        
        raylib.ClearBackground(raylib.WHITE);
        raylib.DrawFPS(10, 10);

        
    }
}

fn initGame() void {
    var correctRange = false;

    globals.victory = false;
    globals.pause = false;

    globals.shipHeight = (globals.playerBaseSize/2) / math.tan(20 * raylib.DEG2RAD);

    globals.player.init();

    globals.destroyedMeteorsCount = 0;

    for (&globals.shots) |*shot| {
        shot.init();
    }

    for (&globals.bigMeteors) |*meteor| {
        meteor.initBig(&correctRange);
    }

    for (&globals.mediumMeteors) |*meteor| {
        meteor.init(20);
    }

    for (&globals.smallMeteors) |*meteor| {
        meteor.init(10);
    }

    globals.midMeteorsCount = 0;
    globals.smallMeteorsCount = 0;
}

fn updateGame() void {
    if(!globals.gameOver) {
        if(raylib.IsKeyPressed('P')) globals.pause = !globals.pause;

        if(!globals.pause) {
            // Player logic: 
            if(raylib.IsKeyDown(raylib.KeyboardKey.KEY_LEFT)) globals.player.rotation -= 5;

        }
    }
}