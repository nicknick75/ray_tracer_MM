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
function  interseption(F, J, ray, t)
    X0 = Ray(t)
    G_D(X) = Ray.direction * J(X)
    T = newton(F, G_D, X0).X
end

#objects = [s,r] --> s = Sphere(...) ,...

#values = [s.f(ray(0)), ...]7
#sing(x) --> -1 if x <0 0 if x === 0 1 if x > 0
function raytrace(Ray, objects)
    t1, t2 = 0
    values = [sign(s.f(ray(t))) for s in objects]
    T = [0;0;0] #inicialzacije tocke za interseption
    while t < 100
        t2 += 0.5 #incremention of t
        r = ray(t2)
        for i in eachindex(objects)
            if values[i] != sing(objects[i].f(r)) #sprememba predznaka
                t = (t1 + t2) / 2
                T = interseption(objects[i].f, objects[i].j, ray, t)
                #color funkcija
                return RGB{N0f8}(0, 0, 0) # crna
                break; #trenutno se ne odbije in samo obarva crno ce zadane objekt
            end
        end
        t1 = t2
    end
    return RGB{N0f8}(1, 1, 1) # bela
end

