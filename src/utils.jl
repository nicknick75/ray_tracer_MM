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

#nevem ce dela cist prov
# function colorCos1(normal, v)
#     cosinus = max(0,dot(normal,v))
#     d = 1 * cosinus
#     return RGB{N0f8}(d, d, d)
# end

function lambert_shading(normal, lightDirection)
    intensity = clamp(dot(normalize(normal), normalize(lightDirection)), 0.0, 1.0)
    return RGB{N0f8}(intensity, intensity, intensity)
end



#objects = [s,r] --> s = Sphere(...) ,...

#values = [s.f(ray(0)), ...]7
#sing(x) --> -1 if x <0 0 if x === 0 1 if x > 0
function raytrace(Ray, objects, Camera)
    t1 = 0
    t2 = 0
    ray(t) = Ray.origin + t*Ray.direction #funkcija za racunanje zarka
    values = [sign(s.F(ray(t1))) for s in objects]
    T = [0;0;0] #inicialzacije tocke za interseption
    while t2 <= 5
        t2 += 0.5 #incremention of t
        r = ray(t2)
        for i in eachindex(objects)
            if values[i] != sign(objects[i].F(r)) #sprememba predznaka
                t = (t1 + t2) / 2
                (t, num) = interseption(objects[i].F, objects[i].J, Ray, t) #ray(t) = približek točke
                #color funkcija
                T = ray(t)
                N = objects[i].J(T)
                n = normalize(N)
                r2 = r - 2*(dot(r,n)/dot(n,n))*n # r2 = reflected ray
                
                light = Camera.p #luc iz kamere
                L = normalize(light .- T)  # smer od točke trka proti luči
                return lambert_shading(n, L)
                #return lambert_shading(r2, L)                
                #return colorCos1(n, normalize(p))
                #return RGB{N0f8}(1, 1, 1) # crna
                break; #trenutno se ne odbije in samo obarva crno ce zadane objekt
            end
        end
        t1 = t2
    end
    return RGB{N0f8}(0,0, 0) # crna
end




