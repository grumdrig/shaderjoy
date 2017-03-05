precision highp float;
const int N = 128;
vec2 f(in vec2 z, in vec2 c) {
	return vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
}
float niter(in vec2 z, in vec2 c) {
	for (int i = 0; i < N; ++i) {
		z = f(z, c);
		if (length(z) > 2.0) {
			return float(i + 1) - log(log(length(z)) / log(2.0)) / log(2.0);
		}
	}
	return float(N);
}
vec3 red(float a) { return vec3(a, 0.0, 0.0); }
vec3 yellow(float a) { return vec3(1.0, a, 0.0); }
vec3 green(float a) { return vec3(1.0 - a, 1.0, 0.0); }
vec3 blue(float a) { return vec3(0.0, 1.0 - a, a); }
vec3 white(float a) { return vec3(a, a, 1.0); }
vec3 color(float a) {
	if (a <= 0.0) return vec3(0.0);
	if (a <= 0.03) return red(a / 0.03);
	if (a <= 0.1) return yellow((a - 0.03) / 0.07);
	if (a <= 0.2) return green((a - 0.1) / 0.1);
	if (a <= 0.4) return blue((a - 0.2) / 0.2);
	if (a <= 1.0) return white((a - 0.4) / 0.6);
	return vec3(1.0);
}

vec3 color2(float a) {
	if (a <= 0.0) return vec3(0.0);
	if (a <= 0.03) return white(a / 0.03);
	if (a <= 0.1) return blue((a - 0.03) / 0.07);
	if (a <= 0.2) return green((a - 0.1) / 0.1);
	if (a <= 0.4) return yellow((a - 0.2) / 0.2);
	if (a <= 1.0) return red((a - 0.4) / 0.6);
	return vec3(0.0);
}

vec2 rand(float p) {
    return fract(sin(vec2(p * 12.984 + 23.982,
                          p * 84.281 + 12.849)) * 43758.5453);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
    float scale = 0.07;
    scale += (iMouse.x / iResolution.x) * 0.1;
	vec2 c = rand(sin(iGlobalTime / 3000.)) * scale;
	vec2 uv = fragCoord.xy / iResolution.xy;
    uv = uv * 2. - 1.;
    uv.x *= iResolution.x / iResolution.y;
    uv *= 1.5;
    vec2 z = uv;
 	float a = niter(z, c) / float(N);

    vec2 c2 = rand(sin(iGlobalTime / 3100.)) * scale;
    float a2 = niter(z, c2) / float(N);

	fragColor = vec4(mix(color(a), color2(a2), 1.),1.0);
}

