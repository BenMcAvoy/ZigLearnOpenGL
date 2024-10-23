const std = @import("std");

const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const zmath = @import("zmath");
const zgui = @import("zgui");

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

const window_width = 1024;
const window_height = 768;

var camera = Camera.init(window_width, window_height);

pub fn main() !void {
    try glfw.init();
    defer glfw.terminate();

    const window = try utils.newWindow("Zig GUI", window_width, window_height);
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

    zgui.init(std.heap.c_allocator);
    zgui.backend.init(window);
    defer zgui.deinit();
    defer zgui.backend.deinit();

    var time: f64 = 0;
    while (!window.shouldClose() and window.getKey(.escape) != .press) {
        time = glfw.getTime();

        glfw.pollEvents();

        gl.clearBufferfv(gl.COLOR, 0, &[_]f32{ 0.1, 0.1, 0.1, 1.0 });
        const fb_size = window.getFramebufferSize();
        zgui.backend.newFrame(@intCast(fb_size[0]), @intCast(fb_size[1]));

        // Render FPS in top left
        zgui.getBackgroundDrawList().addText(.{ 16, 16 }, 0xFFFFFFFF, "FPS: {d}", .{zgui.io.getFramerate()});

        var i: i32 = 0;
        if (zgui.begin("Objects", .{})) {
            for (objects) |obj| {
                i += 1;
                zgui.pushIntId(i);
                zgui.text("Object", .{});

                _ = zgui.sliderFloat2("Position", .{ .v = @ptrCast(&obj.position), .min = -10, .max = 10 });
                _ = zgui.sliderFloat2("Scale", .{ .v = @ptrCast(&obj.scale), .min = 0.1, .max = 10 });
                _ = zgui.sliderFloat("Rotation", .{ .v = &obj.rotation, .min = 0, .max = 360 });
                _ = zgui.colorEdit4("Colour", .{ .col = &obj.colour });

                zgui.popId();
            }
        }
        zgui.end();

        if (zgui.begin("Camera", .{})) {
            _ = zgui.sliderFloat2("Position", .{ .v = @ptrCast(&camera.position), .min = -10, .max = 10 });
            _ = zgui.sliderFloat("Zoom", .{ .v = &camera.zoom, .min = 0.05, .max = 10 });
        }
        zgui.end();

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
            if (camera.zoom > 0.05)
                camera.zoom -= 0.025;
        }

        if (window.getKey(.w) == .press) {
            camera.position[1] += 0.1;
        } else if (window.getKey(.s) == .press) {
            camera.position[1] -= 0.1;
        }

        if (window.getKey(.a) == .press) {
            camera.position[0] -= 0.1;
        } else if (window.getKey(.d) == .press) {
            camera.position[0] += 0.1;
        }

        for (objects) |obj| {
            const model_matrix: zmath.Mat = obj.getModelMatrix();
            shader.set_mat4("model", model_matrix);
            shader.set_vec4("colour", obj.colour);
            gl.drawElements(gl.TRIANGLES, @intCast(rect_indices.len), gl.UNSIGNED_INT, null);
        }

        zgui.backend.draw();
        window.swapBuffers();
    }
}
