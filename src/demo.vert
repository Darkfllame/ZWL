#version 460 core

layout(location = 0) in vec2 aPosition;
layout(location = 1) in vec3 aColor;

out vec3 color;

void main() {
    gl_Position = vec4(aPosition, 0, 1);
    color = aColor;
}
