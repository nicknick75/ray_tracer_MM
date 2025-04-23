using Images, FileIO, ColorTypes

include("camera.jl")
include("objects.jl")
include("utils.jl")
include("ref_utils.jl")


function render_torus_scene(sirina, visina)
    p = [0.0, 0.0, -2.0]            
    look_at = [0.0, 0.0, 2.0]      
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

    # Light source
    light_source = [3.0, 5.0, -1.0]

    # Colors
    yellow = RGB{N0f8}(1.0, 1.0, 0.0)
    grey = RGB{N0f8}(0.6, 0.6, 0.6)
    hot_pink = RGB(1.0, 0.41, 0.71)
    blue  = RGB{N0f8}(0.0, 0.0, 1.0)
 
    reflective_floor = Plane(0.0, 1.0, 0.0, -1.2, 128.0, grey, 1.0, false)
    # Shiny yellow torus in the middle
    torus_center = [0.0, 0.0, 2.5]
    shiny_yellow_torus = Torus(0.5, 0.15, torus_center, 64.0, yellow, 1.0, false)
    pink = Torus(0.8, 0.15, torus_center, 64.0, hot_pink, 1.0, false)
    blue_t = Torus(1.1, 0.15, torus_center, 64.0, blue, 1.0, false)


    ambient = 0.3
    objects = [reflective_floor, shiny_yellow_torus, pink, blue_t]

    img = Array{RGB{N0f8}}(undef, cam.nx, cam.ny)

    for j in 1:cam.ny, i in 1:cam.nx
        ray = generate_ray(cam, i, j)
        img[i, j] = ref_raf_raytrace(ray, objects, cam, light_source, ambient; depth=3)
    end

    return img
end

function main_torus()
    sirina, visina = 800, 800
    img = render_torus_scene(sirina, visina)
    save("../images/tori.png", img)
end
