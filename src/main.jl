using Images, FileIO, ColorTypes, StaticArrays, LinearAlgebra

include("camera.jl")
include("objects.jl")
include("utils.jl")
include("ref_raf_utils.jl")
function render_scene(sirina, visina)
    p = [0.0, 0.0, -2.0]            
    look_at = [0.0, 0.0, 3.0]      
    up = [0.0, 1.0, 0.0]

    w = normalize(look_at .- p)
    x = normalize(cross(w, up))
    y = normalize(cross(x, w))

    aspect_ratio = sirina / visina
    image_height = 2.0
    image_width = aspect_ratio * image_height

    left = -image_width / 2
    right = image_width / 2
    bottom = -image_height / 2
    top = image_height / 2
    d = 1.0

    cam = Camera(p, x, y, w, left, right, bottom, top, d, sirina, visina)

    light_source = [4.0, 3.0, -1.0]

    # colors
    yellow = RGB{N0f8}(1.0, 1.0, 0.0)
    grey = RGB{N0f8}(0.6, 0.6, 0.6)
    olive = RGB{N0f8}(0.37, 0.56, 0.32)
    white = RGB{N0f8}(1.0, 1.0, 1.0)
    blue = RGB{N0f8}(0.3, 0.6, 1.0)
    red = RGB{N0f8}(1.0, 0.0, 0.0)

    # objects
    floor = Plane(1.0, 0.0, 0.0, -1.2, 0.0, olive, 1.0, false) 
    solid = Sphere(0.5, 0.5, 5.0, 1.5, 0.0, red, 0, false) 

    ambient = 0.3
    objects = [floor, solid]

    img = Array{RGB{N0f8}}(undef, cam.nx, cam.ny)

    for j in 1:cam.ny, i in 1:cam.nx
        ray = generate_ray(cam, i, j)
        img[i, j] = ref_raf_raytrace(ray, objects, cam, light_source, ambient; depth=3)
    end
    return img
end

function main()
    sirina, visina = 700, 700
    img = render_scene(sirina, visina)
    save("../images/scene.png", img)
end



