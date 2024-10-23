#version 460

layout(location = 0) in vec3 position;
// layout(location = 1) in vec3 color;

uniform mat4 view;
uniform mat4 model;
uniform mat4 projection;

out vec4 color_frag;

void main() {
	gl_Position = projection * view * model * vec4(position, 1.0);
	color_frag = vec4(0.9, 0.9, 0.9, 1.0);
}
