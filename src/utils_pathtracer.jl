using ColorTypes, LinearAlgebra

include("utils.jl")  

function pathtrace(ray, objects, light, depth, ambient, bounce_weight)
    if depth == 0
        return RGB{N0f8}(0.0, 0.0, 0.0)  # Base case: crna
    end

    t1 = 0.0
    t2 = 0.0
    rayfn(t) = ray.origin + t * ray.direction
    values = [sign(o.F(rayfn(t1))) for o in objects]

    while t2 <= 50
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
                light_dir = normalize(light .- hit_point)
                in_shadow = v_senci(hit_point, light, objects)

                base_color = RGB{Float64}(objects[i].color)

                #če smo v senci - ambienta svetloba
                if in_shadow
                    direct_color = ambient * base_color
                else
                    direct_color = RGB{Float64}(lambert_shading(normal, light_dir, objects[i].color))
                end

                # nakljucna smer odbitega žarka (approx cosine-weighted)
                rand_dir = normalize(normal + randn(3))
                new_ray = Ray(hit_point + 1e-4 * rand_dir, rand_dir)

                    #= namesto random, reflectas
                if objects[i].shine > 0.9
                    reflect_dir = normalize(ray.direction - 2 * dot(ray.direction, normal) * normal)
                    new_ray = Ray(hit_point + 1e-4 * reflect_dir, reflect_dir)
                else
                    rand_dir = normalize(normal + randn(3))
                    new_ray = Ray(hit_point + 1e-4 * rand_dir, rand_dir)
                end=#
                

                indirect_color = RGB{Float64}(pathtrace(new_ray, objects, light, depth - 1, ambient, bounce_weight)
)

                final_color = direct_color + bounce_weight * indirect_color

                return RGB{N0f8}(clamp01.(final_color))
            end
        end
        t1 = t2
    end

    return RGB{N0f8}(0.0, 0.0, 0.0)  # No intersection → black
end
