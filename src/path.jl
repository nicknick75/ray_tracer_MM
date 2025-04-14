using Images, FileIO, ColorTypes

include("camera.jl")
include("objects.jl")
include("utils_pathtracer.jl")  



function render_path_traced_scene(width, height; samples=10, depth=3)
    eye = [0.0, 0.0, 0.0]
    look_at = [0.0, 0.0, 5.0]
    up = [0.0, 1.0, 0.0]

    w = normalize(look_at .- eye)
    x = normalize(cross(w, up))
    y = normalize(cross(x, w))

    aspect = width / height
    h = 2.0
    img_w = aspect * h
    l, r = -img_w / 2, img_w / 2
    b, t = -h / 2, h / 2

    d = 0.8  
    cam = Camera(eye, x, y, w, l, r, b, t, d, width, height)

 
    red = RGB{N0f8}(1.0, 0.0, 0.0)
    light_blue = RGB{N0f8}(0.50, 0.91, 0.96)
    olive = RGB{N0f8}(0.37, 0.56, 0.32)

    light = [2.0, 4.0, 3.0]

    objects = [
        Sphere(0.0, -0.3, 2.5, 0.6, 16.0, red),
        Plane(1, 0, 0, -1, 0, olive),   
        Plane(0, 0, 1, 5, 0, light_blue) 
    ]
    

    img = Array{RGB{N0f8}}(undef, cam.nx, cam.ny)

    for j in 1:cam.ny, i in 1:cam.nx
        pixel_color = RGB{Float64}(0, 0, 0)

        for _ in 1:samples
            ray = generate_ray(cam, i, j)
            pixel_color += RGB{Float64}(pathtrace(ray, objects, light, depth, 0.3, 0.5))
        end

        pixel_color /= samples
        img[i, j] = RGB{N0f8}(clamp01.(pixel_color))
    end

    return img
end

function main()
    img = render_path_traced_scene(300, 300; samples=15, depth=2) #za prvi test manj
    save("../images/pathtraced_scene2.png", img)
end

main()
