const std = @import("std");
const math = std.math;

const raylib = @import("raylib");
const Vector2 = raylib.Vector2;
const Vector3 = raylib.Vector3;
const Color = raylib.Color;

const globals = @import("globals.zig");

pub const Player = struct {
    position: Vector2 = .{.x = 0, .y = 0},
    speed: Vector2 = .{.x = 0, .y = 0},
    acceleration: f32 = 0,
    rotation: f32 = 0,
    color: Color = raylib.LIGHTGRAY,

    pub fn init(self: *@This()) void {
        self.position = Vector2.zero();
        self.speed = Vector2.zero();
        self.acceleration = 0;
        self.rotation = 0;
        self.color = raylib.LIGHTGRAY;
    }

    pub fn collider(self: @This()) Vector3 {
        return Vector3.new(
            self.position.x + math.sin(self.rotation * raylib.DEG2RAD)*(globals.shipHeight / 2.5),
            self.position.y - math.cos(self.rotation * raylib.DEG2RAD)*(globals.shipHeight / 2.5),
            12
        );
    }

    pub fn update(self: *@This()) void {
        // rotation
        if(raylib.IsKeyDown(raylib.KeyboardKey.KEY_LEFT)) self.rotation -= 5;
        if(raylib.IsKeyDown(raylib.KeyboardKey.KEY_RIGHT)) self.rotation += 5;

        // speed
        self.speed.x = math.sin(self.rotation * raylib.DEG2RAD) * globals.playerSpeed;
        self.speed.y = math.cos(self.rotation * raylib.DEG2RAD) * globals.playerSpeed;

        // acceleration
        if(raylib.IsKeyDown(raylib.KeyboardKey.KEY_UP)) {
            if(self.acceleration < 1) self.acceleration += 0.04;
        } else {
            if(self.acceleration > 0) {
                self.acceleration -= 0.02;
            } else if(self.acceleration < 0) self.acceleration = 0;
        }
        if(raylib.IsKeyDown(raylib.KeyboardKey.KEY_DOWN)) {
            if(self.acceleration > 0) {
                self.acceleration -= 0.04;
            } else if(self.acceleration < 0) {
                self.acceleration = 0;
            }
        }

        // movement
        self.position.x += (self.speed.x*self.acceleration);
        self.position.y -= (self.speed.y*self.acceleration);

        // collision logic: player vs walls
        if (self.position.x > globals.screenWidth + globals.shipHeight) {
             self.position.x = -(globals.shipHeight);
        }
        else if (self.position.x < -(globals.shipHeight)) self.position.x = globals.screenWidth + globals.shipHeight;
        if (self.position.y > (globals.screenHeight + globals.shipHeight)) {
            self.position.y = -(globals.shipHeight);
        } else if (self.position.y < -(globals.shipHeight)) self.position.y = globals.screenHeight + globals.shipHeight;

        // shooting logic
        if(raylib.IsKeyPressed(raylib.KeyboardKey.KEY_SPACE)) {
            for(&globals.shots) |*shot| {
                if(!shot.active) {
                    shot.position = .{
                        .x = self.position.x + math.sin(self.rotation * raylib.DEG2RAD)*globals.shipHeight,
                        .y = self.position.y - math.cos(self.rotation * raylib.DEG2RAD)*globals.shipHeight
                    };
                    shot.active = true;
                    shot.speed = .{
                        .x = 1.5*math.sin(self.rotation * raylib.DEG2RAD)*globals.playerSpeed,
                        .y = 1.5*math.cos(self.rotation * raylib.DEG2RAD)*globals.playerSpeed
                    };
                    shot.rotation = self.rotation;
                    break;
                }
            }
        }
    }

    pub fn checkMeteorCollisions(self: @This()) void {
        const actCollider = self.collider();

        for(globals.bigMeteors) |meteor| {
            if(raylib.CheckCollisionCircles(.{.x = actCollider.x, .y = actCollider.y}, actCollider.z, meteor.position, meteor.radius) and meteor.active) globals.gameOver = true;
        }
        for(globals.mediumMeteors) |meteor| {
            if(raylib.CheckCollisionCircles(.{.x = actCollider.x, .y = actCollider.y}, actCollider.z, meteor.position, meteor.radius) and meteor.active) globals.gameOver = true;
        }
        for(globals.smallMeteors) |meteor| {
            if(raylib.CheckCollisionCircles(.{.x = actCollider.x, .y = actCollider.y}, actCollider.z, meteor.position, meteor.radius) and meteor.active) globals.gameOver = true;
        }
    }
};

