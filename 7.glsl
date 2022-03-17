float minimum_distance(vec2 v, vec2 w, vec2 p) {
  // Return minimum distance between line segment vw and point p
  float l2 = dot(v-w, v-w);
  if (l2 == 0.0) return distance(p, v);   // v == w case
  // Consider the line extending the segment, parameterized as v + t (w - v).
  // We find projection of point p onto the line.
  // It falls where t = [(p-v) . (w-v)] / |w-v|^2
  // We clamp t from [0,1] to handle points outside the segment vw.
  float t = max(0.0, min(1.0, dot(p - v, w - v) / l2));
  vec2 projection = v + t * (w - v);  // Projection falls on the segment
  return distance(p, projection);
}


// https://www.shadertoy.com/view/MtS3Dy
float det(vec2 a, vec2 b) { return a.x*b.y-b.x*a.y; }

vec2 get_distance_vector(vec2 b0, vec2 b1, vec2 b2) {
  float a = det(b0, b2), b = 2.0 * det(b1, b0), d = 2.0 * det(b2, b1);
  float f = b * d - a * a;
  vec2 d21 = b2 - b1, d10 = b1 - b0, d20 = b2 - b0;
  vec2 gf = 2.0 * (b * d21 + d * d10 + a * d20);
  gf = vec2(gf.y, -gf.x);
  vec2 pp = -f * gf / dot(gf, gf);
  vec2 d0p = b0 - pp;
  float ap = det(d0p, d20), bp = 2.0 * det(d10, d0p);
  float t = clamp((ap + bp) / (2.0 * a + b + d), 0.0, 1.0);
  return mix(mix(b0, b1, t), mix(b1, b2, t), t);
}

float approx_distance(vec2 p, vec2 b0, vec2 b1, vec2 b2) {
  return length(get_distance_vector(b0-p, b1-p, b2-p));
}


void mainImage( out vec4 fragColor, in vec2 fragCoord ) {
	const float R = 0.45;
	const float T = 0.05;
	const float A = 0.5;
	const float HALO = 0.01;
	vec2 uv = 2.0 * fragCoord.xy / iResolution.xy - 1.0;
	uv.x *= iResolution.x / iResolution.y;
	float r = length(uv);
	float a = atan(uv.y, uv.x) + iTime/5.0;
	float distance = abs(R - r) - T;
	distance = max(abs(mod(a, A) - A/2.0) * R - T, distance) * 3.0;
	float c = 1.0 - clamp(distance * 8.0, 0.0, 1.0);
	fragColor = vec4(c, c, 1.0, 1.0);
	// if (distance <= 0.0) fragColor = vec4(1.0, 0.0, 0.0, 1.0);
}
