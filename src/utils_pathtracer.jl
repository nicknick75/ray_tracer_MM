using ColorTypes, LinearAlgebra

include("utils.jl")  

function pathtrace(ray, objects, depth, ambient; max_inc=50)
    if depth == 0
        return RGB{N0f8}(0.0, 0.0, 0.0)  # Base case: crna
    end

    t1 = 0.0
    t2 = 0.0
    rayfn(t) = ray.origin + t * ray.direction
    values = [sign(o.F(rayfn(t1))) for o in objects]

    while t2 <= max_inc
        t2 += 0.1
        r = rayfn(t2)

        for i in eachindex(objects)
            if values[i] != sign(objects[i].F(r))
                t = (t1 + t2) / 2
                (t, _) = interseption(objects[i].F, objects[i].J, ray, t)
                hit_point = rayfn(t)
                normal = normalize(objects[i].J(hit_point))

                if dot(normal, ray.direction) > 0
                    normal = -normal
                end

                #hits the light
                if(objects[i].light_source)
                    light = RGB{N0f8}(1,1,1) 
                    return  light;
                end
                base_color = RGB{Float64}(objects[i].color)

                # nakljucna smer odbitega žarka (approx cosine-weighted)  
                rand_dir = normalize(normal + randn(3))
                new_ray = Ray(hit_point + 1e-4 * rand_dir, rand_dir)

                cos = clamp(dot(new_ray.direction,normal), 0.0, 1.0)
                if isnan(cos)
                    cos = 0.0
                end

                indirect_color = RGB{Float64}(pathtrace(new_ray,objects, depth - 1, ambient; max_inc=max_inc))
                
                #final_color = RGB{Float64}(base_color.r*indirect_color.r*cos, base_color.g*indirect_color.g*cos, base_color.b*indirect_color.b*cos)
                return RGB{N0f8}(clamp01.(indirect_color)); #črno bela slika
                #return RGB{N0f8}(clamp01.(final_color))
            end
        end
        t1 = t2
    end

    return RGB{N0f8}(0.0, 0.0, 0.0)  # No intersection → black
end