pub const Shoot = struct {
    position: Vector2 = .{.x = 0, .y = 0},
    speed: Vector2 = .{.x = 0, .y = 0},
    radius: f32 = 2,
    rotation: f32 = 0,
    lifeSpan: i32 = 0,
    active: bool = false,
    color: Color = raylib.BLACK,

    pub fn init(self: *@This()) void {
        self.position = Vector2.zero();
        self.speed = Vector2.zero();
        self.radius = 2;
        self.active = false;
        self.lifeSpan = 0;
        self.color = raylib.BLACK;
    }

    pub fn update(self: *@This()) void {
        if(self.active) {
            // life timer
            self.lifeSpan += 1;

            // logic
            self.position.x += self.speed.x;
            self.position.y -= self.speed.y;

            if(
                self.position.x > globals.screenWidth + self.radius
            or  self.position.x < 0 - self.radius
            or  self.position.y > globals.screenHeight + self.radius
            or  self.position.y < 0 - self.radius
                ) {
                self.active = false;
                self.lifeSpan = 0;
            }

            // life
            if(self.lifeSpan >= 60) {
                self.position = .{.x = 0, .y = 0};
                self.speed = .{.x = 0, .y = 0};
                self.lifeSpan = 0;
                self.active = false;
            }
        }
    }
};

pub const Meteor = struct {
    position: Vector2 = .{.x = 0, .y = 0},
    speed: Vector2 = .{},
    radius: f32 = 0,
    active: bool = false,
    color: Color = raylib.BLUE,

    pub fn initBig(self: *@This(), correctRange: *bool) void {
        var posx = @intToFloat(f32, raylib.GetRandomValue(0, globals.screenWidth));

        while (!correctRange.*) {
            if (posx > globals.screenWidth/2 - 150 and posx < globals.screenWidth/2 + 150) {
                posx = @intToFloat(f32, raylib.GetRandomValue(0, globals.screenWidth));
            } else {
                correctRange.* = true;
            }
        }

        correctRange.* = false;

        var posy = @intToFloat(f32, raylib.GetRandomValue(0, globals.screenHeight));

        while(!correctRange.*) {
            if(posy > globals.screenHeight/2 - 150 and posy < globals.screenHeight/2 + 150) {
                posy = @intToFloat(f32, raylib.GetRandomValue(0, globals.screenHeight));
            } else {
                correctRange.* = true;
            }
        }
        
        self.position = .{.x = posx, .y = posy};


        correctRange.* = false;
        var velx = @intToFloat(f32, raylib.GetRandomValue(-globals.meteorsSpeed, globals.meteorsSpeed));
        var vely = @intToFloat(f32, raylib.GetRandomValue(-globals.meteorsSpeed, globals.meteorsSpeed));

        while(!correctRange.*) {
            if(velx == 0 and vely == 0) {
                velx = @intToFloat(f32, raylib.GetRandomValue(-globals.meteorsSpeed, globals.meteorsSpeed));
                vely = @intToFloat(f32, raylib.GetRandomValue(-globals.meteorsSpeed, globals.meteorsSpeed));
            } else {
                correctRange.* = true;
            }
        }

        self.speed = .{.x = velx, .y = vely};
        self.radius = 40;
        self.active = true;
        self.color = raylib.DARKGRAY;
    }

    pub fn init(self: *@This(), radius: f32) void {
        self.position = .{.x = -100, .y = -100};
        self.speed = .{.x = 0, .y = 0};
        self.radius = radius;
        self.active = false;
        self.color = raylib.GRAY;
    }

    pub fn update(self: *@This()) void {
        self.position.x += self.speed.x;
        self.position.y -= self.speed.y;

        // collision logic vs. wall
        if(self.position.x > globals.screenWidth + self.radius) self.position.x = -self.radius;
        if(self.position.x < 0 - self.radius) self.position.x = globals.screenWidth + self.radius;
        if(self.position.y > globals.screenHeight + self.radius) self.position.y = -self.radius;
        if(self.position.y < 0 - self.radius) self.position.y = globals.screenHeight + self.radius;
    }
};