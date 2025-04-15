using ColorTypes, LinearAlgebra

include("utils.jl")  

function pathtrace(ray, objects, depth, ambient, bounce_weight; max_inc=50)
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

                # to je direktna svetloba
                # light_dir = normalize(light .- hit_point)
                # in_shadow = v_senci(hit_point, light, objects)
                if(objects[i].light_source)
                    light =RGB{N0f8}(1,1,1) 
                    return  #zabije v luč
                end
                base_color = RGB{Float64}(objects[i].color)

                #če smo v senci - ambienta svetloba
                # if in_shadow
                #     direct_color = ambient * base_color
                # else
                #     direct_color = RGB{Float64}(lambert_shading(normal, light_dir, objects[i].color))
                # end

                # mogoče narediva več slik različnih random npr. noramlna porazdelitev monte carlo
                # nakljucna smer odbitega žarka (approx cosine-weighted)  
                rand_dir = normalize(normal + randn(3))
                #@show rand_dir
                new_ray = Ray(hit_point + 1e-4 * rand_dir, rand_dir)

                # cos = clamp(dot(new_ray.direction,normal), 0.0, 1.0)
                # if isnan(cos)
                #     cos = 0.0
                # end
                # @show cos

                indirect_color = RGB{Float64}(pathtrace(new_ray,objects, depth - 1, ambient, bounce_weight; max_inc=max_inc))
                
                #ndirect_color = RGB{Float64}(pathtrace(new_ray, objects, light, depth - 1, ambient, bounce_weight; max_inc=max_inc))
                #final_color = RGB{Float64}(base_color.r+indirect_color.r*cos/pi, base_color.g+indirect_color.g*cos/pi, base_color.b+indirect_color.b*cos/pi)
                final_color = RGB{Float64}(base_color.r*indirect_color.r, base_color.g*indirect_color.g, base_color.b*indirect_color.b)
                #final_color = direct_color + bounce_weight * indirect_color
                
                #return RGB{N0f8}(clamp01.(color)); #črno bela slika
                #return RGB{N0f8}(clamp01.(final_color))
            end
        end
        t1 = t2
    end

    return RGB{N0f8}(0.0, 0.0, 0.0)  # No intersection → black
end
