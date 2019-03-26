precision highp float;


vec2 rand(float p) {
    return fract(sin(vec2(p * 12.984 + 23.982,
                          p * 84.281 + 12.849)) * 43758.5453);
}

float positive(float v) {
	v *= 1000.0;
	return v > 1.0 ? 1.0 : v < 0.0 ? 0.0 : v;
}

float f(float v) {
    float scale = iGlobalTime;
    return positive(min(sin(v * scale), min(sin(v * scale * 8.0), sin(v * scale * 64.0))));
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2. - 1.;
    uv.x *= iResolution.x / iResolution.y;
    uv *= 1.5;
    float c = max(f(uv.x), f(uv.y));
    fragColor = vec4(c,c,c,1);
}

