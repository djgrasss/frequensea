-- Visualize IQ data as a texture from a file.
-- Don't connect a device.
-- Steps are deliberate.

VERTEX_SHADER = [[
#version 400
layout (location = 0) in vec3 vp;
layout (location = 1) in vec3 vn;
layout (location = 2) in vec2 vt;
out vec3 color;
out vec2 texCoord;
uniform mat4 uViewMatrix, uProjectionMatrix;
uniform float uTime;
void main() {
    color = vec3(1.0, 1.0, 1.0);
    texCoord = vt;
    gl_Position = vec4(vp.x*2, vp.z*2, 0, 1.0);
}
]]

FRAGMENT_SHADER = [[
#version 400
in vec3 color;
in vec2 texCoord;
uniform sampler2D uTexture;
layout (location = 0) out vec4 fragColor;
void main() {
    float r = texture(uTexture, texCoord).r * 0.05;
    fragColor = vec4(r, r, r, 0.95);
}
]]

function setup()
    freq = 612.004
    device = nrf_device_new(freq, "../rfdata/rf-612.004-big.raw")
    nrf_device_set_paused(device, true)
    camera = ngl_camera_new_look_at(0, 0, 0) -- Camera is unnecessary but ngl_draw_model requires it
    shader = ngl_shader_new(GL_TRIANGLES, VERTEX_SHADER, FRAGMENT_SHADER)
    texture = ngl_texture_new(shader, "uTexture")
    model = ngl_model_new_grid_triangles(2, 2, 1, 1)
end

function draw()
    ngl_clear(0.2, 0.2, 0.2, 1.0)
    buffer = nrf_device_get_iq_buffer(device);
    ngl_texture_update(texture, buffer.width, buffer.height, buffer.channels, buffer.data);
    ngl_draw_model(camera, model, shader)
end

function on_key(key, mods)
    keys_frequency_handler(key, mods)
    if (key == KEY_SPACE) then
        nrf_device_step(device)
    end
end
