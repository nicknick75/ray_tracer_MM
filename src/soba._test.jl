using Images, FileIO, ColorTypes

include("camera.jl")
include("objects.jl")
include("utils.jl")

function render(sirina, visina)
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
    d = 0.5

    cam = Camera(p, x, y, w, left, right, bottom, top, d, sirina, visina)
    # cam = Camera(
    #     p, x, y, w,
    #     -image_width/2, image_width/2,
    #     -image_height/2, image_height/2,
    #     1.0, sirina, visina
    # )

    light_source = [1.0, 0.5, 0.0]

  
    red_sphere   = Sphere(-0.5, 0.0 , 2.0, 0.5, 32.0, RGB{N0f8}(1.0, 0.0, 0.0))   
   green_sphere = Sphere(-0.7, -0.5, 1.3, 0.2, 8.0,RGB{N0f8}(0.0, 1.0, 0.0))   



   dark_gray = RGB{N0f8}(0.2, 0.2, 0.2)
   light_gray = RGB{N0f8}(0.85, 0.85, 0.85)

   #wannabe stene
    floor   = Plane(1.0, 0.0, 0.0, -1.0, 0.0, dark_gray)        
    ceiling = Plane(1.0, 0.0, 0.0, 2.0, 0.0, light_gray)       
    left    = Plane(0.0, 1.0, 0.0, 2.0, 0.0, light_gray)       
    right   = Plane(0.0, 1.0, 0.0, -2.0, 0.0, light_gray)      
    back    = Plane(0.0, 0.0, 1.0, 5.0, 0.0, light_gray)     


   objects = [red_sphere, green_sphere, back, floor, left, right, ceiling]
   img = Array{RGB{N0f8}}(undef, cam.nx, cam.ny)

   for j in 1:cam.ny, i in 1:cam.nx
       ray = generate_ray(cam, i, j)
       img[i, j] = raytrace(ray, objects, cam, light_source)
   end

   return img
end

function main()
   sirina, visina = 800, 800
   img = render(sirina, visina)
   save("../images/soba.png", img)
end