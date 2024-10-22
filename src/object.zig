const std = @import("std");

const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

const zmath = @import("zmath");

pub const Object = struct {
    position: zmath.Vec,
    scale: zmath.Vec,
    rotation: f32,

    pub fn init(position: zmath.Vec, scale: zmath.Vec, rotation: f32) Object {
        return Object{
            .position = position,
            .scale = scale,
            .rotation = rotation,
        };
    }

    pub fn getModelMatrix(self: Object) zmath.Mat {
        var model_matrix = zmath.identity();

        model_matrix = zmath.mul(model_matrix, zmath.translation(self.position[0], self.position[1], self.position[2]));
        model_matrix = zmath.mul(model_matrix, zmath.scaling(self.scale[0], self.scale[1], self.scale[2]));
        model_matrix = zmath.mul(model_matrix, zmath.rotationZ(self.rotation));

        return model_matrix;
    }
};
