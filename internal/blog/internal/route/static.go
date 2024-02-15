package route

import (
	"fmt"

	"github.com/labstack/echo/v4"
	"github.com/starryfire/desi_engineer/config/projectconfig"
)

// SECURITY: Do not expose the whole assets directory as
// that might expose files that should not be exposed
func AppendStaticRoutes(g *echo.Group) {
	// /font => /font*
	g.Static("/font", "assets/font")
	g.Static("/sprite", "assets/sprite")
	g.Static("/icon", "assets/icon")

	g.Static(fmt.Sprintf("/%s/js", projectconfig.VERSION), fmt.Sprintf("assets/js/%s", projectconfig.ENV))
	g.Static(fmt.Sprintf("/%s/css", projectconfig.VERSION), fmt.Sprintf("assets/css/%s", projectconfig.ENV))
}
