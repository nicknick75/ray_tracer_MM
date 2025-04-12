#nevem kam tocno dati lahko kopirava v druge datoteke
using ColorTypes, LinearAlgebra
#= 
    Okej to je zaenkrat tako napol psevdokoda ker nevem se tocno kako bo zgledal ray ko bo sel iz kamere.
    Ampak v teoriji bi lahko delal. Moja ideja je da v raytrace funkcijo das listo objektov in pa ray, ta pa ti
    vrne barvo piksla. Zaenkrat bo samo pobarvala na črno če je zadela objekt in belo če ga ni (v teoriji). Potem 
    ko bova imele kamero pa to bom debugirala ker verjetno bo imela pol errorjev. 
=#

#newton funkcija iz vaj 
function newton(F, JF, X0; tol = 1e-8, maxit = 100)
    # set two variables which will be used (also) outside the for loop
    X = X0
    n = 1
    # first evaluation of F
    Y = F(X)
    for outer n = 1:maxit
        # execute one step of Newton's iteration
        X = X0 - JF(X0)\Y
        Y = F(X)
        # check if the result is within prescribed tolerance
        #if norm(X-X0) + norm(Y) < tol
        if norm(X-X0) < tol #spustimo clen Y
            break;
        end
        # otherwise repeat
        X0 = X
    end

    # a warning if maxit was reached
    if n == maxit
        @warn "no convergence after $maxit iterations"
    end
    # let's return a named tuple
    return (X = X, n = n)
end

#intersection 
# t = (t1 + t2)/ 2
function  interseption(F, J, ray, T)
    #X0 = T
    G_D(X) = ray.direction * J(X) #funkcija odvoda
    T1 = newton(F, G_D, T).X
    return T1
end

# function colorCos1()

# end

#objects = [s,r] --> s = Sphere(...) ,...

#values = [s.f(ray(0)), ...]7
#sing(x) --> -1 if x <0 0 if x === 0 1 if x > 0
function raytrace(Ray, objects)
    t1, t2 = 0
    ray(t) = Ray.origin + t*Ray.direction #funkcija za racunanje zarka
    values = [sign(s.f(ray(t1))) for s in objects]
    T = [0;0;0] #inicialzacije tocke za interseption
    while t < 100
        t2 += 0.5 #incremention of t
        r = ray(t2)
        for i in eachindex(objects)
            if values[i] != sing(objects[i].f(r)) #sprememba predznaka
                t = (t1 + t2) / 2
                T = interseption(objects[i].f, objects[i].j, Ray, ray(t)) #ray(t) = približek točke
                #color funkcija
                # N = objects[i].J(T)
                # n = [N[1], N[2], N[3]]'
                # p = r - 2*(dot(r,n)/dot(n,n))*n # p = reflected ray
                
                return RGB{N0f8}(0, 0, 0) # crna
                break; #trenutno se ne odbije in samo obarva crno ce zadane objekt
            end
        end
        t1 = t2
    end
    return RGB{N0f8}(1, 1, 1) # bela
end




