package component

import (
	"context"
	"io"

	"github.com/a-h/templ"
	"github.com/labstack/echo/v4"
	"github.com/starryfire/desi_engineer/internal/markdownutil"
)

func MarkdownViewer(echoCtx echo.Context, markdownFile string) templ.Component {
	return templ.ComponentFunc(func(ctx context.Context, w io.Writer) (err error) {
		html, err := markdownutil.ParseMarkdownFileToHTML(echoCtx, markdownFile)
		if err != nil {
			echoCtx.Logger().Error(err)
			return err
		}

		// Write unsafe HTML directly to the component
		_, err = io.WriteString(w, html)
		if err != nil {
			echoCtx.Logger().Error(err)
			return err
		}
		return nil
	})
}
