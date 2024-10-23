const std = @import("std");

const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

pub fn newWindow(name: [:0]const u8, width: i32, height: i32) !*glfw.Window {
    const gl_major = 4;
    const gl_minor = 6;

    glfw.windowHintTyped(.context_version_major, gl_major);
    glfw.windowHintTyped(.context_version_minor, gl_minor);
    glfw.windowHintTyped(.opengl_profile, .opengl_core_profile);

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
