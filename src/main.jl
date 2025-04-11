using Images, FileIO, ColorTypes, StaticArrays


#------------najbolj osnovne stvari



#osnovne funkcije: linear algebra paket

#render funkcija: da dejansko generira sliko 
#trenutno placeholder
function render(sirina, visina) 
    img = Array{RGB{N0f8}}(undef, sirina, visina)

    for y in 1:sirina, x in 1:visina
        img[y, x] = RGB{N0f8}(0.3, 0.5, 0.3)
    end

    return img
end    


function main()  
    sirina, visina = 400, 400
    img = render(sirina, visina)
    save("../images/render.png", img)
end



