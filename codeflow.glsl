// codeflow.org/webgl/irradiance


/*
    :copyright: 2011 by Florian Boesch <pyalot@gmail.com>.
    :license: GNU AGPL3, see LICENSE for more details.
*/


/*
float U_scatter_strength = 28.;
float U_mie_distribution = 63.;
float U_rayleigh = 33.;
float U_mie = 100.;
float U_spot = 1000.;
float U_rayleigh_strength = 139.;
float U_mie_strength = 264.;
float U_rayleigh_collected = 81.;
float U_mie_collected = 39.;
vec3 Kr = vec3(48,127,169)/255.;

*/

#define EARTH 1
#define MARS 1
#define VENUS 1
#define URANUS 1
#define ALIEN 1

#if EARTH
    // const float U_shading_mix = 5.;
    // const float U_specularity = 45.;
    // const float U_reflectivity = 20.;
    const vec3 Kr = vec3(48,127,169)/255.;
    const float U_scatter_strength = 28.;
    const float U_mie_distribution = 63.;
    const float U_rayleigh = 33.;
    const float U_mie = 100.;
    const float U_spot = 1000.;
    const float U_rayleigh_strength = 139.;
    const float U_mie_strength = 264.;
    const float U_rayleigh_collected = 81.;
    const float U_mie_collected = 39.;

#elif MARS
    // const float U_shading_mix = 63.;
    // const float U_specularity = 63.;
    // const float U_reflectivity = 25.;
    const vec3 Kr = vec3(169,130,50)/255.;
    const float U_scatter_strength = 54.;
    const float U_mie_distribution = 74.;
    const float U_rayleigh = 19.;
    const float U_mie = 44.;
    const float U_spot = 373.;
    const float U_rayleigh_strength = 359.;
    const float U_mie_strength = 308.;
    const float U_rayleigh_collected = 81.;
    const float U_mie_collected = 39.;

#elif VENUS
    // const float U_shading_mix = 63.;
    // const float U_specularity = 63.;
    // const float U_reflectivity = 25.;
    const vec3 Kr = vec3(170,146,75)/255.;
    const float U_scatter_strength = 140.;
    const float U_mie_distribution = 81.;
    const float U_rayleigh = 25.;
    const float U_mie = 124.;
    const float U_spot = 0.;
    const float U_rayleigh_strength = 397.;
    const float U_mie_strength = 298.;
    const float U_rayleigh_collected = 34.;
    const float U_mie_collected = 76.;

#elif URANUS
    // const float U_shading_mix = 63.;
    // const float U_specularity = 63.;
    // const float U_reflectivity = 25.;
    const vec3 Kr = vec3(69,134,227)/255.;
    const float U_scatter_strength = 18.;
    const float U_mie_distribution = 56.;
    const float U_rayleigh = 80.;
    const float U_mie = 67.;
    const float U_spot = 0.;
    const float U_rayleigh_strength = 136.;
    const float U_mie_strength = 68.;
    const float U_rayleigh_collected = 71.;
    const float U_mie_collected = 0.;

#elif ALIEN
    // const float U_shading_mix = 5.;
    // const float U_specularity = 45.;
    // const float U_reflectivity = 20.;
    const vec3 Kr = vec3(63,136,90)/255.;
    const float U_scatter_strength = 26.;
    const float U_mie_distribution = 86.;
    const float U_rayleigh = 44.;
    const float U_mie = 60.;
    const float U_spot = 0.;
    const float U_rayleigh_strength = 169.;
    const float U_mie_strength = 139.;
    const float U_rayleigh_collected = 71.;
    const float U_mie_collected = 46.;
#endif


float atmospheric_depth(vec3 position, vec3 dir){
    float a = dot(dir, dir);
    float b = 2.0*dot(dir, position);
    float c = dot(position, position)-1.0;
    float det = b*b-4.0*a*c;
    float detSqrt = sqrt(det);
    float q = (-b - detSqrt)/2.0;
    float t1 = c/q;
    return t1;
}

