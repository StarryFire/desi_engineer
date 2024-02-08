package templutil

import (
	"context"
	"fmt"
	"net/http"

	"github.com/a-h/templ"
	"github.com/labstack/echo/v4"
	"github.com/starryfire/desi_engineer/config/projectconfig"
	"github.com/starryfire/desi_engineer/config/projectconstant"
)

type TemplContext string

const EchoContextKey = TemplContext("EchoContext")

func GetEchoContext(ctx context.Context) echo.Context {
	return ctx.Value(EchoContextKey).(echo.Context)
}

func GetEchoReverseURL(
	ctx context.Context,
	name string,
	params ...interface{},
) string {
	return GetEchoContext(ctx).Echo().Reverse(name, params...)
}

func GetStatusCodeAndMessageFromError(ctx echo.Context, err error) (int, string) {
	he, ok := err.(*echo.HTTPError)
	if ok {
		if he.Internal != nil {
			if herr, ok := he.Internal.(*echo.HTTPError); ok {
				he = herr
			}
		}
	} else {
		he = &echo.HTTPError{
			Code:    http.StatusInternalServerError,
			Message: http.StatusText(http.StatusInternalServerError),
		}
	}

	code := he.Code
	var message string
	switch m := he.Message.(type) {
	case string:
		if projectconfig.ENV == projectconstant.ENV_DEV {
			message = fmt.Sprintf("message: %s, error: %s", m, err.Error())
		} else {
			message = m
		}
	case error:
		message = m.Error()
	default:
		message = fmt.Sprintf("%+v", m)
	}
	return code, message
}

// Handles all errors that are returned by echo controllers
func GetCustomErrorHandler(errorHandlerTemplComponent func(echo.Context, string) templ.Component) func(error, echo.Context) {
	return func(err error, ctx echo.Context) {
		code, message := GetStatusCodeAndMessageFromError(ctx, err)
		if code >= http.StatusInternalServerError {
			ctx.Logger().Error(err)
		}

		if ctx.Response().Committed {
			return
		}

		// Send response
		if ctx.Request().Method == http.MethodHead { // Issue #608
			err = ctx.NoContent(code)
			if err != nil {
				ctx.Logger().Error(err)
			}
		} else {
			Render(
				ctx,
				code,
				errorHandlerTemplComponent(ctx, message),
				nil,
			)
		}
	}
}
