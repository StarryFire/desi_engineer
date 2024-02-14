package cms

import (
	"github.com/labstack/echo/v4"
	"github.com/starryfire/desi_engineer/internal/cms/internal/route"
)

func AppendRoutes(r *echo.Echo) {
	rootRouter := r.Group("/")
	route.AppendRootRoutes(rootRouter)

	HealthCheckRoute := rootRouter.GET("health", controller.GetHealth)
	HealthCheckRoute.Name = projectconstant.HEALTH_CHECK_ROUTE_NAME

	articleGroup := rootRouter.Group("post/")
	route.AppendArticleRoutes(articleGroup)
}
