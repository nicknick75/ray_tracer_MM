using ColorTypes, LinearAlgebra

include("utils.jl")
 
#depth je kolkokrat se zarek odbije, preden ga ubijes
function pathtrace(ray, objects, light, depth) #
    if depth == 0
        return RGB{N0f8}(0.0, 0.0, 0.0) #base case črna
    end
    t1 = 0
    t2 = 0
    rayfn(t) = ray.origin + t * ray.direction #funkcija za racunanje zarka
    values = [sign(o.F(rayfn(t1))) for o in objects]

    while t2 <= 50
        t2 += 0.1
        r = rayfn(t2)
        for i in eachindex(objects)
            if values[i] != sign(objects[i].F(r))
                t = (t1 + t2)/2
                (t, num) = interseption(objects[i].F, objects[i].J, ray, t)
                hitPoint = rayfn(t)
                n = normalize(objects[i].J(hitPoint))
                 #zaradi ravnnin ce normala kaze v smeri zarka
                if dot(n, ray.direction) > 0
                    n = -n
                end

                #manjka mi senca pa lokalen shading

               

                indirect_color = pathtrace(new_ray, objects, light, depth - 1) #rekurzivni klic, vsakic 
                                                                                #manjsa globina

                # vracas kombo direkt + indirektne svetlobe
                #c = RGB{Float64}(direct_color) + konst * RGB{Float64}(indirect_color)?
                return RGB{N0f8}(clamp.(c))
            end
        end
        t1 = t2
    end

    return RGB{N0f8}(0.0, 0.0, 0.0)
end

