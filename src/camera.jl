using LinearAlgebra

#= 
    Kamera definira: s kod zarki ivirajo, v katero smer se piksli vidijo, kak velik (pa kje)
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

#smiselno met neko funkcijo, ki bi generirala zarek na dolocenem pikslu

function generate_ray(cam::Camera, i::Int, j::Int) #::Ray - ker vraca ray?

    x = cam.lm + (cam.dm - cam.lm) * (i + 0.5) / cam.nx #zracunas x in y koord piksla
    y = cam.sm + (cam.zm - cam.sm) * (j + 0.5) / cam.ny #0.5, da gres skoz sredino piksla 
                                                        #nisem 100%, da je to potrebno
    
    #generacija zarka iz pozicije
    pixelPosition = cam.p .+ cam.d .* cam.w .+ x .* cam.x .+ y .* cam.y #koordinata piksla v 3D prostoru
    direction = pixelPosition .- cam.p
    direction = direction ./ norm(direction) #normed za lazji izracun

    return Ray(cam.p, direction)
end    
