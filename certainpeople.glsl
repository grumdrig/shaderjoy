// Lives in public at:
// https://www.shadertoy.com/view/tdjSDh

vec2 rotate(vec2 v, float a){
    return mat2(cos(a),-sin(a),
                sin(a),cos(a)) * v;
}

bool test(float v) {
    int n = int(floor(v));
    return ((1 & n & n >> 3 & n >> 6 & n >> 9) == 1);
}

float f(vec2 v) {
    float t = iGlobalTime / 4.0;
    float p = fract(t);
    float scale = 10.0 * pow(8.0, p);
    ivec2 n = ivec2(floor(v * scale));
    vec2 q = vec2(p,p);
    return max(test(v.x * scale) || test(v.x * scale + q.x) || test(v.x * scale - q.x) ? 1.0 : 0.0,
               test(v.y * scale) || test(v.y * scale + q.y) || test(v.y * scale - q.y) ? 1.0 : 0.0);
}

float C(vec2 fragCoord) {
    vec2 uv = 4. * (2. * fragCoord.xy / iResolution.x - 1.);

    float tr = iGlobalTime / 200.0;
	float r = 3.14159265 * sin(21.0 * tr) * sin(5.0 * tr);
	uv =rotate(uv, r);

    uv += vec2(-2.0, -2.0);

    float t = iGlobalTime / 20.0;
    float x0 = sin(33.0 * t) * cos(9.0 * t);
    float y0 = sin(40.0 * t) * sin(7.0 * t);
    t /= 10.0;
    x0 += 2.0 * sin(33.0 * t) * cos(9.0 * t);
    y0 += 2.0 * sin(40.0 * t) * sin(7.0 * t);

    return f(uv + vec2(x0, y0));
}

void mainImage(out vec4 fragColor, in vec2 fragCoord)
{
    float c = (C(fragCoord                 ) +
               C(fragCoord + vec2(0.0, 0.5)) +
               C(fragCoord + vec2(0.5, 0.0)) +
               C(fragCoord + vec2(0.5, 0.5))) / 4.;
    fragColor = vec4(c,c,c,1);
}

