package controller

import (
	"net/http"

	"github.com/labstack/echo/v4"
)

func GetHealth(ctx echo.Context) error {
	return ctx.String(http.StatusOK, "OK")
}
