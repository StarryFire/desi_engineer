package route

import (
	"fmt"

	"github.com/labstack/echo/v4"
	"github.com/starryfire/desi_engineer/config/projectconfig"
	"github.com/starryfire/desi_engineer/config/projectconstant"
	"github.com/starryfire/desi_engineer/internal/cms/internal/controller"
)

func AppendRootRoutes(rootRouter *echo.Group) {
	homePageRoute := rootRouter.GET("", controller.ServeHomePage)
	homePageRoute.Name = projectconstant.HOME_PAGE_ROUTE_NAME

	SocialMediaPostImageRoute := rootRouter.GET("social-media-post-image", controller.ServeSocialMediaPostImage)
	SocialMediaPostImageRoute.Name = projectconstant.SOCIAL_MEDIA_POST_IMAGE_ROUTE_NAME

	appendSitemapRoutes(rootRouter)
	appendFaviconRoutes(rootRouter)

	staticGroup := rootRouter.Group("static/")
	appendStaticRoutes(staticGroup)
}

func appendSitemapRoutes(r *echo.Group) {
	// uncomment this once you build the sitemap.xml
	// r.Static("sitemap.xml", "assets/sitemap")
}

func appendFaviconRoutes(r *echo.Group) {
	r.Static("", "assets/favicon")
}

// SECURITY: Do not expose the whole assets directory as
// that might expose files that should not be exposed
func appendStaticRoutes(r *echo.Group) {
	r.Static("font", "assets/font")
	r.Static("sprite", "assets/sprite")

	r.Static(fmt.Sprintf("%s/js", projectconfig.VERSION), fmt.Sprintf("assets/js/%s", projectconfig.ENV))
	r.Static(fmt.Sprintf("%s/css", projectconfig.VERSION), fmt.Sprintf("assets/css/%s", projectconfig.ENV))
}
