#pragma once
#include "glew.h"

// lazy wrapper for unsafe GLuint type
enum GLResource : GLuint {
	GLRESOURCE_NULL = 0,
};

// 3D renderer wrapper for OpenGL (by default)
class Renderer {
public:
	Renderer(class Window& renderWindow);

public:
	void UseShaderProgram(const class ShaderProgram& program);

	GLResource LoadShaderFromSourceFile(const char* filename, GLenum glShaderType);
};

// Shader wrapper for OpenGL
class ShaderProgram {
public:
	ShaderProgram();

	// Loads and links a shader program with the given shaders
	ShaderProgram(const Renderer& renderer, GLResource vertexShader, GLResource fragmentShader);

public:
	// Attaches a shader to the program (either vertex or fragment)
	bool AttachShader(GLResource shader);

	// Links the program
	bool Link();

public:
	// Returns whether the shader is successfully linked and loaded
	bool IsLoaded() {
		return isLoaded;
	}

public:
	GLuint GetGlProgram() const {
		return glProgram;
	}

private:
	bool isLoaded;

	GLuint glProgram;
};