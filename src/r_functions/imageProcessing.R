# Apply a circular crop to an image
cropCircular <- function(imageOriginal, xOffset, yOffset, zoom) {
  # xOffset = 0
  # yOffset = 0
  # get height, width and crop longer side to match shorter side
  imageInfo <- magick::image_info(imageOriginal)
  minSide <- round(min(imageInfo$width, imageInfo$height) / zoom)
  
  imageSquare <- magick::image_crop(imageOriginal, geometry=paste0(minSide, "x", minSide, "+", xOffset, "+", yOffset), repage=TRUE)
  
  # create a new image with white background and black circle
  mask <- magick::image_draw(image_blank(minSide, minSide))
  symbols(minSide/2, minSide/2, circles=(minSide/2)-3, bg='black', inches=FALSE, add=TRUE)
  dev.off()
  
  # create an image composite using both images
  imageCircular <- magick::image_composite(imageSquare, mask, operator='copyopacity')
  
  # set background as white
  imageCircular <- magick::image_background(imageCircular, 'white')
  
  return(imageCircular)
}

# Download & Crop Image
downloadAndCropImage <- function(imageLocation, fileName, xOffset, yOffset, zoom, outputDir) {
  # read image from web
  image <- magick::image_read(imageLocation)

  # save original image
  image_write(image, file.path(outputDir, "images", "originals", fileName))

  # resize proportionally to height: 200px(image)
  image <- image_scale(image, "x400") 
  
  # apply circular crop
  circlularImage <- cropCircular(image, xOffset, yOffset, zoom)

  # save circular image
  image_write(circlularImage, file.path(outputDir, "images", "cropped", fileName))
}

# Replace filename extension with png
pngExtension <- function(fileName) {
  fileNamePNG = paste0(tools::file_path_sans_ext(fileName), ".png")
  return(fileNamePNG)
}

# Get palette of 6 colours from manually cropped image
getPalette <- function(fileName, dataDir) {
  # Ensure reproducibility
  set.seed(123)

  # Get colors and create a palette
  palette <- colorfindr::get_colors(file.path(dataDir, "images", "handCropped", fileName), 
                      exclude_col = "#FFFFFF", exclude_rad = 10
                      ) %>% 
  make_palette(n = 6)
  return(palette)
}
