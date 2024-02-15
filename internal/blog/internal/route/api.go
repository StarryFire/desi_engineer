package route

import (
	"github.com/labstack/echo/v4"
	"github.com/starryfire/desi_engineer/config/projectconstant"
	"github.com/starryfire/desi_engineer/internal/blog/internal/controller"
)

func AppendAPIRoutes(r *echo.Group) {
	HealthCheckRoute := r.GET("/health", controller.GetHealth)
	HealthCheckRoute.Name = projectconstant.HEALTH_CHECK_ROUTE_NAME
}
