#version 460

layout(location = 0) in vec3 position;
// layout(location = 1) in vec3 color;

uniform mat4 model_matrix;

out vec4 color_frag;

void main() {
	gl_Position = vec4(position, 1.0) * model_matrix;
	color_frag = vec4(0.9, 0.9, 0.9, 1.0);
}
