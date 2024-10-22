const std = @import("std");

const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const zmath = @import("zmath");

const utils = @import("utils.zig");

const ShaderProgram = @import("shader.zig").ShaderProgram;
const Buffers = @import("buffers.zig").Buffers;
const Object = @import("object.zig").Object;

const gl = zopengl.bindings;

fn resizeCallback(
    window: *glfw.Window,
    width: i32,
    height: i32,
) callconv(.C) void {
    _ = window;
    gl.viewport(0, 0, width, height);
}

const rect_vertices = [_]f32{
    -0.5, 0.5, 0.0, // TL  0
    0.5, 0.5, 0.0, // TR   1
    -0.5, -0.5, 0.0, // BL 2
    0.5, -0.5, 0.0, // BR  3
};

const rect_indices = [_]u32{
    0, 1, 3,
    2, 3, 0,
};

pub fn main() !void {
    try glfw.init();
    defer glfw.terminate();

    const window = try utils.newWindow("Zig GUI", 800, 800);
    defer window.destroy();

    _ = window.setFramebufferSizeCallback(resizeCallback);

    const vx_source = @embedFile("shaders/vert.glsl");
    const fx_source = @embedFile("shaders/frag.glsl");

    const shader = try ShaderProgram.init(vx_source, fx_source);
    const buffers = try Buffers.init(&rect_vertices, &rect_indices);

    const object_1 = Object.init(zmath.f32x4(0.0, 0.0, 0.0, 0.0), zmath.f32x4(0.5, 0.5, 0.5, 0.0), 0.0);
    const object_2 = Object.init(zmath.f32x4(0.0, 0.0, 0.0, 0.0), zmath.f32x4(1.0, 0.25, 0.5, 0.0), 0.0);
    const objects = [_]Object{ object_1, object_2 };

    while (!window.shouldClose() and window.getKey(.escape) != .press) {
        glfw.pollEvents();

        gl.clearBufferfv(gl.COLOR, 0, &[_]f32{ 0.1, 0.1, 0.1, 1.0 });

        shader.use();
        buffers.use();

        for (objects) |obj| {
            const model_matrix: zmath.Mat = obj.getModelMatrix();
            shader.set_mat4("model_matrix", model_matrix);
            gl.drawElements(gl.TRIANGLES, @intCast(rect_indices.len), gl.UNSIGNED_INT, null);
        }

        window.swapBuffers();
    }
}
