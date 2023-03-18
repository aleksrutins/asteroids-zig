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
        updateDrawGame();
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
        if(raylib.IsKeyPressed(raylib.KeyboardKey.KEY_P)) globals.pause = !globals.pause;

        if(!globals.pause) {
            // Player logic: 
            globals.player.update();
            for(&globals.shots) |*shot| {
                if(shot.active) shot.update();
            }
            for(&globals.bigMeteors) |*meteor| {
                if(meteor.active) meteor.update();
            }
            for(&globals.mediumMeteors) |*meteor| {
                if(meteor.active) meteor.update();
            }
            for(&globals.smallMeteors) |*meteor| {
                if(meteor.active) meteor.update();
            }
            
            // meteors vs. shots
            // for(&globals.shots) |*shot| {

            // }
        }
    } else {
        if(raylib.IsKeyPressed(raylib.KeyboardKey.KEY_SPACE)) {
            initGame();
            globals.gameOver = false;
        }
    }
}

fn drawGame() void {
    raylib.BeginDrawing();
    defer raylib.EndDrawing();
    raylib.ClearBackground(raylib.WHITE);
    if(!globals.gameOver) {
        // draw ship
        const pos = globals.player.position;
        const rot = globals.player.rotation * raylib.DEG2RAD;
        const v1 = raylib.Vector2 {
            .x = pos.x + math.sin(rot)*globals.shipHeight,
            .y = pos.y - math.cos(rot)*globals.shipHeight
        };
        const v2 = raylib.Vector2 {
            .x = pos.x - math.cos(rot)*(globals.playerBaseSize/2),
            .y = pos.y - math.sin(rot)*(globals.playerBaseSize/2),
        };
        const v3 = raylib.Vector2 {
            .x = pos.x + math.cos(rot)*(globals.playerBaseSize/2),
            .y = pos.y + math.sin(rot)*(globals.playerBaseSize/2)
        };
        raylib.DrawTriangle(v1, v2, v3, raylib.MAROON);
    }
}

fn updateDrawGame() void {
    updateGame();
    drawGame();
}