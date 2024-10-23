const std = @import("std");

const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const zmath = @import("zmath");

const ShaderProgram = @import("shader.zig").ShaderProgram;

const gl = zopengl.bindings;

pub const Camera = struct {
    position: zmath.Vec,
    rotation: f32,
    zoom: f32,

    projection: zmath.Mat,
    view: zmath.Mat,

    width: f32,
    height: f32,

    shaderProgram: *ShaderProgram,

    pub fn init(width: f32, height: f32) Camera {
        return Camera{ .position = zmath.Vec{ 0.0, 0.0, 0.0, 0.0 }, .rotation = 0.0, .zoom = 0.5, .projection = zmath.identity(), .view = zmath.identity(), .width = width, .height = height, .shaderProgram = undefined };
    }

    pub fn setShader(self: *Camera, shaderProgram: *ShaderProgram) void {
        self.shaderProgram = shaderProgram;
    }

    pub fn resize(self: *Camera, width: f32, height: f32) void {
        self.width = width;
        self.height = height;
    }

    // Update orthographic projection matrix and view matrix
    fn update(self: *Camera) void {
        const aspect = self.width / self.height;
        self.projection = zmath.orthographicRh(aspect / self.zoom, 1.0 / self.zoom, -1.0, 100.0);

        self.view = zmath.lookAtRh(self.position, (self.position + zmath.f32x4(0.0, 0.0, -1.0, 0.0)), zmath.f32x4(0.0, 1.0, 0.0, 0.0));
    }

    pub fn use(self: *Camera) void {
        self.update();

        self.shaderProgram.set_mat4("projection", self.projection);
        self.shaderProgram.set_mat4("view", self.view);
    }
};
