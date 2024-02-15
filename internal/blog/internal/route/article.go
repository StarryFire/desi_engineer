package route

import (
	"github.com/labstack/echo/v4"
	"github.com/starryfire/desi_engineer/config/projectconstant"
	"github.com/starryfire/desi_engineer/internal/blog/internal/controller"
)

func AppendArticleRoutes(r *echo.Group) {
	articlePageRoute := r.GET("/:slug", controller.ServeArticlePage)
	articlePageRoute.Name = projectconstant.ARTICLE_PAGE_ROUTE_NAME
}
