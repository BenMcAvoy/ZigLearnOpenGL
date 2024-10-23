const std = @import("std");

const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const zmath = @import("zmath");

const gl = zopengl.bindings;

const escape_sequence_red = "\x1b[31m";
const escape_sequence_reset = "\x1b[0m";

pub const ShaderProgram = struct {
    program: c_uint,

    pub fn init(vertex_shader: []const u8, fragment_shader: []const u8) !ShaderProgram {
        // Used for error checking
        var success: c_int = gl.TRUE;
        var info_log: [512]u8 = undefined;
        var info_log_length: c_int = undefined;

        const vs = gl.createShader(gl.VERTEX_SHADER);
        gl.shaderSource(vs, 1, &vertex_shader.ptr, &info_log_length);
        gl.compileShader(vs);
        gl.getShaderiv(vs, gl.COMPILE_STATUS, &success);
        if (success == gl.FALSE) {
            gl.getShaderInfoLog(vs, info_log.len, &info_log_length, &info_log);
            const log = info_log[0..@intCast(info_log_length) :0];
            std.debug.print("{s}SHADER::VERTEX::COMPILATION::FAILED:{s} {s}\n", .{
                escape_sequence_red,
                log,
                escape_sequence_reset,
            });
            return error.ShaderCompilationError;
        }

        const fs = gl.createShader(gl.FRAGMENT_SHADER);
        gl.shaderSource(fs, 1, &fragment_shader.ptr, &info_log_length);
        gl.compileShader(fs);
        gl.getShaderiv(fs, gl.COMPILE_STATUS, &success);
        if (success == gl.FALSE) {
            gl.getShaderInfoLog(fs, info_log.len, &info_log_length, &info_log);
            const log = info_log[0..@intCast(info_log_length) :0];
            std.debug.print("{s}SHADER::FRAGMENT::COMPILATION::FAILED:{s} {s}\n", .{
                escape_sequence_red,
                log,
                escape_sequence_reset,
            });
            return error.ShaderCompilationError;
        }

        const program: c_uint = gl.createProgram();

        gl.attachShader(program, vs);
        gl.attachShader(program, fs);

        gl.linkProgram(program);

        gl.getProgramiv(program, gl.LINK_STATUS, &success);
        if (success == gl.FALSE) {
            gl.getProgramInfoLog(program, info_log.len, &info_log_length, &info_log);
            const log = info_log[0..@intCast(info_log_length) :0];
            std.debug.print("{s}SHADER::PROGRAM::LINKING::FAILED:{s} {s}\n", .{
                escape_sequence_red,
                log,
                escape_sequence_reset,
            });
            return error.ShaderLinkingError;
        }

        gl.deleteShader(vs);
        gl.deleteShader(fs);

        return ShaderProgram{ .program = program };
    }

    pub fn use(self: ShaderProgram) void {
        gl.useProgram(self.program);
    }

    pub fn set_i32(self: ShaderProgram, name: []const u8, value: i32) void {
        const location = gl.getUniformLocation(self.program, name.ptr);
        gl.uniform1i(location, value);
    }

    pub fn set_f32(self: ShaderProgram, name: []const u8, value: f32) void {
        const location = gl.getUniformLocation(self.program, name.ptr);
        gl.uniform1f(location, value);
    }

    pub fn set_mat4(self: ShaderProgram, name: []const u8, value: zmath.Mat) void {
        const location = gl.getUniformLocation(self.program, name.ptr);
        gl.uniformMatrix4fv(location, 1, gl.FALSE, &zmath.matToArr(value));
    }

    pub fn set_vec4(self: ShaderProgram, name: []const u8, value: zmath.Vec) void {
        const location = gl.getUniformLocation(self.program, name.ptr);
        gl.uniform4fv(location, 1, &zmath.vecToArr4(value));
    }
};