float phase(float alpha, float g){
    float a = 3.0*(1.0-g*g);
    float b = 2.0*(2.0+g*g);
    float c = 1.0+alpha*alpha;
    float d = pow(1.0+g*g-2.0*g*alpha, 1.5);
    return (a/b)*(c/d);
}

float horizon_extinction(vec3 position, vec3 dir, float radius){
    float u = dot(dir, -position);
    if(u<0.0){
        return 1.0;
    }
    vec3 near = position + u*dir;
    if(length(near) < radius){
        return 0.0;
    }
    else{
        vec3 v2 = normalize(near)*radius - position;
        float diff = acos(dot(normalize(v2), dir));
        return smoothstep(0.0, 1.0, pow(diff*2.0, 3.0));
    }
}

vec3 absorb(float dist, vec3 color, float factor){
    return color-color*pow(Kr, vec3(factor/dist));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float rayleigh_brightness = U_rayleigh / 10.;                  //  0-100
    float mie_brightness = U_mie / 1000.;                          //  0-168
    float spot_brightness = U_spot;                                //  0-1000
    float scatter_strength = U_scatter_strength / 1000.;           //  0-160
    float rayleigh_strength = U_rayleigh_strength / 1000.;         //  0-400
    float mie_strength = U_mie_strength / 10000.;                  //  0-400
    float rayleigh_collection_power = U_rayleigh_collected / 100.; //  0-200
    float mie_collection_power = U_mie_collected / 100.;           //  0-200
    float mie_distribution = U_mie_distribution / 100.;            //  0-100

    float surface_height = 0.99;
    float range = 0.01;
    float intensity = 1.8;
    const int step_count = 16;

    //vec3 lightdir = normalize(vec3(0.25 * cos(iGlobalTime) + .25, sin(iGlobalTime) + .5, 1.));
    const float PI = 3.1415926585;
    float t = (sin(iGlobalTime) + 1.) * PI / 4.;
    vec3 lightdir = vec3(0, sin(t), cos(t));
    vec2 coord = 2. * fragCoord.xy / iResolution.xy - 1.;  // on [-1, 1];
    float up = PI * coord.y / 2.;
    vec3 fisheye = vec3(cos(up) * sin(coord.x * PI), sin(up), cos(up) * cos(coord.x * PI));
    vec3 eyedir = normalize(coord.x < 0. ? vec3(coord, 1.) : fisheye);
    float alpha = dot(eyedir, lightdir);

    if (abs(fragCoord.y - iResolution.y / 2.) < 1.) {
        fragColor = vec4(1,0,0,1);
        return;
    }

    float rayleigh_factor = phase(alpha, -0.01) * rayleigh_brightness;
    float mie_factor = phase(alpha, mie_distribution) * mie_brightness;
    float spot = smoothstep(0.0, 15.0, phase(alpha, 0.9995)) * spot_brightness;

    vec3 eye_position = vec3(0.0, surface_height, 0.0);
    float eye_depth = atmospheric_depth(eye_position, eyedir);
    float step_length = eye_depth / float(step_count);
    float eye_extinction = horizon_extinction(eye_position, eyedir, surface_height - 0.15);

    vec3 rayleigh_collected = vec3(0);
    vec3 mie_collected = vec3(0);

    for(int i=0; i<step_count; i++){
        float sample_distance = step_length * float(i);
        vec3 position = eye_position + eyedir * sample_distance;
        float extinction = horizon_extinction(position, lightdir, surface_height - 0.35);
        float sample_depth = atmospheric_depth(position, lightdir);
        vec3 influx = absorb(sample_depth, vec3(intensity), scatter_strength) * extinction;
        rayleigh_collected += absorb(sample_distance, Kr * influx, rayleigh_strength);
        mie_collected += absorb(sample_distance, influx, mie_strength);
    }

    rayleigh_collected *= eye_extinction * pow(eye_depth, rayleigh_collection_power) / float(step_count);
    mie_collected *= eye_extinction * pow(eye_depth, mie_collection_power) / float(step_count);

    vec3 color = vec3(spot * mie_collected + mie_factor * mie_collected + rayleigh_factor * rayleigh_collected);
    color = pow(color, vec3(1.0/2.2));  // gamma correct

    fragColor = vec4(color, 1.0);
}
