using Images, FileIO, ColorTypes

include("camera.jl")
include("objects.jl")
include("utils_pathtracer.jl")

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
    d = 1.0

    cam = Camera(p, x, y, w, left, right, bottom, top, d, sirina, visina)
    # cam = Camera(
    #     p, x, y, w,
    #     -image_width/2, image_width/2,
    #     -image_height/2, image_height/2,
    #     1.0, sirina, visina
    # )

    #light_source = [1.0, 0.5, 0.0]
    light = Sphere(1.0, 2.0, -1.5, 1.5, 0.0, RGB{N0f8}(0,0,0), 0.0, false;light_source=true)

    pink = RGB{N0f8}(1.0, 0.5, 0.8)
    dark_gray = RGB{N0f8}(0.2, 0.2, 0.2)
    light_gray = RGB{N0f8}(0.85, 0.85, 0.85)
    light_blue = RGB{N0f8}(0.50, 0.91, 0.96)
    olive = RGB{N0f8}(0.37, 0.56, 0.32)
   
    red_sphere   = Sphere(0.0, 0.0 , 2.0, 1.0, 32.0, RGB{N0f8}(1.0, 0.0, 0.0), 0.0, false)   
    #blue_sphere = Sphere(-0.8, 1.0, 1.3, 0.2, 64.0,RGB{N0f8}(0.0, 0.0, 1.0))   
    #torus = Torus_side(0.3, 0.1, [-0.5, 0.0, 1.2], 32.0, pink)

    #stene
    floor   = Plane(1.0, 0.0, 0.0, -1.0, 0.0, olive, 0.0, false)        
    #ceiling = Plane(1.0, 0.0, 0.0, 2.0, 0.0, light_gray)       
    #left    = Plane(0.0, 1.0, 0.0, 2.0, 0.0, light_gray)       
    #right   = Plane(0.0, 1.0, 0.0, -2.0, 0.0, light_gray)      
    back    = Plane(0.0, 0.0, 1.0, 5.0, 0.0, light_blue, 0.0, false)     

    ambient = 0.2
    objects = [red_sphere, back, floor, light]
    img = Array{RGB{N0f8}}(undef, cam.nx, cam.ny)

    for j in 1:cam.ny, i in 1:cam.nx
        ray = generate_ray(cam, i, j)
        color = RGB{Float64}(0,0,0)
        for k in 1:10
            color += RGB{Float64}(pathtrace(ray, objects, 3, ambient; max_inc=10))
            # @show color
        end
        #img[i, j] = RGB{Float64}(clamp01(color / 10))
        img[i, j] = RGB{Float64}(clamp01(color / 10 * 2))# 2.2 scaled factor
        # @show img[i,j]
    end
    return img
end

function main()
   sirina, visina = 800, 800
   img = render(sirina, visina)
   save("../images/pathtraceColour10B.png", img)
end