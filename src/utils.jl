using ColorTypes, LinearAlgebra

#newton funkcija iz vaj 
function newton(F, JF, Ray, t0; tol = 1e-8, maxit = 100)
    # set two variables which will be used (also) outside the for loop
    ray(k) = Ray.origin + k*Ray.direction
    t = t0
    n = 1
    # first evaluation of F
    Y = F(ray(t))
    for outer n = 1:maxit    
        t = t0 - JF(t0)\Y
        Y = F(ray(t))
        # check if the result is within prescribed tolerance
        if norm(t-t0) < tol #spustimo clen Y
            break;
        end
        # otherwise repeat
        t0 = t
    end
    # a warning if maxit was reached
    if n == maxit
        @warn "no convergence after $maxit iterations"
    end
    # let's return a named tuple
    return (t = t, n = n)
end

#intersection 
# t = (t1 + t2)/ 2
function  interseption(F, J, Ray, t)
    #X0 = T
    # G_D(X) = ray.direction .* J(X) #funkcija odvoda
    ray(k) = Ray.origin + k*Ray.direction
    G_D(X) = dot(Ray.direction,J(ray(t))) #funkcija odvoda
    result = newton(F, G_D, Ray, t)
    return result
end

#SHADING MODELS

function lambert_shading(normal, lightDirection, color)
    n = normalize(normal)
    l = normalize(lightDirection)

    if any(isnan.(n)) || any(isnan.(l))
        return RGB{N0f8}(0.0, 0.0, 0.0)  # črna kot fallback, ce se kak vektor pokvari
    end

    intensity = clamp(dot(n, l), 0.0, 1.0)
    c = RGB{Float64}(color)
    scaled_color = intensity * c
    return RGB{N0f8}(scaled_color)
end

function Phong_shading(light, ray_ref, p)
    l = normalize(light)
    rf = normalize(ray_ref)

    if any(isnan.(rf)) || any(isnan.(l))
        return RGB{N0f8}(0.0, 0.0, 0.0)  # črna kot fallback, ce se kak vektor pokvari
    end

    intensity = clamp((max(dot(rf, l), 0))^p, 0.0, 1.0) #p pomeni stopnjo refleksivnosti pri 1 bo bela lisa največja pri 256 najmanjša
    return RGB{N0f8}(intensity, intensity, intensity) #samo črno/belo 
end

function shadingCombined(reflected, normal, lightDirection, color, p)
    lambert = lambert_shading(normal, lightDirection, color)
    phong = Phong_shading(lightDirection, reflected, p)
    sum = RGB{Float64}(lambert) + RGB{Float64}(phong)  #kombinacija
    color = RGB{N0f8}(RGB(clamp01.(sum)))
    return color
end

function v_senci(point, light_pos, objects)
    dir = normalize(light_pos .- point)
    light_dist = norm(light_pos - point)
    shadow_ray = Ray(point .+ 1e-4 * dir, dir)

    for obj in objects
        # zacnes malo stran, da preskocis lasten objekt
        t0 = 1.0
        result = interseption(obj.F, obj.J, shadow_ray, t0)
        if result.t > 0 && result.t < light_dist  # intersekcija pred svetlobnim virom
            return true
        end
    end

    return false
end


 

#raytrace function no ray bouncing 
function raytrace(Ray, objects, Camera, light_source)
    t1 = 0
    t2 = 0
    ray(t) = Ray.origin + t*Ray.direction #funkcija za racunanje zarka
    values = [sign(s.F(ray(t1))) for s in objects]
    T = [0;0;0] #inicialzacije tocke za interseption
    while t2 <= 50
        t2 += 0.1 #incremention of t
        r = ray(t2)
        for i in eachindex(objects)
            if values[i] != sign(objects[i].F(r)) #sprememba predznaka
                t = (t1 + t2) / 2
                (t, num) = interseption(objects[i].F, objects[i].J, Ray, t) #ray(t) = približek točke
                T = ray(t)
                n = normalize(objects[i].J(T))
                #zaradi ravnnin ce normala kaze v smeri zarka
                if dot(n, Ray.direction) > 0
                    n = -n
                end

                v = normalize(Ray.direction)
                r2 = v - 2*(dot(v,n)/dot(n,n))*n # r2 = reflected ray 
                L = normalize(light_source .- T)  # smer od točke trka proti luči


                

                #return lambert_shading(n, L, objects[i].color)
                #return Phong_shading(L, r2, 8) #second problem solution (p must be 1)
                #return shadingCombined(r2, n, L, objects[i].color, 32) #second problem solution
                #return RGB{N0f8}(0, 1, 0) # crna

                if v_senci(T, light_source, objects)
                    # arbitrarno - 0.1 bo bolj temno, 0.3 bolj svetlo
                    ambient = 0.1
                    c = RGB{Float64}(objects[i].color)
                    scaled = ambient * c
                    return RGB{N0f8}(scaled)
                else
                    return shadingCombined(r2, n, L, objects[i].color, 32)
                end 
               
                break;
            end
        end
        t1 = t2
    end
    return RGB{N0f8}(0,0, 0) # crna
end




