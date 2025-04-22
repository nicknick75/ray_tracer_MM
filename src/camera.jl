using LinearAlgebra

#= 
    Kamera definira: iz kod zarki izvirajo, v katero smer gledamo, kak velik (pa kje)
    je image plane 
=#

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

function generate_ray(cam::Camera, i::Int, j::Int) 

    x = cam.lm + (cam.dm - cam.lm) * (i + 0.5) / cam.nx #izracunas x in y koord piksla
    y = cam.sm + (cam.zm - cam.sm) * (j + 0.5) / cam.ny #0.5, da gres skozi sredino piksla 
    
    #generacija zarka iz pozicije
    pixelPosition = cam.p .+ cam.d .* cam.w .+ x .* cam.x .+ y .* cam.y #koordinata piksla v 3D prostoru
    direction = pixelPosition .- cam.p
    direction = direction ./ norm(direction) #normed za lazji izracun

    return Ray(cam.p, direction)
end    
