package controller

import (
	"bytes"
	"fmt"
	"image/jpeg"
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/starryfire/desi_engineer/config/cmsconfig"
	"github.com/starryfire/desi_engineer/internal/cms/internal/util"
	"github.com/starryfire/desi_engineer/internal/datatype"
	"github.com/starryfire/desi_engineer/internal/imageutil"
)


func GetHealth(ctx echo.Context) error {
	return ctx.Json(http.StatusOK)
}
