Shaderjoy
=========

A clone of a subset of the functionality of [Shadertoy](http://shadertoy.com)
meant to be run locally. This page always reloads whatever shader script
changes; the purpose of Shaderjoy is that it allow a local editor of choice to
be used, with the benefit of version control and so on if desired. Changes to
the shader are immediately reflected on the page, and the page will display
whatever shader is edited last. Edit the shader, and it will be displayed, is
what I'm telling you. Hence, the server is spammed with reloads, this being
the reason that this is intended to be served locally (that is, served on
localhost) e.g. with

	python -m HTTPSimpleServer

Any file with a `.glsl` extension is regarded as a shader that is expected to
adhere to the same (but a subset of) the `mainImage` function and uniform
conventions that Shadertoy expects.
