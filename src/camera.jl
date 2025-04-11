
struct Camera
    p::Vector{Float64}      # pozicija 
    x::Vector{Float64}      # x os 
    y::Vector{Float64}      # y os
    w::Vector{Float64}      # smer 
    lm::Float64             # leva, desna, spoddnja, zgornja meja slike
    dm::Float64              
    sm::Float64              
    zm::Float64             
    d::Float64              # focal length
    nx::Int                 # width (piksl)
    ny::Int                 # height(piks)
end
