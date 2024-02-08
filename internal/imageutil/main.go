package imageutil

import (
	"image"
	"image/color"

	"github.com/fogleman/gg"
)

// Reference: https://josemyduarte.github.io/2021-02-28-quotes-on-images-with-go/

// Use this in order to destroy cached og images on linkedin: https://www.linkedin.com/post-inspector/inspect/

// In order to preview your og image on various websites, use this: https://robolly.com/open-graph-preview/

type GenerateTextOnImageRequest struct {
	BgImgPath string
	FontPath  string
	FontSize  float64
	Text      string
}

func GenerateTextOnImage(request GenerateTextOnImageRequest) (image.Image, error) {
	bgImage, err := gg.LoadImage(request.BgImgPath)
	if err != nil {
		return nil, err
	}
	imgWidth := bgImage.Bounds().Dx()
	imgHeight := bgImage.Bounds().Dy()

	dc := gg.NewContext(imgWidth, imgHeight)
	dc.DrawImage(bgImage, 0, 0)

	if err := dc.LoadFontFace(request.FontPath, request.FontSize); err != nil {
		return nil, err
	}

	x := float64(imgWidth / 2)
	y := float64((imgHeight / 2) - 80)
	maxWidth := float64(imgWidth) - 200
	dc.SetColor(color.White)
	dc.DrawStringWrapped(request.Text, x, y, 0.5, 0.5, maxWidth, 1.5, gg.AlignCenter)

	return dc.Image(), nil
}
