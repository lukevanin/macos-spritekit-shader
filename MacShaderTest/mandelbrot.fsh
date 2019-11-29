/*
 sampler2D u_texture;
 Uniform
 A sampler associated with the texture used to render the node.
 
 float u_time;
 Uniform
 The elapsed time in the simulation.
 
 float u_path_length;
 Uniform
 Provided only when the shader is attached to an SKShapeNode object’s strokeShader property. This value represents the total length of the path, in points.
 
 vec2 v_tex_coord;
 Varying
 The coordinates used to access the texture. These coordinates are normalized so that the point (0.0,0.0) is in the bottom-left corner of the texture.
 
 vec4 v_color_mix;
 Varying
 The premultiplied color value for the node being rendered.
 
 float v_path_distance;
 Varying
 Provided only when the shader is attached to an SKShapeNode object’s strokeShader property. This value represents the distance along the path in points.
 
 vec4 SKDefaultShading()
 Function
 A function that provides the default behavior used by SpriteKit.
 */

vec4 hsv_to_rgb(float hue, float saturation, float value) {
    vec4 K = vec4(1.0, 0.66, 0.33, 3.0);
    vec4 p = abs(fract(vec4(hue) + K) * 6.0 - K.wwww);
    return vec4(value * mix(K.xxx, clamp(p.xyz - K.xxx, 0.0, 1.0), saturation), 1.0);
}

vec2 complex_multiply(vec2 lhs, vec2 rhs) {
    float a = lhs.x;
    float b = lhs.y;
    float c = rhs.x;
    float d = rhs.y;
    float r = (a * c) - (b * d);
    float i = (a * d) + (b * c);
    return vec2(r, i);
}

//vec2 pow_2_complex(vec2 c) {
//    return vec2(c.x * c.x - c.y * c.y, 2.0 * c.x * c.y);
//}

vec2 pow_complex(vec2 c, float e) {
    float t = atan(c.y, c.x) * e;
    float r = pow(length(c), e);
    float a = cos(t) * r;
    float b = sin(t) * r;
    return vec2(a, b);
}

vec4 i_to_rgb(float i, float t, float n) {
    float h = 0.5 + cos((t * 0.1) + (n * 2.0) + (i * 0.4)) * 0.5;
//    float b = (0.5 + (1.0 - n) * 0.5) - (cos(i * 4.0) * 0.1);
    float b = (1.0 - (n * 0.9)) * (0.8 + i * 0.5);
    float s = 0.25 - (n * 0.125);
    return hsv_to_rgb(h, s, b);
}

vec4 iterate(vec2 c, float e, float t) {
    int steps = 20;
    for (int j = 0; j < steps; j++) {
        vec2 z = vec2(0.0, 0.0);
        float p = float(j) / float(steps);
        int s = clamp(20 - (p * 30), 2, 20);
        for (int i = 0; i < s; i++) {
            float f = 0.5 + sin(e) * 0.5;
            z = pow_complex(z, 3.0 + (f * 4)) + c;
            if ((z.x * z.x + z.y * z.y) > 4.0) {
                float d = float(i) / float(s);
                return i_to_rgb(d, t, p);
            }
        }
        e = e * 1.06;
        c = c * 1.6;
    }
    return vec4(0, 0, 0, 1);
}

void main() {
    float t = u_time * 0.1;
    float st = 0.5 + cos(u_time * 0.1) * 0.5;
    vec2 s = 2.0 - (st * 1.5);

    vec2 tx = v_tex_coord;
    vec2 c = u_offset + ((tx - 0.5) * u_scale * s * 1.0);
    vec2 r = vec2(cos(t), sin(t));
    vec2 q = vec2(c.x * r.y + c.y * r.x, c.y * r.y - c.x * r.x);

    float i = 0.5 + cos(u_time * 0.125) * 0.5;
    float j = 4.0 + (i * 8);
    vec4 p = iterate(q, j, u_time);
    
    gl_FragColor = p;
}
