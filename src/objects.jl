
#sfera, ravnina, torus
#ravnina
struct Plane
    a::Float64
    b::Float64
    c::Float64
    d::Float64
    F::Function
    J::Function
end

function Plane(a, b, c, d)
    F(X) = a*X[1] + b*X[2] + c*X[3] - d
    J(X) = [a, b, c]
    return Plane(a, b, c, d, F, J)
end

struct Sphere
    a::Float64
    b::Float64
    c::Float64
    r::Float64
    F::Function
    J::Function
end

#sfera 
function Sphere(a, b, c, r)
    F(X) = (X[1] - a)^2 + (X[2] - b)^2 + (X[3] - c)^2 - r^2
    J(X) = [2*X[1], 2*X[2], 2*X[3]]
    return Sphere(a, b, c, r, F, J)
end

# struct Torus
#     f::Function
#     J::Function
# end

# function Torus()
    
# end