#version 330 core

out vec3 color;
in vec2 uv;

uniform sampler2D colorSampler;

uniform float time;

void main() {
	vec2 uvNormalised = (uv * 2.0f) - vec2(1.0f, 1.0f);
	float rotation = time * length(uvNormalised) * 0.0f;
	rotation = (0.1f * length(uvNormalised)) * 6.28;

	uvNormalised = vec2(uvNormalised.x * cos(rotation) - uvNormalised.y * sin(rotation), uvNormalised.x * sin(rotation) + uvNormalised.y * cos(rotation));

	color = texture(colorSampler, /*(uvNormalised + vec2(1.0f, 1.0f)) / 2.0f*/ uv).xyz;
	//color = texture(shadowSampler, uv).xxx;
}