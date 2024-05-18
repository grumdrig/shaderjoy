Shaderjoy
=========

A clone of a subset of the functionality of [Shadertoy](http://shadertoy.com)
meant to be run locally. This page immediately live-reloads whatever shader
script changes; editing on Shaderjoy first allows use of a local editor of
choice, plus the benefit of version control and so on, if desired.

Hence, the server is spammed with reloads, this being the reason that this is
intended to be served locally (that is, served on localhost) e.g. with

	python -m HTTPSimpleServer

Any file with a `.glsl` extension is regarded as a fragment shader that
adhering to the same (but a subset of) the `mainImage` function and uniform
conventions that Shadertoy expects.

Specifically `mainImage` function conforms to this signature:

	void mainImage( out vec4 fragColor, in vec2 fragCoord )

And the uniforms available to the program are:

	uniform vec3      iResolution;      // viewport resolution (in pixels)
	uniform float     iTime;            // shader playback time (in seconds)
	uniform float     iTimeDelta;       // render time (in seconds)
	uniform mediump int       iFrame;   // shader playback frame
	uniform vec4      iMouse;           // mouse coords. xy: current (if MLB down), zw: click
	uniform vec4      iDate;            // <year, month, day, time in seconds>

When you're happy, paste the shader code into Shadertoy to share with the
world.


Particle System
---------------

Alternatively, you can program particle systems by providing the following
elements in the source file:

	#define iNumPoints 100

Set the number of particles (which must be a non-negative integer) by defining
`iNumPoints` in the source. The default value is 100.

	#define ClearColor (0,0,0,1)

Optionally, define a color for the background, in RGBA components, each on
`[0, 1]`.

Then define a `mainParticle` function conforming to the following signature:

	void mainParticle(out vec2 pointPosition, out float pointSize, in int pointIndex)

In the function body, the size and position of the `pointIndex`-th particle
should be set.

Finally, define a `mainImage` function conforming to this signature:

	void mainImage(out vec4 fragColor, in vec2 pointCoord, in int pointIndex)

which will be called for each pixel in each particle. `pointCoord` is simply
`gl_PointCoord`, the coordinates of the pixel within the particle, on the
range `[0, 1]`.


