package route

import (
	"fmt"

	"github.com/labstack/echo/v4"
	"github.com/starryfire/desi_engineer/config/projectconfig"
)

// SECURITY: Do not expose the whole assets directory as
// that might expose files that should not be exposed
func AppendStaticRoutes(r *echo.Group) {
	r.Static("/font", "assets/font")
	r.Static("/sprite", "assets/sprite")

	r.Static(fmt.Sprintf("/%s/js", projectconfig.VERSION), fmt.Sprintf("assets/js/%s", projectconfig.ENV))
	r.Static(fmt.Sprintf("/%s/css", projectconfig.VERSION), fmt.Sprintf("assets/css/%s", projectconfig.ENV))
}
