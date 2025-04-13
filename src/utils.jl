#nevem kam tocno dati lahko kopirava v druge datoteke
using ColorTypes, LinearAlgebra
#= 
    Po debagiranju zgleda takole ampak pomoje je se zmeraj nekaj narobe ker bi sfera morala biti osencena povsod ampak
    vsaj narise krog tko da nek intersepciton ze dela
=#

#newton funkcija iz vaj 
function newton(F, JF, Ray, t0; tol = 1e-8, maxit = 100)
    # set two variables which will be used (also) outside the for loop
    ray(k) = Ray.origin + k*Ray.direction
    t = t0
    n = 1
    # first evaluation of F
    # Y = F(X)
    Y = F(ray(t))
    #println(Y)
    for outer n = 1:maxit    
        t = t0 - JF(t0)\Y
        Y = F(ray(t))
        # check if the result is within prescribed tolerance
        #if norm(X-X0) + norm(Y) < tol
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


#=function lambert_shading(normal, lightDirection, color)
    intensity = clamp(dot(normalize(normal), normalize(lightDirection)), 0.0, 1.0)
    c = RGB{Float64}(color);
    scaled_color = intensity * c
    return RGB{N0f8}(scaled_color)
end =#


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


function v_senci(point, light_pos, objects)
    dir = normalize(light_pos .- point) #smer svetlobe
    shadow_ray = Ray(point .+ 1e-4 * dir, dir) #majhen premik, da ne trcis z isto

    # pogledas za vse obj, ce so na poti
    for obj in objects
        t1 = 0.0 #zac in konec                
        t2 = 0.0                
        
        while t2 < norm(light_pos - point)
            t2 += 0.1
            # tocki na zarku
            p1 = shadow_ray.origin + t1 * shadow_ray.direction
            p2 = shadow_ray.origin + t2 * shadow_ray.direction
            # objekt preseka žarek med p1 in p2? senca
            if sign(obj.F(p1)) != sign(obj.F(p2))
                return true
            end
            t1 = t2
        end
    end
    return false
end 



#objects = [s,r] --> s = Sphere(...) ,...

#values = [s.f(ray(0)), ...]7
#sing(x) --> -1 if x <0 0 if x === 0 1 if x > 0
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
                #color funkcija
                T = ray(t)
                n = normalize(objects[i].J(T))
                #zaradi ravnnin ce normala kaze v smeri zarka
                if dot(n, Ray.direction) > 0
                    n = -n
                end
                v = normalize(Ray.direction)
                r2 = v - 2*(dot(v,n)/dot(n,n))*n # r2 = reflected ray 
                L = normalize(light_source .- T)  # smer od točke trka proti luči
                rL = normalize(-L - 2*(dot((-L),n)/dot(n,n))*n)


                #=ne deluje se cist prav, celo stvar zatemni
                    pomojem sem premajhen offset nastavila in zaznava senco povsod
                
                if v_senci(T, light_source, objects)
                    # ambientni del - temneje
                    ambient = 0.2
                    c = RGB{Float64}(objects[i].color)
                    scaled = ambient * c
                    return RGB{N0f8}(scaled)
                else
                    return lambert_shading(n, L, objects[i].color)
                end =#

                return lambert_shading(n, L, objects[i].color)
                #return lambert_shading(r2, L, objects[i].color)
                #return RGB{N0f8}(0, 1, 0) # crna

                break;
            end
        end
        t1 = t2
    end
    return RGB{N0f8}(1,1, 1) # crna
end




