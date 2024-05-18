const UNIFORMS = `
		uniform vec3      iResolution;      // viewport resolution (in pixels)
		uniform float     iTime;            // shader playback time (in seconds)
		uniform float     iGlobalTime;      // obsolescent progenitor of iTime
		uniform float     iTimeDelta;       // render time (in seconds)
		uniform mediump int       iFrame;   // shader playback frame
		uniform vec4      iMouse;           // mouse coords. xy: current (if MLB down), zw: click
		uniform vec4      iDate;            // (year, month, day, time in seconds)
`;

function compileShader(code, filename) {
	let program = gl.createProgram();
	program.isParticleShader = code.search(/\bmainParticle\b/g) >= 0;
	program.isPixelShader = !program.isParticleShader;

	let includedCode = '';

	for (let m of code.matchAll(/^#include\s+"([^"]+)"\s*$/gm)) {
		let filename = m[1].slice(0, -5); // remove ext
		console.log(filename, SHADERS[filename], SHADERS);
		includedCode += `
			#define mainImage ${filename}_mainImage
			#line 1
			${SHADERS[filename].currentContents}
			#undef mainImage
		`;
	}

	// Vertex shader
	let vertexShader = gl.createShader(gl.VERTEX_SHADER);
	if (program.isPixelShader) {
		gl.shaderSource(vertexShader, `#version 300 es
			precision highp float;

			void main() {
				gl_Position = vec4(1, -1, 0, 1);
				if (gl_VertexID < 4 && gl_VertexID != 1) gl_Position.x = -1.0;
				if (gl_VertexID > 1 && gl_VertexID != 4) gl_Position.y = 1.0;
			}
		`);
	} else {
		gl.shaderSource(vertexShader, `#version 300 es
			precision highp float;

			${UNIFORMS}

			flat out int pointIndex;

			#line 1
			${code}

			void main() {
				mainParticle(gl_Position.xy, gl_PointSize, gl_VertexID);
				gl_Position.zw = vec2(0, 1);
				pointIndex = gl_VertexID;
			}
		`);
	}
	gl.compileShader(vertexShader);
	if (!gl.getShaderParameter(vertexShader, gl.COMPILE_STATUS)) throw new Error(gl.getShaderInfoLog(vertexShader));

	// Fragment shader
	let fragmentShader = gl.createShader(gl.FRAGMENT_SHADER);
	if (program.isPixelShader) {
		gl.shaderSource(fragmentShader, `#version 300 es
			precision highp float;

			${UNIFORMS}

			out vec4 FragColor;

			${includedCode}

			#line 1
			${code}

			void main() {
				mainImage(FragColor, gl_FragCoord.xy);
			}
		`);
	} else {
		gl.shaderSource(fragmentShader, `#version 300 es
			precision highp float;

			${UNIFORMS}

			flat in int pointIndex;
			out vec4 FragColor;

			#line 1
			${code}

			void main() {
				mainImage(FragColor, gl_PointCoord, pointIndex);
			}
		`);
	}
	gl.compileShader(fragmentShader);
	if (!gl.getShaderParameter(fragmentShader, gl.COMPILE_STATUS))
		throw new Error(gl.getShaderInfoLog(fragmentShader), filename);
	gl.attachShader(program, vertexShader);
	gl.attachShader(program, fragmentShader);
	gl.linkProgram(program);
	if (!gl.getProgramParameter(program, gl.LINK_STATUS)) throw new Error(gl.getProgramInfoLog(program));
	gl.useProgram(program);

	if (program.isParticleShader) {
		program.iNumPoints = 100;
		let m = code.match(/^#\s*define\s+iNumPoints\s+([0-9]+)/m);
		if (m) {
			program.iNumPoints = parseInt(m[1]);
		}

		m = code.match(/^#\s*define\s+ClearColor\s+\(\s*([^,)])\s*,\s*([^,)])\s*,\s*([^,)])\s*,\s*([^,)])\s*\)/m);
		if (m) {
			gl.clearColor(Number(m[1]), Number(m[2]), Number(m[3]), Number(m[4]));
		}

		gl.enable(gl.BLEND);
		gl.blendFunc(gl.SRC_ALPHA, gl.ONE_MINUS_SRC_ALPHA);
	} else {
		gl.disable(gl.BLEND);
	}

	return program;
}


// All these globals are pretty bad
let T0, T1 = 0, DT = 0;
let FRAME = 0;
let NOW;
let TIME_ELAPSED;
let ext;


function renderFrame(program, canvas) {
	if (!ext) ext = gl.getExtension('EXT_disjoint_timer_query_webgl2');
	let clock = performance.now();
	gl.viewport(0, 0, canvas.width, canvas.height);
	if (typeof T0 === 'undefined') {
		T0 = clock;
		FRAME = 0;
	}
	FRAME++;
	NOW = (clock - T0)/1000;
	const dk = .99;
	DT = DT * dk + (1-dk) * (clock - T1)/1000;
	gl.uniform3f(gl.getUniformLocation(program, "iResolution"), canvas.width, canvas.height, 1);
	gl.uniform1f(gl.getUniformLocation(program, "iTime"), NOW);
	gl.uniform1f(gl.getUniformLocation(program, "iGlobalTime"), NOW);
	gl.uniform1f(gl.getUniformLocation(program, "iTimeDelta"), DT);
	gl.uniform1i(gl.getUniformLocation(program, "iFrame"), FRAME);
	gl.uniform4fv(gl.getUniformLocation(program, "iMouse"), canvas.iMouse ?? [0,0,0,0]);
	let today = new Date();
	gl.uniform4f(gl.getUniformLocation(program, "iDate"), today.getFullYear(), today.getMonth(), today.getDay(), +today);
	T1 = clock;

	if (ext && ext.query && (!ext.last || NOW - ext.last > 0.1)) {
		ext.last = NOW;
		const available = gl.getQueryParameter(ext.query, gl.QUERY_RESULT_AVAILABLE);
		const disjoint = gl.getParameter(ext.GPU_DISJOINT_EXT);

		if (available && !disjoint) {
			TIME_ELAPSED = gl.getQueryParameter(ext.query, gl.QUERY_RESULT) / 1e6;
			gl.deleteQuery(ext.query);
			ext.query = null;
		}
	}

	let query;
	if (ext && !ext.query) {
		query = gl.createQuery();
		gl.beginQuery(ext.TIME_ELAPSED_EXT, query);
	}

	if(program.isParticleShader) {
		gl.clear(gl.DEPTH_BUFFER_BIT | gl.COLOR_BUFFER_BIT);
		gl.uniform1i(gl.getUniformLocation(program, "iNumPoints"), program.iNumPoints);
		gl.drawArrays(gl.POINTS, 0, program.iNumPoints);
	} else {
		gl.drawArrays(gl.TRIANGLES, 0, 6);
	}

	if (query) {
		ext.query = query;
		gl.endQuery(ext.TIME_ELAPSED_EXT);
	}
}