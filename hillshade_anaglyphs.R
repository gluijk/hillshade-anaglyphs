# Anaglyph calculation from a hillshade map
# www.overfitting.net
# https://www.overfitting.net/2024/08/anaglifos-de-un-mapa-de-elevacion-con-r.html

library(tiff)  # save 16-bit TIFF's


# ANAGLYPH

# Create left/right images by slicing the DEM to left/right

ALTMAX=3718  # Teide altitude (m)
NSLICES=50  # pixels to control anaglyph perceived height

for (orientation in c('izqcolor', 'dercolor')) {
    print("----------------------------------------------")
    print(paste0("Calculation orientation: ", orientation))
    
    DEM=readTIFF(paste0("DEM", orientation, ".tif"))*ALTMAX
    composite=readTIFF(paste0("composite", orientation, ".tif"))
    R=composite[,,1]
    G=composite[,,2]
    B=composite[,,3]
    
    stepmap=composite
    Rd=R
    Gd=G
    Bd=B
    for (n in 1:NSLICES) {
        print(paste0(n, "/", NSLICES, "..."))
        z=n*ALTMAX/NSLICES
        i=which(DEM >= z)
    
        Rd[i-n]=R[i]
        Gd[i-n]=G[i]
        Bd[i-n]=B[i]
    }
    stepmap[,,1]=Rd
    stepmap[,,2]=Gd
    stepmap[,,3]=Bd
    writeTIFF(stepmap, paste0("stepmap", orientation, ".tif"),
                              bits.per.sample=16, compression="LZW")
}


# Fuse left/right images in anaglyph

Gamma=1  # optional gamma lift for R channel (1=no lift)

# Monochrome anaglyph
# Read left and right sliced images
izq=readTIFF("stepmapizq.tif")
der=readTIFF("stepmapder.tif")

lumizq=0.299*izq[,,1]+0.587*izq[,,2]+0.114*izq[,,3]  # Luminance
lumder=0.299*der[,,1]+0.587*der[,,2]+0.114*der[,,3]  # model
anaglyph=izq
anaglyph[,,1]=lumizq^(1/Gamma)
anaglyph[,,2]=lumder
anaglyph[,,3]=lumder
writeTIFF(anaglyph, "anaglifobn.tif", bits.per.sample=16, compression="LZW")


# Colour anaglyph
# Read left and right sliced images
izq=readTIFF("stepmapizqcolor.tif")
der=readTIFF("stepmapdercolor.tif")

anaglyph=izq^(1/Gamma)
anaglyph[,,2:3]=der[,,2:3]
writeTIFF(anaglyph, "anaglifocolor.tif", bits.per.sample=16, compression="LZW")
