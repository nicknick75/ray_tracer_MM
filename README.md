# Ray Tracer & Path Tracer in Julia

This project implements a **basic ray tracer**, **advanced ray tracer** and **path tracer**.

| File | Description |
|------|-------------|
| `main.jl` | Entry point 
| `camera.jl` | Defines the `Camera` struct and ray generation |
| `object.jl` | Implements abstract `Object` type and concrete subtypes (Sphere, Plane, etc.) |
| `utils.jl` | Core rendering logic: ray tracing, Newton’s method, shading, shadows |
| `utils_pathtracer.jl` | Path tracing |
| `ref_raf_utils.jl` | Refraction and reflection handling |
| `test.jl` | Example scenes |

running:
  include("main.jl") //or whatever the test name is
  main()

