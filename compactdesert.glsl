
vec3 random( vec2 p ) {
    return fract(sin(vec3(dot(p,vec2(127.1,311.7)),
                          dot(p,vec2(198.5,455.1)),
                          dot(p,vec2(269.5,183.3))))*43758.5453);
}

const float mm = .01;
const float OR = 60. * mm;
const float OE = 58. * mm;
const float IE = 25. * mm;
const float IR = 7.5 * mm;
const float PI = 3.1415926585;
const float G = .75;

const vec3 uSunDirection = normalize(vec3(.5,.5,1));

// http://matkl.github.io/average-color/
const vec3 avgColor = vec3(78, 80, 85) / 255.;

vec3 gradient(float t) {
    vec3 off = vec3(.0, .1, .2) * 10.464;
    return cos(t * 3. + off) / 2. + .5;
}

vec3 gradient(vec2 p) {
    return ( gradient(p.x) + gradient(p.y) ) / 2.;
}


vec3 skyColor(vec3 rd) {
      // Sky from iq's Rainforest demo
	  vec3 col = 0.8 * vec3(0.4,0.65,1.0) - 2. * rd.y * vec3(0.4,0.36,0.4);

				    // clouds
/*
				    float t = (1000.0-ro.y)/rd.y;
				    if( t>0.0 )
				    {
				        vec2 uv = (ro+t*rd).xz;
				        float cl = fbm_9( uv*0.002 );
				        float dl = smoothstep(-0.2,0.6,cl);
				        col = mix( col, vec3(1.0), 0.4*dl );
				    }
*/
    col *= 0.8;

  // sun glare
  float sun = clamp(dot(uSunDirection,rd), 0.0, 1.0);
  col += 0.4*vec3(1.0,0.6,0.3)*(0.7 * pow(sun, 6.0) + exp(-10. * rd.y - .25) + 4. * smoothstep(.997, 1.00, sun));
  //return vec3(0);
  return col;
}


void mainImage(out vec4 fragColor, in vec2 fragCoord) {
	vec2 p = (-iResolution.xy + 2.0*fragCoord.xy) / iResolution.y;

     // camera movement
    float time = iGlobalTime;
    //time = 0.;
	vec3 ro = vec3( 0.2 * sin(1. * PI * time), 1.8 + 0.1 * sin(2. * PI * time), 1.4 * time);
    vec3 ta = vec3( 0.0, 1.0, 0.0 );
	// create view ray
    vec2 mouse = vec2(0);
    mouse = iMouse.xy  / iResolution.xy * 2. - 1.;
	vec3 rd = normalize(vec3(p + mouse, 1.));// p.x*uu + p.y*vv + 1.5*ww );

    vec3 col = vec3(0.0);

	// raytrace-plane
	float h = -ro.y/rd.y;
    if (h < 0.) {
    	col = skyColor(vec3(rd.x, rd.y, rd.z));
    } else {
		vec3 pos = ro + h * rd;

        float top = -99999.;
        int topn = -1;
        vec2 point = pos.xz;
        vec2 cell = floor(point / G) * G;

        struct Cell {
            vec2 cell;
            vec3 r;
            vec2 pt;
            float dist;
        };

        Cell nabes[9];
        //  x   z  n
        // -1, -1  0
        // -1,  0  1
        // -1, +1  2
        //  0, -1  3
        //  0,  0  4
        //  0, +1  5
        // +1, -1  6
        // +1,  0  7
        // +1, +1  8

        for (int i = -1; i <= 1; ++i) {
            for (int j = -1; j <= 1; ++j) {
                int n = 4 + j * 3 + i;
                nabes[n].cell = cell + vec2(i, j) * G;
                nabes[n].r = random(nabes[n].cell) * G;
                nabes[n].pt = nabes[n].cell + nabes[n].r.xz;
                nabes[n].dist = distance(nabes[n].pt, point);
                float zorder = nabes[n].r.y;
                float d = nabes[n].dist;
                if (d < OR && d > IR && zorder > top) {
                    topn = n;
                    top = zorder;
                }
            }
        }

        vec3 sky = skyColor(reflect(rd, normalize(vec3(nabes[7].r.y - nabes[1].r.y, 10,
                                                       nabes[5].r.y - nabes[3].r.y))));

        if (topn >= 0) {

            if (nabes[topn].dist < IE || nabes[topn].dist > OE) {
            	col = sky;
            } else {
                float angle = atan(point.y - nabes[topn].pt.y,
                                   point.x - nabes[topn].pt.x);
                col = gradient(angle * 4. / PI);
            }

            // Occlusion
            for (int n = 0; n < 9; ++n) {
                float zorder = nabes[n].r.y;
                float d = nabes[n].dist;
                if (d > OR && zorder > top) {
                    float x = d - OR;
                    col *= smoothstep(-IE, IE, x);
                } else if (d < IR && zorder > top) {
                    float x = IR - d;
                    col *= smoothstep(-IE, IE, x);
                }
            }
        }


        col = mix(col, avgColor*.8, 1.-exp(-.08*(h-2.)));

        col += sky * 0.4;
	}

	//col = sqrt( col );
	//col = pow(col, vec3(1./1.2));

	fragColor = vec4( col, 1.0 );
}
