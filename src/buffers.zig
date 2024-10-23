const std = @import("std");

const glfw = @import("zglfw");
const zopengl = @import("zopengl");
const gl = zopengl.bindings;

pub const Buffers = struct {
    vbo: c_uint,
    vao: c_uint,
    ebo: c_uint,

    pub fn init(vertices: []const f32, indices: []const u32) !Buffers {
        if (vertices.len == 0) {
            return error.EmptyVertexData;
        }

        if (indices.len == 0) {
            return error.EmptyIndexData;
        }

        var vbo: c_uint = undefined;
        var vao: c_uint = undefined;
        var ebo: c_uint = undefined;

        gl.genBuffers(1, &ebo);
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, ebo);
        gl.bufferData(gl.ELEMENT_ARRAY_BUFFER, @intCast(@sizeOf(u32) * indices.len), indices.ptr, gl.STATIC_DRAW);

        gl.genBuffers(1, &vbo);
        gl.bindBuffer(gl.ARRAY_BUFFER, vbo);
        gl.bufferData(gl.ARRAY_BUFFER, @intCast(@sizeOf(f32) * vertices.len), vertices.ptr, gl.STATIC_DRAW);

        gl.genVertexArrays(1, &vao);
        gl.bindVertexArray(vao);

        gl.vertexAttribPointer(0, 3, gl.FLOAT, gl.FALSE, 3 * @sizeOf(f32), @ptrFromInt(0));
        gl.enableVertexAttribArray(0);

        return Buffers{ .vbo = vbo, .vao = vao, .ebo = ebo };
    }

    pub fn deinit(self: Buffers) void {
        gl.deleteBuffers(1, &self.ebo);
        gl.deleteBuffers(1, &self.vbo);
        gl.deleteVertexArrays(1, &self.vao);
    }

    pub fn use(self: Buffers) void {
        gl.bindBuffer(gl.ELEMENT_ARRAY_BUFFER, self.ebo);
        gl.bindVertexArray(self.vao);
    }
};
