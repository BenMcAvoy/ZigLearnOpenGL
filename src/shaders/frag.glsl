#version 460

out vec4 FragColor;
in vec4 color_frag;

void main() {
	// FragColor = vec4(1.0, 0.0, 0.0, 1.0);
	FragColor = color_frag;
}
