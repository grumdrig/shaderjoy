
// From this shitty gist https://gist.github.com/patriciogonzalezvivo/670c22f3966e662d2f83
//	Classic Perlin 3D Noise
//	by Stefan Gustavson
//
vec4 permute(vec4 x){return mod(((x*34.0)+1.0)*x, 289.0);}
vec4 taylorInvSqrt(vec4 r){return 1.79284291400159 - 0.85373472095314 * r;}
vec3 fade(vec3 t) {return t*t*t*(t*(t*6.0-15.0)+10.0);}

float noise(vec3 P){
  vec3 Pi0 = floor(P); // Integer part for indexing
  vec3 Pi1 = Pi0 + vec3(1.0); // Integer part + 1
  Pi0 = mod(Pi0, 289.0);
  Pi1 = mod(Pi1, 289.0);
  vec3 Pf0 = fract(P); // Fractional part for interpolation
  vec3 Pf1 = Pf0 - vec3(1.0); // Fractional part - 1.0
  vec4 ix = vec4(Pi0.x, Pi1.x, Pi0.x, Pi1.x);
  vec4 iy = vec4(Pi0.yy, Pi1.yy);
  vec4 iz0 = Pi0.zzzz;
  vec4 iz1 = Pi1.zzzz;

  vec4 ixy = permute(permute(ix) + iy);
  vec4 ixy0 = permute(ixy + iz0);
  vec4 ixy1 = permute(ixy + iz1);

  vec4 gx0 = ixy0 / 7.0;
  vec4 gy0 = fract(floor(gx0) / 7.0) - 0.5;
  gx0 = fract(gx0);
  vec4 gz0 = vec4(0.5) - abs(gx0) - abs(gy0);
  vec4 sz0 = step(gz0, vec4(0.0));
  gx0 -= sz0 * (step(0.0, gx0) - 0.5);
  gy0 -= sz0 * (step(0.0, gy0) - 0.5);

  vec4 gx1 = ixy1 / 7.0;
  vec4 gy1 = fract(floor(gx1) / 7.0) - 0.5;
  gx1 = fract(gx1);
  vec4 gz1 = vec4(0.5) - abs(gx1) - abs(gy1);
  vec4 sz1 = step(gz1, vec4(0.0));
  gx1 -= sz1 * (step(0.0, gx1) - 0.5);
  gy1 -= sz1 * (step(0.0, gy1) - 0.5);

  vec3 g000 = vec3(gx0.x,gy0.x,gz0.x);
  vec3 g100 = vec3(gx0.y,gy0.y,gz0.y);
  vec3 g010 = vec3(gx0.z,gy0.z,gz0.z);
  vec3 g110 = vec3(gx0.w,gy0.w,gz0.w);
  vec3 g001 = vec3(gx1.x,gy1.x,gz1.x);
  vec3 g101 = vec3(gx1.y,gy1.y,gz1.y);
  vec3 g011 = vec3(gx1.z,gy1.z,gz1.z);
  vec3 g111 = vec3(gx1.w,gy1.w,gz1.w);

  vec4 norm0 = taylorInvSqrt(vec4(dot(g000, g000), dot(g010, g010), dot(g100, g100), dot(g110, g110)));
  g000 *= norm0.x;
  g010 *= norm0.y;
  g100 *= norm0.z;
  g110 *= norm0.w;
  vec4 norm1 = taylorInvSqrt(vec4(dot(g001, g001), dot(g011, g011), dot(g101, g101), dot(g111, g111)));
  g001 *= norm1.x;
  g011 *= norm1.y;
  g101 *= norm1.z;
  g111 *= norm1.w;

  float n000 = dot(g000, Pf0);
  float n100 = dot(g100, vec3(Pf1.x, Pf0.yz));
  float n010 = dot(g010, vec3(Pf0.x, Pf1.y, Pf0.z));
  float n110 = dot(g110, vec3(Pf1.xy, Pf0.z));
  float n001 = dot(g001, vec3(Pf0.xy, Pf1.z));
  float n101 = dot(g101, vec3(Pf1.x, Pf0.y, Pf1.z));
  float n011 = dot(g011, vec3(Pf0.x, Pf1.yz));
  float n111 = dot(g111, Pf1);

  vec3 fade_xyz = fade(Pf0);
  vec4 n_z = mix(vec4(n000, n100, n010, n110), vec4(n001, n101, n011, n111), fade_xyz.z);
  vec2 n_yz = mix(n_z.xy, n_z.zw, fade_xyz.y);
  float n_xyz = mix(n_yz.x, n_yz.y, fade_xyz.x);
  return 2.2 * n_xyz;
}

float fbm(vec3 P) {
	return (noise(P)
		+ 0.50 * noise(P/2.0 + vec3(23.12, 92.93, 29.91))
		+ 0.25 * noise(P/4.0 + vec3(45.21, 29.02, 23.11))
		)
	// * 1.75
		;
}



// https://www.youtube.com/watch?v=aeEn609nkRs

#define iNumPoints 11939
#define ClearColor (1,1,1,1)

void mainParticle(out vec2 pointPosition, out float pointSize, in int pointIndex) {
	const float WINDINGS = 10.0;
	const float R = 5.0;
	const float SWATH = 0.4 * R;
	float t = float(pointIndex)/float(iNumPoints);// + iTime * 0.001;
	// doesn't really matter much what arc spacing to use but using the golden ratio
	// times pi to minimize overlap
	float a = 1.61803398875 * 3.14159265 * float(pointIndex);
	float w = t * SWATH;

	vec2 uv = vec2(cos(a), sin(a));

	float h = 1.2 * abs(noise(vec3(uv * (R + w), iTime * 0.2)));
	h = pow(h, 1.2);
	// float c = clamp(pow(1.0 / h, 0.9), 0.0, 1.0);
	// if (c < c = d < h * 3.0 ? 1.0 : 0.0;
	// c *= noise(100.0 * normalize(uv) * iTime * 0.01);
	/*
	float h2 = 0.05 * (0.7 + noise(vec3(normalize(uv) * 10.0, 2938.982 + iTime * 0.8)));
	float c2 = clamp(pow((d-1.0) / h2, 4.0), 0.0, 1.0);
	// c *= pow((d-1.0) / h2, 4.0);
	c = c * c2;
	fragColor = vec4(c, c, c,1.0);
	// fragColor.r = noise(uv * 10.0);
	*/

	pointPosition = (1.0 + 0.1 * h) * uv;
	pointPosition.x *= iResolution.y / iResolution.x;
	pointPosition *= 0.8;
	pointSize = 0.5;
}

void mainImage(out vec4 fragColor, in vec2 pointCoord, in int pointIndex) {
	// pointCoord = pointCoord * 2.0 - 1.0;
	// pointCoord *= 1.1; // point coordinates don't cover the whole range (in firefox at least)
	// float d = length(pointCoord);
	//d = 0.0;
	// float t = float(pointIndex)/float(iNumPoints);
	fragColor = vec4(0,0,0,1);// d < 1.0 ? 0.8 : 0.0);
}
