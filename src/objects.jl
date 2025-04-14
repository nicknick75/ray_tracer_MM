abstract type Object end
struct Ray
    origin::Vector{Float64}
    direction::Vector{Float64}
end



#sfera, ravnina, torus
#ravnina
struct Plane <: Object
    a::Float64
    b::Float64
    c::Float64
    d::Float64
    shine::Float64
    color::RGB{N0f8}
    F::Function
    J::Function
end

function Plane(a, b, c, d, shine, color)
    F(X) = a*X[1] + b*X[2] + c*X[3] - d
    J(X) = [a, b, c]
    return Plane(a, b, c, d, shine, color, F, J)
end

struct Sphere <: Object
    a::Float64
    b::Float64
    c::Float64
    r::Float64
    shine::Float64
    color::RGB{N0f8}
    F::Function
    J::Function
end

#sfera 
function Sphere(a, b, c, r, shine, color)
    F(X) = (X[1] - a)^2 + (X[2] - b)^2 + (X[3] - c)^2 - r^2
    J(X) = [2*(X[1] - a), 2*(X[2] - b), 2*(X[3] - c)]
    return Sphere(a, b, c, r, shine, color, F, J)
end


#torus 
struct Torus <: Object
    R::Float64       
    r::Float64       
    center::Vector{Float64}
    shine::Float64
    color::RGB{N0f8}
    F::Function
    J::Function
end

# f(x, y, z) = (x^2 + y^2 + z^2 + R^2 - r^2)^2 - 4 * R^2 * (x^2 + y^2)
function Torus(R, r, center, shine, color)
    cx, cy, cz = center
    F(X) = begin
        x, y, z = X[1] - cx, X[2] - cy, X[3] - cz
        s = x^2 + y^2 + z^2 + R^2 - r^2
        s^2 - 4*R^2*(x^2 + y^2)
    end
    J(X) = begin
        x, y, z = X[1] - cx, X[2] - cy, X[3] - cz
        s = x^2 + y^2 + z^2 + R^2 - r^2
        fx = 4*s*2x - 8*R^2*2x
        fy = 4*s*2y - 8*R^2*2y
        fz = 4*s*2z
        [fx, fy, fz]
    end
    return Torus(R, r, center, shine, color, F, J)
end


function Torus_side(R, r, center, color)
    cx, cy, cz = center
    F(X) = begin
        x, y, z = X[1] - cx, X[2] - cy, X[3] - cz
        s = x^2 + y^2 + z^2 + R^2 - r^2
        s^2 - 4 * R^2 * (z^2 + y^2)  #da je luknja v x
    end
    J(X) = begin
        x, y, z = X[1] - cx, X[2] - cy, X[3] - cz
        s = x^2 + y^2 + z^2 + R^2 - r^2
        fx = 8 * x * s
        fy = 8 * y * s - 8 * R^2 * y
        fz = 8 * z * s - 8 * R^2 * z
        [fx, fy, fz]
    end
    return Torus(R, r, center, shine, color, F, J)
end

struct Ellipsoid <: Object
    a::Float64
    b::Float64
    c::Float64
    rx::Float64
    ry::Float64
    rz::Float64
    shine::Float64
    color::RGB{N0f8}
    F::Function
    J::Function
end

function Ellipsoid(a, b, c, rx, ry, rz, shine, color)
    F(X) = ((X[1] - a)/rx)^2 + ((X[2] - b)/ry)^2 + ((X[3] - c)/rz)^2 - 1
    J(X) = [
        2*(X[1] - a)/(rx^2),
        2*(X[2] - b)/(ry^2),
        2*(X[3] - c)/(rz^2)
    ]
    return Ellipsoid(a, b, c, rx, ry, rz, shine, color, F, J)
end

#za u(x,y) = x^2sin(y)
struct GraphOfFunction <: Object
    u::Function
    shine::Float64
    color::RGB{N0f8}
    F::Function
    J::Function
end

function GraphOfFunction(u, shine, color)
    F(X) = begin
        x, y = X[1], X[2]
        if !isfinite(x) || !isfinite(y)
            return Inf 
        end
        return X[3] - u(x, y)
    end

    J(X) = begin
        x, y = X[1], X[2]
        if !isfinite(x) || !isfinite(y)
            return [0.0, 0.0, 1.0]  # arbitrarna
        end
        # du/dx = 2x * sin(y), du/dy = x^2 * cos(y)
        return [
            -2 * x * sin(y),
            -x^2 * cos(y),
             1.0
        ]
    end
    return GraphOfFunction(u, shine, color, F, J)
end
