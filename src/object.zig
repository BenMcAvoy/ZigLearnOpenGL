const std = @import("std");

const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

const zmath = @import("zmath");

pub const Object = struct {
    position: zmath.Vec,
    scale: zmath.Vec,
    rotation: f32,

    colour: zmath.Vec,

    pub fn init(x: f32, y: f32) Object {
        return Object{
            .position = zmath.f32x4(x, y, 0.0, 0.0),
            .scale = zmath.f32x4(1.0, 1.0, 0.0, 0.0),
            .rotation = 0.0,

            .colour = zmath.f32x4(1.0, 1.0, 0.0, 1.0),
        };
    }

    pub fn setPosition(self: *Object, x: f32, y: f32) void {
        self.position = zmath.f32x4(x, y, 0.0, 0.0);
    }

    pub fn setScale(self: *Object, x: f32, y: f32) void {
        self.scale = zmath.f32x4(x, y, 0.0, 0.0);
    }

    pub fn setRotation(self: *Object, rotation: f32) void {
        self.rotation = rotation;
    }

    pub fn setColour(self: *Object, r: f32, g: f32, b: f32, a: f32) void {
        self.colour = zmath.f32x4(r, g, b, a);
    }

    pub fn translate(self: *Object, x: f32, y: f32) void {
        self.position[0] += x;
        self.position[1] += y;
    }

    pub fn scale(self: *Object, x: f32, y: f32) void {
        self.scale = zmath.mul(self.scale, zmath.f32x4(x, y, 0.0, 0.0));
    }

    pub fn rotate(self: *Object, rotation: f32) void {
        self.rotation += rotation;
    }

    pub fn getModelMatrix(self: Object) zmath.Mat {
        var model = zmath.identity();
        model = zmath.mul(zmath.translation(self.position[0], self.position[1], 0.0), model);
        const rotationRad = (-self.rotation) * std.math.pi / 180.0;
        model = zmath.mul(zmath.rotationZ(rotationRad), model);
        model = zmath.mul(zmath.scaling(self.scale[0], self.scale[1], 1.0), model);

        return model;
    }
};
