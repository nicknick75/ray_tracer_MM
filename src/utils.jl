using ColorTypes, LinearAlgebra

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
        if norm(t-t0) < tol #drop Y
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
    ray(k) = Ray.origin + k*Ray.direction
    G_D(X) = dot(Ray.direction,J(ray(t))) #derivative
    result = newton(F, G_D, Ray, t)
    return result
end

#SHADING MODELS

function lambert_shading(normal, lightDirection, color)
    n = normalize(normal)
    l = normalize(lightDirection)

    if any(isnan.(n)) || any(isnan.(l))
        return RGB{N0f8}(0.0, 0.0, 0.0)  # black fallback
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
        return RGB{N0f8}(0.0, 0.0, 0.0)  # black fallback
    end

    intensity = clamp((max(dot(rf, l), 0))^p, 0.0, 1.0) #p is reflection point at 1 bo bela lisa največja, pri 256 najmanjša
    return RGB{N0f8}(intensity, intensity, intensity) #samo črno/belo 
end

function shadingCombined(reflected, normal, lightDirection, color, p, ambient)
    lambert = lambert_shading(normal, lightDirection, color)
    c = RGB{Float64}(color)
    scaled = ambient * c

    phong = Phong_shading(lightDirection, reflected, p)
    if (p < 1.0) 
        phong = RGB{N0f8}(0,0,0) #if object isn't shiny
    end
    sum = RGB{Float64}(scaled) + RGB{Float64}(lambert) + RGB{Float64}(phong)  #combo
    color = RGB{N0f8}(RGB(clamp01.(sum)))
    return color
end

function v_senci(point, light_pos, objects)
    dir = normalize(light_pos .- point)
    light_dist = norm(light_pos .- point)
    shadow_ray = Ray(point .+ 1e-4 * dir, dir)
    t = 0
    ray(t) = shadow_ray.origin + t*shadow_ray.direction #shadow_ray at time t
    values = [sign(s.F(ray(t))) for s in objects]
    while t <= light_dist 
        t += 0.1
        r = ray(t)
        for i in eachindex(objects)
            if values[i] != sign(objects[i].F(r))
                return true 
            end
        end
    end
    return false
end

#raytrace function no ray bouncing 
function raytrace(Ray, objects, Camera, light_source, ambient; max_inc = 50)
    t1 = 0
    t2 = 0
    ray(t) = Ray.origin + t*Ray.direction #calculating ray
    values = [sign(s.F(ray(t1))) for s in objects]
    T = [0,0,0] #init interception point
    while t2 <= max_inc
        t2 += 0.05 #incremention of t
        r = ray(t2)
        for i in eachindex(objects)
            if values[i] != sign(objects[i].F(r)) #sign change
                t = (t1 + t2) / 2
                (t, num) = interseption(objects[i].F, objects[i].J, Ray, t) #ray(t) = approx
                T = ray(t)
                n = normalize(objects[i].J(T))
                #if normal is in ray dir
                if dot(n, Ray.direction) > 0
                    n = -n
                end

                v = normalize(Ray.direction)
                r2 = v - 2*(dot(v,n)/dot(n,n))*n # r2 = reflected ray 
                L = normalize(light_source .- T)  # from collision to light

                if v_senci(T, light_source, objects)
    
                    c = RGB{Float64}(objects[i].color)
                    scaled = ambient * c
                    return RGB{N0f8}(scaled)
                else
                    return shadingCombined(r2, n, L, objects[i].color, objects[i].shine, ambient)
                end 
                #ALTERNATIVES
                #return lambert_shading(n, L, objects[i].color)
                #return lambert_shading(r2, L, objects[i].color)
                #return Phong_shading(L, r2, 8) #second problem solution (p must be 1)
                #return shadingCombined(r2, n, L, objects[i].color, objects[i].shine)
                #return RGB{N0f8}(0, 1, 0) # black

                break;
            end
        end
        t1 = t2
    end
    return RGB{N0f8}(0,0, 0) # black
end
