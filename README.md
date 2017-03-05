Shaderjoy
=========

A clone of a subset of the functionality of [Shadertoy](http://shadertoy.com)
meant to be run locally. This page immediately reloads whatever shader script
changes; editing on Shaderjoy first allows use of a local editor of choice,
plus the benefit of version control and so on, if desired. Don't touch that
reload button - edit the shader, and it will be displayed, is what I'm telling
you.

Hence, the server is spammed with reloads, this being the reason that this is
intended to be served locally (that is, served on localhost) e.g. with

	python -m HTTPSimpleServer

Any file with a `.glsl` extension is regarded as a fragment shader that
adhering to the same (but a subset of) the `mainImage` function and uniform
conventions that Shadertoy expects.

When you're happy, paste the shader code into Shadertoy to share with the
world.
