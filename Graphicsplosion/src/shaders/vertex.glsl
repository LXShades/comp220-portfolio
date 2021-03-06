#version 330 core

layout(location = 0) in vec3 vertexPos;
layout(location = 1) in vec3 vertexColour;
layout(location = 2) in vec3 vertexNormal;
layout(location = 3) in vec2 vertexUv;
layout(location = 4) in uvec4 boneIndices;
layout(location = 5) in vec4 boneWeights;

out vec3 fragShadowPosition;
out vec3 fragColour;
out vec2 fragUv;
out vec3 fragNormal;
out vec3 viewDirection;

uniform mat4 matWorld; // the global transformation matrix
uniform mat4 matViewProj;  // the global view matrix
uniform mat4 matShadowView;  // the shadow view matrix
uniform vec3 cameraPosition;

uniform mat4 boneTransforms[32]; // bone matrices

uniform float time; // global time

uniform vec3 ambientLightColour;
uniform vec3 directionalLightDirection;
uniform vec3 directionalLightColour;

void main()
{
	// Calculate the position of the vertex based on bones
	// If there is at least one bone attached, weight this to the bone
	int numBones = 0;
	vec4 originalNormal = vec4(vertexNormal, 0.0f);
	vec3 animatedPosition = vec3(0.0f, 0.0f, 0.0f);
	vec4 animatedNormal = vec4(0.0f, 0.0f, 0.0f, 0.0f);
	vec4 worldVertexPosition = vec4(vertexPos, 1.0f);

	if (boneIndices.x < 32u) {
		animatedPosition += (boneTransforms[boneIndices.x] * vec4(vertexPos, 1.0f)).xyz * boneWeights.x;
		animatedNormal += boneTransforms[boneIndices.x] * originalNormal;

		if (boneIndices.y < 32u) {
			animatedPosition += (boneTransforms[boneIndices.y] * vec4(vertexPos, 1.0f)).xyz * boneWeights.y;
			animatedNormal += boneTransforms[boneIndices.y] * originalNormal;
			
			if (boneIndices.z < 32u) {
				animatedPosition += (boneTransforms[boneIndices.z] * vec4(vertexPos, 1.0f)).xyz * boneWeights.z;
				animatedNormal += boneTransforms[boneIndices.z] * originalNormal;
				
				if (boneIndices.w < 32u) {
					animatedPosition += (boneTransforms[boneIndices.w] * vec4(vertexPos, 1.0f)).xyz * boneWeights.w;
					animatedNormal += boneTransforms[boneIndices.w] * originalNormal;
				}
			}
		}

		worldVertexPosition = matWorld * vec4(animatedPosition, 1.0f);
		animatedNormal = matWorld * normalize(animatedNormal);
	} else {
		// Otherwise use the regular position
		worldVertexPosition = matWorld * vec4(vertexPos, 1);
		animatedNormal = matWorld * originalNormal;
	}

	// Use directional light + ambient light
	float lightFactor = clamp(1.0f - dot(animatedNormal.xyz, directionalLightDirection), 0.0f, 1.0f);
	fragColour = vertexColour * clamp(ambientLightColour + (directionalLightColour * lightFactor), 0.0f, 1.0f);

	// Standard UVs
	fragUv = vertexUv;

	// Send normal to frag shader
	fragNormal = vec3(matWorld * animatedNormal);

	// Send view direction to frag shader
	viewDirection = normalize(cameraPosition - worldVertexPosition.xyz);

	// Send shadow map position
	vec4 fragShadowPosition4D = matShadowView * worldVertexPosition;
	fragShadowPosition = fragShadowPosition4D.xyz / fragShadowPosition4D.w;

	// Send the vertex position
	gl_Position = matViewProj * worldVertexPosition;
}