
vec3 rand(vec3 xyz) {
	return fract(vec3(sin(dot(xyz, vec3(43.238, 27.874, 57.982))),
					  sin(dot(xyz, vec3(91.922, 11.838, 77.133))),
					  sin(dot(xyz, vec3(43.238, 27.874, 57.982))))*
				 vec3(9283.9502,8329.9128,3201.1984));
}


vec3 curp(vec3 v0, float t, vec3 v1) {
	t = t * t * (3.0 - 2.0 * t);
	return mix(v0, v1, t);
}

vec3 lerp(vec3 v0, float t, vec3 v1) {
	return mix(v0, v1, t);
}

vec3 noise(vec3 xyz) {
	vec3 v0 = floor(xyz);
	vec3 f = xyz - v0;
	return
	  curp(curp(lerp(rand(v0),               f.z, rand(v0 + vec3(0,0,1))),
				f.y,
				lerp(rand(v0 + vec3(0,1,0)), f.z, rand(v0 + vec3(0,1,1)))),
		   f.x,
		   curp(lerp(rand(v0 + vec3(1,0,0)), f.z, rand(v0 + vec3(1,0,1))),
				f.y,
				lerp(rand(v0 + vec3(1,1,0)), f.z, rand(v0 + vec3(1,1,1)))));
}

vec3 simplex(vec3 xyz, int octaves) {
	float a = 1.0;
	vec3 result = vec3(0);
	for (int o = 1 << octaves; o > 0; o >>= 1, a /= 2.) {
		result += (2. * noise(xyz / float(o)) - 1.) * a;
	}
	return result;
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	vec2 uv = fragCoord/iResolution.x - vec2(0.5, 0.5 * iResolution.y / iResolution.x);
	vec3 per = simplex(vec3(uv * 120., iTime * 1.0), 5);
	per = normalize(per);
	float a = dot(per, normalize(vec3(uv, 0.1)));
	a = 1. * pow(a, 5.);
	a = 1. - a;
	fragColor.rgb = vec3(0.5 * per.r, 0.1, 1.0 * per.b) * a * 1.;
	fragColor.rgb = 0.1 + 0.8 * fragColor.rgb;
	fragColor.rgb = vec3(1.0) - fragColor.rgb;
	fragColor.rgb = 0.25 * fragColor.rgb + vec3(0.65);
	fragColor.a = 1.0;
}
