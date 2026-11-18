# ZigLearnOpenGL

ZigLearnOpenGL is a learning project for building a small OpenGL scene in Zig. It uses GLFW for the window, OpenGL shaders and buffers for drawing, a camera/object model, and Dear ImGui for an interface.

## Build and run

Clone the repository with its `zig-gamedev` submodule and install a compatible Zig toolchain:

```sh
git clone --recurse-submodules https://github.com/BenMcAvoy/ZigLearnOpenGL.git
cd ZigLearnOpenGL
zig build run
```

The project dependencies and build steps are described in `build.zig` and `build.zig.zon`.

## Status

This is an OpenGL learning exercise rather than a complete graphics framework.
