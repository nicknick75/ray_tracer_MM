using Images, FileIO, ColorTypes, StaticArrays

include("camera.jl")
include("objects.jl")
include("utils.jl")

#------------najbolj osnovne stvari



#osnovne funkcije: linear algebra paket

#render funkcija: da dejansko generira sliko
#trenutno placeholder
function render(cam::Camera, objects, light_source)
    img = Array{RGB{N0f8}}(undef, cam.nx, cam.ny)

    for j in 1:cam.ny, i in 1:cam.nx
        ray = generate_ray(cam, i, j)
        color = raytrace(ray, objects, cam, light_source)
        img[i, j] = color
    end

    return img
end
 
function look(perspective, target, up)
    w = normalize(target .- perspective)
    x = normalize(cross(up, w))
    y = cross(w, x)
    return x, y, w
end


function main()  
    # Kamera setup
    perspective = [0.0, 0.0, 0.0]
    target = [0.0, 0.0, 5.0]
    up = [0.0, 1.0, 0.0]
    x, y, w = look(perspective, target, up)

    cam = Camera(
        perspective,
        x, y, w,
        -1.0, 1.0,     # left, right
        -1.0, 1.0,     # bottom, top
        1.0,           # focal length
        400, 400       # resolution
    )

    #izvor svetolobe (light source)
    light_source = [5.0, 5.0, -10.0]
    
    # Scena
    sphere = Sphere(0.0, 1.0, 5.0, 2.0,RGB{N0f8}(1,0.329,0.686))
    sphere2 = Sphere(0.0, 0.0, 3.0, 1.0,RGB{N0f8}(1,0.757,0.369))
    #plane = Plane(0.0, 1.0, 0.0, -1.0)
    objects = [sphere, sphere2]

    # Render
    img = render(cam, objects, light_source)
    save("../images/render.png", img)

end



