#version 460

out vec4 FragColor;
uniform vec4 colour;

void main() {
	if (colour.a < 0.02)
		discard;

	FragColor = colour;
}
