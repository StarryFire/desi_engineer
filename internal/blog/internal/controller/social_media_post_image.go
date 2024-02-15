package controller

import (
	"bytes"
	"fmt"
	"image/jpeg"
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/starryfire/desi_engineer/config/blogconfig"
	"github.com/starryfire/desi_engineer/internal/blog/internal/util"
	"github.com/starryfire/desi_engineer/internal/datatype"
	"github.com/starryfire/desi_engineer/internal/imageutil"
)

type SocialMediaPostImageRequest struct {
	Slug      string `query:"slug"`
	MediaType string `query:"media_type"`
}

func ServeSocialMediaPostImage(ctx echo.Context) error {
	var req SocialMediaPostImageRequest
	err := ctx.Bind(&req)
	if err != nil {
		ctx.Logger().Error(err)
		return nil
	}

	title := ""
	if req.Slug == "" {
		title = blogconfig.HOME_PAGE_TITLE
	} else {
		record, err := util.GetArticleRecord(ctx, datatype.ArticleSlug(req.Slug))
		if err != nil {
			ctx.Logger().Error(err)
			title = "Article Not Found"
		} else {
			title = record.Title
		}
	}

	bg_image_path := "assets/image/og_banner.jpg"
	if req.MediaType == "twitter" {
		bg_image_path = "assets/image/twitter_banner.jpg"
	}

	img, err := imageutil.GenerateTextOnImage(imageutil.GenerateTextOnImageRequest{
		BgImgPath: bg_image_path,
		FontPath:  "assets/font/IBMPlexMono-Regular.ttf",
		FontSize:  49,
		Text:      title,
	})

	if err != nil {
		fmt.Printf("%+v", err)
	}

	var buf bytes.Buffer
	jpeg.Encode(&buf, img, nil)

	// In case you want to stream the bytes
	// Create a reader from the bytes
	// r := bytes.NewReader(buf.Bytes())
	// Send the bytes as a stream
	// return ctx.Stream(http.StatusOK, "image/jpeg", r)

	// in case you want to serve all the bytes at once as a blob
	return ctx.Blob(http.StatusOK, "image/jpeg", buf.Bytes())

}
