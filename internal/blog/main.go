package blog

import (
	"github.com/labstack/echo/v4"
	"github.com/starryfire/desi_engineer/config/projectconstant"
	"github.com/starryfire/desi_engineer/internal/blog/internal/controller"
	"github.com/starryfire/desi_engineer/internal/blog/internal/route"
)

func AppendRoutes(r *echo.Echo) {
	homePageRoute := r.GET("/", controller.ServeHomePage)
	homePageRoute.Name = projectconstant.HOME_PAGE_ROUTE_NAME

	SocialMediaPostImageRoute := r.GET("/social-media-post-image", controller.ServeSocialMediaPostImage)
	SocialMediaPostImageRoute.Name = projectconstant.SOCIAL_MEDIA_POST_IMAGE_ROUTE_NAME

	// uncomment this once you build the sitemap.xml
	// r.Static("/sitemap.xml", "assets/sitemap")

	// serves favicons
	r.Static("/", "assets/favicon")

	staticGroup := r.Group("/static")
	route.AppendStaticRoutes(staticGroup)

	HealthCheckRoute := r.GET("/api/health", controller.GetHealth)
	HealthCheckRoute.Name = projectconstant.HEALTH_CHECK_ROUTE_NAME

	articleGroup := r.Group("/post")
	route.AppendArticleRoutes(articleGroup)
}
