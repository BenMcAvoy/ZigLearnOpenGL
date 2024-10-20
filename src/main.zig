const std = @import("std");

const imgui = @import("zgui");
const glfw = @import("zglfw");
const zopengl = @import("zopengl");

fn newWindow(name: [:0]const u8, width: i32, height: i32) !*glfw.Window {
    const gl_major = 4;
    const gl_minor = 6;

    glfw.windowHintTyped(.context_version_major, gl_major);
    glfw.windowHintTyped(.context_version_minor, gl_minor);
    glfw.windowHintTyped(.opengl_profile, .opengl_core_profile);

    glfw.windowHintTyped(.decorated, false);

    if (@import("builtin").os.tag == .macos) {
        glfw.windowHintTyped(.opengl_forward_compat, true);
    }

    glfw.windowHintTyped(.client_api, .opengl_api);
    glfw.windowHintTyped(.doublebuffer, true);

    std.debug.print("Creating window with name {s} and size {d}x{d}\n", .{ name, width, height });
    const window = try glfw.Window.create(width, height, name, null);

    glfw.makeContextCurrent(window); // Set OpenGL context to the window
    glfw.swapInterval(1); // Enable vsync

    try zopengl.loadCoreProfile(glfw.getProcAddress, gl_major, gl_minor);

    return window;
}

pub fn main() !void {
    try glfw.init();
    defer glfw.terminate();

    const window = try newWindow("Zig GUI", 800, 600);

    imgui.init(std.heap.c_allocator);

    imgui.backend.init(window);
    defer imgui.deinit();
    defer imgui.backend.deinit();
    defer window.destroy();

    const gl = zopengl.bindings;

    var wants_open = true;

    while (!window.shouldClose() and window.getKey(.escape) != .press) {
        glfw.pollEvents();

        gl.clearBufferfv(gl.COLOR, 0, &[_]f32{ 0.2, 0.3, 0.3, 1.0 });

        const fb_size = window.getFramebufferSize();
        imgui.backend.newFrame(@intCast(fb_size[0]), @intCast(fb_size[1]));

        imgui.setNextWindowPos(.{ .x = 0, .y = 0 });
        imgui.setNextWindowSize(.{ .w = @floatFromInt(fb_size[0]), .h = @floatFromInt(fb_size[1]) });

        if (imgui.begin("Demo Window", .{ .flags = .{
            .no_move = true,
            .no_resize = true,
            .no_collapse = true,
            .no_title_bar = false,
            .menu_bar = true,
        }, .popen = &wants_open })) {
            if (imgui.beginMenuBar()) {
                if (imgui.beginMenu("File", true)) {
                    if (imgui.menuItem("Exit", .{}))
                        window.setShouldClose(true);

                    imgui.endMenu();
                }

                imgui.endMenuBar();
            }

            imgui.text("Hello, world!", .{});

            if (imgui.button("Button", .{}))
                std.debug.print("Button pressed!\n", .{});

            imgui.end();
        }

        imgui.backend.draw();
        window.swapBuffers();

        if (!wants_open)
            window.setShouldClose(true);
    }
}
