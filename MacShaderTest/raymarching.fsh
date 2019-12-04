
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

struct Ray {
    vec3 origin;
    vec3 direction;
    vec3 seed;
};

struct Hit {
    bool is_hit;
    vec3 position;
    vec3 scatter;
    vec3 color;
    vec3 seed;
};

struct Result {
    float depth;
    int material;
};

vec3 op_repeat(vec3 p, vec3 c) {
    vec3 q = mod(p+0.5*c,c)-0.5*c;
    return q;
}

vec3 op_transform_x(vec3 p, float t) {
    float f = t;
    float c = cos(f);
    float s = sin(f);
    mat3 m = mat3(
        1, 0, 0,
        0, c, -s,
        0, s, c
    );
    return p * m;
}

vec3 op_transform_y(vec3 p, float t) {
    float f = t;
    float c = cos(f);
    float s = sin(f);
    mat3 m = mat3(
                  c, 0, -s,
                  0, 1, 0,
                  s, 0, c
                  );
    return p * m;
}

vec3 op_transform_z(vec3 p, float t) {
    float f = t;
    float c = cos(f);
    float s = sin(f);
    mat3 m = mat3(
                  c, -s, 0,
                  s, c, 0,
                  0, 0, 1
                  );
    return p * m;
}

float sd_plane( vec3 p, vec4 n ) {
    return dot(p,n.xyz) + n.w;
}

float sd_sphere(vec3 origin, float radius) {
    return length(origin) - radius;
}

float sd_box(vec3 p, vec3 b) {
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}

float sd_round_box( vec3 p, vec3 b, float r ) {
    vec3 q = abs(p) - b;
    return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0) - r;
}

float sd_torus( vec3 p, vec2 t ) {
    vec2 q = vec2(length(p.xz)-t.x,p.y);
    return length(q)-t.y;
}

Result min_result(Result input, int material, float depth) {
    if (depth < input.depth) {
        Result output = Result();
        output.depth = depth;
        output.material = material;
        return output;
    }
    else {
        return input;
    }
}

Result sd_world(vec3 p, float t) {
    
//    vec3 box_offset = vec3(sin(t * 0.9) * 1.0, 1.0 + cos(t * 0.4) * 1.0, 1.0 + cos(t * 0.9) * 1.0);
//    float box_radius = 0.2; // 0.2 + (cos(t * 0.1) * 0.1);
//    vec3 box_size = vec3(0.5, 0.5, 0.5) - box_radius;

    vec3 sphere_offset = vec3(sin(t * 0.7) * 1.5, 0.5 + cos(t * 0.9) * 0.5, -2 + cos(t * 0.7) * 1.5);
//    vec2 torus_radius = vec2(0.5, 0.25);

//    vec3 sphere_offset = vec3(sin(t * 0.9) * 1.5, 1.0 + cos(t * 0.2) * 1.0, cos(t * 0.9) * 1.5);
//    vec3 torus_offset = vec3(0, 0.5 + sin(t * 0.8) * 0.8, -2);
//    vec3 sphere_offset = vec3(0, 0, -2);
    float sphere_radius = 1.5;

    Result d = Result();
    d.depth = 100000;
    d.material = 0;
    
//    d = min_result(d, 1, 5.0);
    //    d = min_result(d, 1, p.y + 1.0);
    
    d = min_result(d, 2, p.y + 2.0 + ((sin(p.x - t * 0.1) - cos(p.z + t * 0.5)) * 0.5));
//    d = min(d, sd_box(p - box_offset, box_size));
//    d = min(d, sd_round_box(p - box_offset, box_size, box_radius));
//    d = min_result(d, 1, sd_torus(p - torus_offset, torus_radius));
    
    vec3 r = vec3(4.0, 100.0, 4.0);
    vec3 q = op_repeat(op_transform_z(op_transform_x(op_transform_y(p + sphere_offset, t * 0.1), t * 0.2), t * 0.15), r);
    d = min_result(d, 3, sd_sphere(q, sphere_radius));
    
//    d = min_result(d, 2, sd_sphere(p + vec3(0, -2.5, -2), 3));

    //        sd_plane(p + vec3(0, 1, 0), normalize(vec4(0.0, 1, 0.0, 0.0)))
    return d;
}

vec3 sd_normal(vec3 p, float t) {
//    vec3 e = vec3(0.00001, 0.0, 0.0);
//    vec3 e = vec3(1.0, -1.0, 0) * 0.5773 * 0.0005;
//    vec3 n = vec3(
//        sd_world(p + e.xyy, t).depth - sd_world(p - e.xyy, t).depth,
//        sd_world(p + e.yxy, t).depth - sd_world(p - e.yxy, t).depth,
//        sd_world(p + e.yyx, t).depth - sd_world(p - e.yyx, t).depth
//    );
//    return normalize(n);
    vec3 n = vec3(0.0);
    for( int i=0; i<4; i++ )
    {
        vec3 e = 0.5773*(2.0*vec3((((i+3)>>1)&1),((i>>1)&1),(i&1))-1.0);
        n += e * sd_world(p + 0.0005 * e, t).depth;
    }
    return normalize(n);
}

