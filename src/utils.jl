#nevem kam tocno dati lahko kopirava v druge datoteke
using ColorTypes, LinearAlgebra
#= 
    Po debagiranju zgleda takole ampak pomoje je se zmeraj nekaj narobe ker bi sfera morala biti osencena povsod ampak
    vsaj narise krog tko da nek intersepciton ze dela
=#

#newton funkcija iz vaj 
function newton(F, JF, X0; tol = 1e-8, maxit = 100)
    # set two variables which will be used (also) outside the for loop
    X = X0
    n = 1
    # first evaluation of F
    # Y = F(X)
    for outer n = 1:maxit
        Y = F(X)
        grad = JF(X)
        # execute one step of Newton's iteration
        X = X .- (grad \ Y)
        # Y = F(X)
        # check if the result is within prescribed tolerance
        #if norm(X-X0) + norm(Y) < tol
        if norm(Y) < tol #spustimo clen Y
            break;
        end
        # otherwise repeat
        # X0 = X
    end

    # a warning if maxit was reached
    # if n == maxit
    #     @warn "no convergence after $maxit iterations"
    # end
    # let's return a named tuple
    return (X = X, n = n)
end

#intersection 
# t = (t1 + t2)/ 2
function  interseption(F, J, ray, T)
    #X0 = T
    # G_D(X) = ray.direction .* J(X) #funkcija odvoda
    G_D(X) = dot(ray.direction,J(X)) #funkcija odvoda
    T1 = newton(F, G_D, T).X
    return T1
end

#=nevem ce dela cist prov
function colorCos1(normal, v)
    angle = acos(dot(normal,v)/(norm(normal)*norm(v)))
    value = abs(angle/(pi))
    return RGB{N0f8}(value, value, value)
end=#

function lambert_shading(normal, lightDirection)
    intensity = clamp(dot(normalize(normal), normalize(lightDirection)), 0.0, 1.0)
    return RGB{N0f8}(intensity, intensity, intensity)
end


#objects = [s,r] --> s = Sphere(...) ,...

#values = [s.f(ray(0)), ...]7
#sing(x) --> -1 if x <0 0 if x === 0 1 if x > 0
function raytrace(Ray, objects)
    t1 = 0
    t2 = 0
    ray(t) = Ray.origin + t*Ray.direction #funkcija za racunanje zarka
    values = [sign(s.F(ray(t1))) for s in objects]
    T = [0;0;0] #inicialzacije tocke za interseption
    while t2 < 10
        t2 += 0.1 #incremention of t
        r = ray(t2)
        for i in eachindex(objects)
            if values[i] != sign(objects[i].F(r)) #sprememba predznaka
                t = (t1 + t2) / 2
                T = interseption(objects[i].F, objects[i].J, Ray, ray(t)) #ray(t) = približek točke
                #color funkcija
                N = objects[i].J(T)
                n = normalize([N[1], N[2], N[3]])
                p = r - 2*(dot(r,n)/dot(n,n))*n # p = reflected ray
                
                light = cam.p #luc iz kamere
                L = normalize(light .- T)  # smer od točke trka proti luči
                return lambert_shading(n, L)

                
                #return colorCos1(n, normalize(p))

                # return RGB{N0f8}(0, 0, 0) # crna
                break; #trenutno se ne odbije in samo obarva crno ce zadane objekt
            end
        end
        t1 = t2
    end
    return RGB{N0f8}(0,0, 0) # bela
end




