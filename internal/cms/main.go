package cms

import (
	"github.com/labstack/echo/v4"
	"github.com/starryfire/desi_engineer/internal/cms/internal/route"
)

func AppendRoutes(r *echo.Echo) {
	rootRouter := r.Group("/")
	route.AppendRootRoutes(rootRouter)

	articleGroup := rootRouter.Group("post/")
	route.AppendArticleRoutes(articleGroup)
}