vec3 sky(Ray ray, float time) {
//    vec3 bottom_color = vec3(1.0, 1.0, 1.0);
//    vec3 top_color = vec3(0.5, 0.7, 1.0);
//    float d = 0.5 + cos(time * 0.1) * 0.5;
    float d = 1.0;
    vec3 top_color = mix(vec3(1.0, 1.0, 1.0), vec3(0.01, 0.01, 0.03), d);
    vec3 bottom_color = mix(vec3(0.5, 0.7, 1.0), vec3(0.3, 0.3, 0.5), d);
    
    vec3 unit_direction = normalize(ray.direction);
    float t = 0.5 + (unit_direction.y * 0.5);
    return (1.0 - t) * bottom_color + t * top_color;
}

// https://thebookofshaders.com/10/
float random21(vec2 st) {
    return (fract(sin(dot(st, vec2(12.9898, 78.233))) * 43758.5453123) * 2.0) - 1.0;
}

vec3 random33(vec3 seed) {
    float a = random21(seed.xy);
    float b = random21(seed.yz);
    float c = random21(seed.zx);
    vec3 v = vec3(a, b, c);
    return normalize(v);
}

float schlick(float cosine, float index) {
    float r0 = (1.0 - index) / (1.0 + index);
    r0 = r0 * r0;
    return r0 + (1 - r0) * pow(1.0 - cosine, 5);
}

Hit cast(Ray ray, float t) {
    int steps = 48;
    float depth_min = .01;
    float depth_max = 20.0;

    float depth_total = 0.0;
    for (int i = 0; i < steps; i++) {
        vec3 p = ray.origin + ray.direction * depth_total;
        Result result = sd_world(p, t);
        if (result.depth <= depth_min) {
            vec3 normal = sd_normal(p, t);
            float refraction_index = 1.0 / 1.5;
            vec3 random = random33(p * ray.seed * (2 + sin(t)));
//            vec3 random = random33(p * ray.seed);
            vec3 reflection = reflect(ray.direction, normal);
            vec3 refraction = refract(ray.direction, normal, refraction_index);
            vec3 diffuse = normalize(normal + random);
            float cosine = -dot(ray.direction, normal) / length(ray.direction);
            float probability = schlick(cosine, refraction_index);
            float blend = 0;
            vec3 scatter;
            vec3 color;
            Hit hit = Hit();
            hit.is_hit = true;
            
            if (result.material == 1) {
                scatter = normalize(normal + random);
                color = vec3(0.5, 0.5, 0.6);
            }
            else if (result.material == 2) {
                scatter = normalize(reflection + ((normal + diffuse) * 0.02));
//                scatter = reflection;
//                color = vec3(0.4, 0.3, 0.9);
                float m = 0.5 + sin(t * 0.12) * 0.5;
                float n = 0.5 + cos(t * 0.2) * 0.5;
//                vec3(0.9, 0.8, 0.3)
                color = mix(mix(vec3(0.9, 0.8, 0.3), vec3(0.1, 0.1, 0.2), m), vec3(0.85, 0.85, 0.8), n);
            }
//            else if (result.material == 2) {
//                scatter = reflection;
//                color = vec3(0.9, 0.8, 0.3);
//            }
            else {
                if (random.x > probability) {
                    scatter = reflection;
                }
                else {
                    scatter = refraction;
                }
                scatter = scatter + (diffuse * 0.01);
                color = vec3(1.0);
            }
//            hit.position = p + (refraction * 2); // - (normal * depth_min * 2);
//            hit.scatter = refraction; // normalize((1.0 - blend) * reflection + (blend * diffuse));
            
            hit.position = p + (scatter * 10);
            hit.scatter = scatter;
            hit.seed = random;
            hit.color = color;
//            hit.color = vec3(probability); // vec3(1.0, 1.0, 1.0);
            return hit;
        }
        depth_total += result.depth;
        if (depth_total > depth_max) {
            break;
        }
    }
    
    Hit hit = Hit();
    hit.is_hit = false;
    hit.color = sky(ray, t);
    return hit;
}

vec3 gamma(vec3 color) {
    color = color / 1.0;
    return vec3(sqrt(color.r), sqrt(color.g), sqrt(color.b));
}

vec3 raymarch(Ray ray, float t) {
    Hit hit;
    vec3 color = vec3(1.0);
    int bounces = 4;
    int i = 0;
    float f = 1.0;
    do {
        hit = cast(ray, t);
//        color = clamp(color * hit.color * f, 0, 1);
        color = color * hit.color * f;
        ray.origin = hit.position;
        ray.direction = hit.scatter;
        ray.seed = hit.seed;
        f = f * 0.99;
    } while (hit.is_hit && i++ < bounces);
//    return gamma(color * pow(0.5, i + 1));
    return gamma(color);
}

void main() {
    
    vec2 uv = (v_tex_coord - 0.5) * 2.0 * u_scale;
    vec3 origin = vec3(0.0, 0.0, -5.0);
    vec3 target = vec3(uv, 1.0);
    Ray ray = Ray();
    ray.origin = origin;
    ray.direction = normalize(target);
    ray.seed = random33(vec3(1, -1, 0));
    
    float t = u_time;
//    float t = 1.0;

    int rays = 7;
    vec3 color = vec3(0);
    for (int i = 0; i < rays; i++) {
        ray.origin = origin + (random33(ray.origin + i + t * 10) * 0.005);
        float f = float(i) / float(rays);
        color = color + raymarch(ray, t - 0.16 + (f * 0.032));
    }
    color = color / rays;
    
    gl_FragColor = vec4(color, 1.0);
}
