precision highp float;


vec2 rand(float p) {
    return fract(sin(vec2(p * 12.984 + 23.982,
                          p * 84.281 + 12.849)) * 43758.5453);
}

float positive(float v) {
	v *= 1000.0;
	return v > 1.0 ? 1.0 : v < 0.0 ? 0.0 : v;
}

bool test(float v) {
    int n = int(floor(v));
    return ((1 & n & n >> 3 & n >> 6 & n >> 9) == 1);
}

float f(float v) {
    float t = iGlobalTime / 4.0;
    float p = fract(t);
    float scale = 10.0 * pow(8.0, p);
    int n = int(floor(v * scale));
    // p = sqrt(p);
    return test(v * scale) || test(v * scale + p) || test(v * scale - p) ? 1.0 : 0.0;
    // return positive(min(sin(v * scale), min(sin(v * scale * 8.0), sin(v * scale * 8.0))));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2. - 1.;
    uv.x *= iResolution.x / iResolution.y;
    uv *= 1.5;
    uv += vec2(-2.0, -2.0);
    float t = iGlobalTime / 20.0;
    float x0 = sin(33.0 * t) * cos(9.0 * t);
    float y0 = sin(40.0 * t) * sin(7.0 * t);
    t /= 10.0;
    x0 += 2.0 * sin(33.0 * t) * cos(9.0 * t);
    y0 += 2.0 * sin(40.0 * t) * sin(7.0 * t);
    float c = max(f(uv.x + x0), f(uv.y + y0));
    fragColor = vec4(c,c,c,1);
}

