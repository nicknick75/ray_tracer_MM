using Images, FileIO, ColorTypes, StaticArrays

include("camera.jl")
include("objects.jl")
include("utils.jl")
#------------najbolj osnovne stvari



#osnovne funkcije: linear algebra paket

#render funkcija: da dejansko generira sliko
#trenutno placeholder
#=
    trenutno je samo en korg na srednini neki dela neki ne ker pomoje bi morala biti senca povsod ne samo na zgornjem delu
    lahko bi mele neko funkcijo za kamero da bi lazje na zacetku jo napisali 
=#
function render(sirina, visina) 
    # kamera setup
    p = [0.0, 0.0, 0.0]
    look_at = [0.0, 0.0, 5.0]
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
    img = Array{RGB{N0f8}}(undef, cam.nx, cam.ny) #za kamero 
    sfera = Sphere(0.0, 0.0, 5.0, 2.0)  # sredina na Z = -5, radij = 1
    sfera2 = Sphere(0.0, 1.0, 2.0, 1.0)
    # sfera3 = Sphere(1.0, 0.0, 2.0, 1.0)
    #plane = Plane(1.0, 1.0, 1.0, 5.0)
    objects =[sfera]
    for j in 1:cam.ny, i in 1:cam.nx
        ray = generate_ray(cam, i, j)
        color = raytrace(ray, objects, cam)
        img[i, j] = color
    end

    return img
end    


function main()  
    sirina, visina = 500, 500
    img = render(sirina, visina)
    save("../images/render.png", img)
end



