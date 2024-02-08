package templutil

import (
	"context"
	"net/http"

	"github.com/a-h/templ"
	"github.com/labstack/echo/v4"
)

func GetHandler(
	templComponent templ.Component,
	statusCode int,
	errorHandler func(*http.Request, error) http.Handler,
) *templ.ComponentHandler {
	return templ.Handler(
		templComponent,
		templ.WithStatus(statusCode),
		templ.WithErrorHandler(errorHandler),
	)
}

func Render(
	ctx echo.Context,
	statusCode int,
	templComponent templ.Component,
	errorHandlerTemplComponent func(echo.Context, string) templ.Component,
) {
	var errorHandler func(*http.Request, error) http.Handler = nil
	if errorHandlerTemplComponent != nil {
		// Handles all errors that occur while rendering templ templates
		errorHandler = func(req *http.Request, err error) http.Handler {
			status, message := GetStatusCodeAndMessageFromError(ctx, err)
			if status >= http.StatusInternalServerError {
				ctx.Logger().Error(message)
			}

			return GetHandler(errorHandlerTemplComponent(ctx, message), status, nil)
		}
	}

	handler := GetHandler(templComponent, statusCode, errorHandler)

	renderCtx := context.WithValue(
		ctx.Request().Context(),
		EchoContextKey,
		ctx,
	)
	handler.ServeHTTP(
		ctx.Response(),
		ctx.Request().WithContext(renderCtx),
	)
}
