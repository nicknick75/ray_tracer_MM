using ColorTypes, LinearAlgebra
include("utils.jl")  


function refract(incoming, N, n1, n2)
    incoming = normalize(incoming)
    N = normalize(N)
    eta = n1 / n2 #snell's zakon
    cos_i = -dot(N, incoming)
    sin2_t = eta^2 * (1.0 - cos_i^2)

    if sin2_t > 1.0
        return nothing  #totalno interno
    end

    cos_t = sqrt(1.0 - sin2_t)
    T = eta * incoming + (eta * cos_i - cos_t) * N
    return normalize(T)
end
 

#raytrayce z reflection in refraction opcijo
function ref_raf_raytrace(ray_obj, objects, Camera, light_source, ambient; max_inc = 50, depth = 2)
    t1 = 0
    t2 = 0
    ray(t) = ray_obj.origin + t*ray_obj.direction #funkcija za racunanje zarka
    values = [sign(s.F(ray(t1))) for s in objects]
    T = [0,0,0] #inicialzacije tocke za interseption
    while t2 <= max_inc
        t2 += 0.05 #incremention of t
        r = ray(t2)
        for i in eachindex(objects)
            if values[i] != sign(objects[i].F(r)) #sprememba predznaka
                t = (t1 + t2) / 2
                (t, num) = interseption(objects[i].F, objects[i].J, ray_obj, t) #ray(t) = približek točke
                T = ray(t)
                n = normalize(objects[i].J(T))
                #zaradi ravnnin ce normala kaze v smeri zarka
                if dot(n, ray_obj.direction) > 0
                    n = -n
                end

                v = normalize(ray_obj.direction)
                r2 = v - 2*(dot(v,n)/dot(n,n))*n # r2 = reflected ray 
                L = normalize(light_source .- T)  # smer od točke trka proti luči

                
                if v_senci(T, light_source, objects)
                    # samo ambient komponenta brez direktne svetlobe
                    direct = RGB{N0f8}(ambient * RGB{Float64}(objects[i].color))
                else
                    direct = shadingCombined(r2, n, L, objects[i].color, objects[i].shine, ambient)
                    lambert = lambert_shading(n,L, objects[i].color) #za shiny predmete 
                end

                shiny = Phong_shading(L, r2, objects[i].shine) #nevem kam točno dati amapk če ni shine bo to itak 0.0.0

                # ce je shiny + imas ray depth
                is_reflective = objects[i].shine > 0.5 && depth > 0
                # refraction?
                is_transparent = objects[i].transparent && depth > 0

                reflected_color = RGB{N0f8}(0, 0, 0)
                refracted_color = RGB{N0f8}(0, 0, 0)

                if is_reflective
                    reflected_ray = Ray(T .+ 1e-4 * r2, r2)
                    reflected_color = ref_raf_raytrace(reflected_ray, objects, Camera, light_source, ambient; max_inc=max_inc, depth=depth - 1)
                end

                if is_transparent
                    n1 = 1.0  # zrak
                    n2 = objects[i].refraction
                    refracted_dir = refract(-v, n, n1, n2)

                    if refracted_dir !== nothing
                        refracted_ray = Ray(T .+ 1e-4 * refracted_dir, refracted_dir)
                        refracted_color = ref_raf_raytrace(refracted_ray, objects, Camera, light_source, ambient; max_inc=max_inc, depth=depth - 1)
                    end
                end

                # kombiniraj scenarije
                if is_reflective && is_transparent
                    # combined = 0.4 * RGB{Float64}(direct) + 0.3 * RGB{Float64}(reflected_color) + 0.3 * RGB{Float64}(refracted_color)
                    combined = 0.4 * RGB{Float64}(lambert) + 0.3 * RGB{Float64}(reflected_color) + 0.3 * RGB{Float64}(refracted_color) + RGB{Float64}(shiny)
                    return RGB{N0f8}(clamp01.(combined))
                elseif is_reflective
                    # combined = 0.5 * RGB{Float64}(direct) + 0.5 * RGB{Float64}(reflected_color) prejsna verzija
                    combined = 0.5 * RGB{Float64}(lambert) + 0.5 * RGB{Float64}(reflected_color) + RGB{Float64}(shiny)
                    return RGB{N0f8}(clamp01.(combined))
                elseif is_transparent
                    combined = 0.5 * RGB{Float64}(direct) + 0.5 * RGB{Float64}(refracted_color)
                    return RGB{N0f8}(clamp01.(combined))
                else
                    return direct
                end
            end
        end
        t1 = t2
    end
    return RGB{N0f8}(0,0, 0) # crna
end
