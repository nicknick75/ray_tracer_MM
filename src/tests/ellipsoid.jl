function render_ellipsoid_scene(sirina, visina)
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

    # Light source
    light_source = [4.0, -3.0, -1.0]

    # Colors
    yellow = RGB{N0f8}(1.0, 1.0, 0.0)
    grey = RGB{N0f8}(0.6, 0.6, 0.6)
    baby_pink  = RGB{N0f8}(1.0, 0.8, 0.9)
    white = RGB{N0f8}(0.95, 0.95, 0.95)
    blue = RGB{N0f8}(0.3, 0.6, 1.0)
    baby_blue  = RGB{N0f8}(0.7, 0.85, 1.0)

    # Reflective floor
    #floor = Plane(1.0, 0.0, 0.0, -1.0, 0.0, baby_pink, 1.0, false)
    #back  = Plane(0.0, 0.0, 1.0, 10.0, 0.0, white, 1.0, false)

    #ellipsoid = Ellipsoid(1, 0, 3, 2.0, 1.0, 1.0, 128, baby_pink, 1.0, false)
    torus = Torus(1.0, 0.5, [1.0, 0.0, 3.0], 128.0, baby_blue, 1.0, false)

    ambient = 0.3
    objects = [torus]

    img = Array{RGB{N0f8}}(undef, cam.nx, cam.ny)

    for j in 1:cam.ny, i in 1:cam.nx
        ray = generate_ray(cam, i, j)
        img[i, j] = ref_raf_raytrace(ray, objects, cam, light_source, ambient; depth=3)
    end

    return img
end

function main_ellipsoid()
    sirina, visina = 700, 700
    img = render_ellipsoid_scene(sirina, visina)
    save("../images/elips.png", img)
end
