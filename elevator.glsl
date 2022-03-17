float noneg(float x) { return x < 0.0 ? 9999999.9 : x; }

mat2 rot2(float a){
    float c = cos(a);
    float s = sin(a);
	return mat2(c, s, -s, c);
}

void mainImage( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 p = (2.0*fragCoord-iResolution.xy) / iResolution.y;

	vec3 ro = vec3(0, 1.6, 0);
	vec3 rd = vec3(p, 1.0);
	rd = normalize(rd);

	rd.yz = rot2(0.2235 * cos(iTime * 0.5)) * rd.yz;
	rd.xz = rot2(1.5 + 0.35 * cos(iTime * 0.8122)) * rd.xz;


	const float Y0 = 0.0;
	const float Y1 = 4.0;
	const float Z0 = -2.0, Z1 = 2.0;
	const float X0 = -2.0, X1 = 2.0;
	float tz1 = noneg((Z1 - ro.z) / rd.z);
	float tz0 = noneg((Z0 - ro.z) / rd.z);
	float ty1 = noneg((Y1 - ro.y) / rd.y);
	float ty0 = noneg((Y0 - ro.y) / rd.y);
	float tx1 = noneg((X1 - ro.x) / rd.x);
	float tx0 = noneg((X0 - ro.x) / rd.x);
	float t = min(min(min(tx0, tx1), min(ty0, ty1)), min(tz0, tz1));

	vec3 q = ro + t * rd;

	fragColor = vec4(0,0,0,1);
	if (t == tx0) {
		fragColor.r = 1.0;

		if (q.y > 2.0) {
			const float G = 0.1;
			const float GT = 0.01;

			const float W = 1.0;
			const float WT = 0.04;
			if (q.z < Z0 + WT
				|| q.z > Z1 - WT
				|| q.y < 2.0 + WT
				|| q.y > Y1 - WT
				|| abs(mod(q.z + W - WT/2.0, W) - W) < WT
			) {
				fragColor.xyz = vec3(0.8);
			} else if (
				mod(q.z, G) < GT
				|| mod(q.y, G) < GT
			) {
				fragColor.xyz = vec3(0.9);
			}
		}

	} else if (t == tx1) {
		fragColor.r = 0.5;
	} else if (t == ty0) {
		fragColor.g = 1.0;
	} else if (t == ty1) {
		fragColor.g = 0.5;
	} else if (t == tz0) {
		fragColor.b = 1.0;
	} else if (t == tz1) {
		fragColor.b = 0.5;

		if (q.y < 2.0) {
			// grating
			const float G = 0.15;
			const float T = 0.05;
			float fence = max(mod(q.x + q.y, G), mod(q.y - q.x, G)) / G;
			if (fence > (1.0 - T)) fragColor.xyz = vec3(0.8);

			const float W = 1.0;
			const float WT = 0.04;
			if (q.y < WT * 2.0 ||
				q.y > 2.0 - WT * 2.0 ||
				q.x < X0 + WT * 2.0 ||
				q.x > X1 - WT * 2.0 ||
				abs(mod(q.x + W - WT/2.0, W) - W) < WT) {
				fragColor.xyz = vec3(0.8);
			}
		}
		// fragColor.b = smoothstep(0.0, 1.0, fragColor.b);
		// if (fragColor.b < 0.9) fragColor.b = 0.0;
	}
}
