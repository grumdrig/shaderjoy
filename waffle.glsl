vec2 hash( vec2 p ) {
	p = vec2(dot(p,vec2(127.1,311.7)), dot(p,vec2(269.5,183.3)));
	return -1.0 + 2.0*fract(sin(p)*43758.5453123);
}

float noise( in vec2 p ) {
    const float K1 = 0.366025404; // (sqrt(3)-1)/2;
    const float K2 = 0.211324865; // (3-sqrt(3))/6;
	vec2 i = floor(p + (p.x+p.y)*K1);
    vec2 a = p - i + (i.x+i.y)*K2;
    vec2 o = (a.x>a.y) ? vec2(1.0,0.0) : vec2(0.0,1.0); //vec2 of = 0.5 + 0.5*vec2(sign(a.x-a.y), sign(a.y-a.x));
    vec2 b = a - o + K2;
	vec2 c = a - 1.0 + 2.0*K2;
    vec3 h = max(0.5-vec3(dot(a,a), dot(b,b), dot(c,c) ), 0.0 );
	vec3 n = h*h*h*h*vec3( dot(a,hash(i+0.0)), dot(b,hash(i+o)), dot(c,hash(i+1.0)));
    return dot(n, vec3(70.0));
}

const mat2 m = mat2( 1.6,  1.2, -1.2,  1.6 );

float fbm(vec2 n, int levels) {
	float total = 0.0, amplitude = 0.8;
	for (int i = 0; i < levels; i++) {
		total += noise(n) * amplitude;
		n = n * 2.0;// + vec2(23.1212717, 92.9327871);
		amplitude *= 0.5;
	}
	total = total * 0.5 + 0.5;
	return total;
}

vec3 hsv2rgb(vec3 c)
{
    vec3 rgb = clamp(abs(mod(c.x * 6.0 + vec3(0.0, 4.0, 2.0), 6.0) - 3.0) - 1.0,
                     0.0,
                     1.0);
    return c.z * mix(vec3(1.0), rgb, c.y);
}


// -----------------------------------------------

void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec3 d = vec3(fbm(fragCoord.xy * 0.02 + vec2(-23.23153, 56.91043), 3),
				  fbm(fragCoord.xy * 0.02 + vec2(39.392455, -6.29398), 3),
				  fbm(fragCoord.xy * 0.02 + vec2(92.291898, 12.09329), 3));

    vec2 p = fragCoord.xy / iResolution.xy;
	vec2 uv = p * vec2(iResolution.x/iResolution.y, 1.0);

	float N = 7.0;
	N = max(1.0, floor(20.0 * iMouse.y / iResolution.y));

	float size = min(0.1 * N, 0.8);

	float left = (iResolution.x/iResolution.y - size) / 2.0;
	float bottom = (1.0 - size) / 2.0;

	const float margin = 0.1;
	const float sidelight = 0.25;
	float dx = max(0.0, max(left - uv.x, sidelight * (uv.x - (left + size))));
	float dy = max(0.0, max(sidelight * (bottom - uv.y), uv.y - (bottom + size)));
	if (dx > 0.0 || dy > 0.0) {
		float marginal = sqrt(dx*dx + dy*dy);
		vec3 hsv = vec3(0.4, 0.6, 0.6 - 0.3 * smoothstep(0.01, 0.0, marginal));
		hsv = hsv - 0.02 * (d - vec3(0.5));
		fragColor = vec4(hsv2rgb(hsv), 1.0);
		return;
	}

	uv = (uv - vec2(left, bottom)) / size;
	const float edge = 0.25;
	vec2 index = uv * vec2(N + edge * 2.0) - vec2(edge);
	vec2 part = fract(index);

	float h = 0.07 + 0.02 * d.x;
	float s = 0.60 + 0.15 * d.y;
	// float v = 0.30 + 0.45 * fbm(fragCoord.xy * 0.02 + vec2(92.291898, 12.09329), 3);
	// float v = 0.30 + min(part.x, part.y) * fbm(fragCoord.xy * 0.02 + vec2(92.291898, 12.09329), 3);
	vec2 w = cos(index * 2.0 * 3.14159265) * 0.5 + 0.5;
	const float P = 3.0;
	w = vec2(pow(w.x, P), pow(w.y, P));
	float ww;
	if (index.x < 0.0 || index.x > N) {
		if (index.y < 0.0 || index.y > N)
			ww = min(w.x, w.y);
		else
			ww = w.x;
	} else if (index.y < 0.0 || index.y > N)
		ww = w.y;
	else
		ww = max(w.x, w.y);

	float v = 0.1 + 0.5 * ww + 0.4 * d.z;

	// float v = fbm(fragCoord.xy * 0.1) * 0.5 + 0.5;
	// v = v * 6.0;
	fragColor = vec4(hsv2rgb(vec3(h,s,v)), 1.0);
}