using Images, FileIO, ColorTypes, StaticArrays


#------------najbolj osnovne stvari



#osnovne funkcije: linear algebra paket

#render funkcija: da dejansko generira sliko 
#trenutno placeholder
function render(sirina, visina) 
    img = Array{RGB{N0f8}}(undef, cam.nx, cam.ny) #za kamero 

    for j in 1:cam.ny, i in 1:cam.nx
        ray = generate_ray(cam, i, j)
        color = raytrace(ray, objects)
        img[i, j] = color
    end

    return img
end    


function main()  
    sirina, visina = 400, 400
    img = render(sirina, visina)
    save("../images/render.png", img)
end



