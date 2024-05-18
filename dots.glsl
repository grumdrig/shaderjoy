const float R = 24.0;
const vec2 velocity = vec2(1.0, 1.11);

vec2 tau(ivec2 i, float t) {
	return fract(sin(vec2(2983.239849232, 9823.219834983) * vec2(i) + vec2(93498.32345, 9205.9054) * vec2(i).yx + vec2(272.123, 983.982)) * 9283.943498 * t) - 0.5;
}

vec2 tau2(ivec2 i) {
	// return tau(i, floor(iTime + 1.0));
	return mix(tau(i, floor(iTime)), tau(i, floor(iTime + 1.0)), fract(iTime));
}

vec2 nexus(ivec2 jdex) {
	return R * vec2(jdex) + R * tau2(jdex) * 0.3;
}

vec3 location(ivec2 index) {
	vec3 ns[3];
	vec2 nx = nexus(index);

	for (int j = -1; j <= 1; j += 1)
	for (int i = -1; i <= 1; i += 1)
	if (i != 0 || j != 0) {
		ivec2 jdex = index + ivec2(i, j);
		vec2 n = nexus(jdex);
		float d = distance(n, nx);
		if (j == -1) {
			ns[i+1] = vec3(n, d);
		} else {
			for (int k = 0; k < 3; k += 1) {
				if (d < ns[k].z) {
					ns[k] = vec3(n, d);
					break;
				}
			}
		}
	}
	return //mix(vec3(nx, 25.0),
			   vec3((ns[0].xy + ns[1].xy + ns[2].xy) / 3.0, min(ns[0].z, min(ns[1].z, ns[2].z)));
			 //  0.5 * sin(2.0 * iTime) + 0.5);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	float c = 0.0;
	vec2 origin = velocity * iTime;
	ivec2 index = ivec2(floor((fragCoord - origin) / R));
	float md = R * 999.0;
	for (int i = -1; i <= 1; i += 1)
	for (int j = -1; j <= 1; j += 1) {
		ivec2 jdex = index + ivec2(i, j);
		vec3 l = location(jdex);
		vec2 core = origin + l.xy;
		float d = length(fragCoord - core);
		float dc = d < l.z / 3.0 ? 1.0 : 0.0;
		c = max(c, dc);
	}
	fragColor = vec4(c, c, c, 1.0);
}
