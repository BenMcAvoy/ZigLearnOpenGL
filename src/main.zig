const std = @import("std");

const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const zmath = @import("zmath");

const utils = @import("utils.zig");

const ShaderProgram = @import("shader.zig").ShaderProgram;
const Buffers = @import("buffers.zig").Buffers;
const Object = @import("object.zig").Object;
const Camera = @import("camera.zig").Camera;

const gl = zopengl.bindings;

fn resizeCallback(
    window: *glfw.Window,
    width: i32,
    height: i32,
) callconv(.C) void {
    _ = window;
    gl.viewport(0, 0, width, height);
    camera.resize(@floatFromInt(width), @floatFromInt(height));
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

var camera = Camera.init(800, 800);

pub fn main() !void {
    try glfw.init();
    defer glfw.terminate();

    const window = try utils.newWindow("Zig GUI", 800, 800);
    defer window.destroy();

    _ = window.setFramebufferSizeCallback(resizeCallback);

    const vx_source = @embedFile("shaders/vert.glsl");
    const fx_source = @embedFile("shaders/frag.glsl");

    const buffers = try Buffers.init(&rect_vertices, &rect_indices);

    var shader = try ShaderProgram.init(vx_source, fx_source);
    camera.setShader(&shader);

    var object_1 = Object.init(0, 0);
    var object_2 = Object.init(0, 0);
    var object_3 = Object.init(0, 0);

    object_1.setScale(1.0, 0.2);
    object_2.setScale(0.2, 1.0);
    object_3.setScale(0.5, 0.5);

    object_1.setColour(1.0, 0.0, 0.0, 1.0);
    object_2.setColour(0.0, 1.0, 0.0, 1.0);

    const objects = [_]*Object{ &object_1, &object_2, &object_3 };

    var fps_acc: f64 = 0.0;
    var fps_count: f32 = 0;

    var time: f64 = 0;
    while (!window.shouldClose() and window.getKey(.escape) != .press) {
        fps_acc += glfw.getTime() - time;
        fps_count += 1;

        if (fps_acc >= 1.0) {
            std.debug.print("FPS: {d}\n", .{fps_count / fps_acc});
            fps_acc = 0.0;
            fps_count = 0;
        }

        time = glfw.getTime();

        glfw.pollEvents();

        gl.clearBufferfv(gl.COLOR, 0, &[_]f32{ 0.1, 0.1, 0.1, 1.0 });

        shader.use();
        buffers.use();
        camera.use();

        object_1.rotate(0.5);
        object_2.rotate(-0.5);

        object_3.setPosition(@floatCast(@cos(time * 2)), @floatCast(@sin(time * 2)));
        object_3.rotate(5.0);

        if (window.getKey(.up) == .press) {
            camera.zoom += 0.025;
        }

        if (window.getKey(.down) == .press) {
            if (camera.zoom > 0)
                camera.zoom -= 0.025;
        }

        if (window.getKey(.w) == .press) {
            camera.position[1] += 1 / camera.zoom;
        } else if (window.getKey(.s) == .press) {
            camera.position[1] -= 1 / camera.zoom;
        }

        if (window.getKey(.a) == .press) {
            camera.position[0] -= (1 / 200) / camera.zoom;
        } else if (window.getKey(.d) == .press) {
            camera.position[0] += (1 / 200) / camera.zoom;
        }

        for (objects) |obj| {
            const model_matrix: zmath.Mat = obj.getModelMatrix();
            shader.set_mat4("model", model_matrix);
            shader.set_vec4("colour", obj.colour);
            gl.drawElements(gl.TRIANGLES, @intCast(rect_indices.len), gl.UNSIGNED_INT, null);
        }

        window.swapBuffers();
    }
}
