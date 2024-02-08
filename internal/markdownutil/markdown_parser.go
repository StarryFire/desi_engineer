package markdownutil

import (
	"os"

	"github.com/gomarkdown/markdown"
	"github.com/gomarkdown/markdown/html"
	"github.com/gomarkdown/markdown/parser"
	"github.com/labstack/echo/v4"
)

func newMarkdownRenderer() *html.Renderer {
	opts := html.RendererOptions{
		Flags: html.CommonFlags,
	}
	return html.NewRenderer(opts)
}

func newMarkdownParser() *parser.Parser {
	extensions := parser.CommonExtensions
	p := parser.NewWithExtensions(extensions)
	return p
}

func ParseMarkdownBytesToHTML(data []byte) (string, error) {
	parser := newMarkdownParser()
	renderer := newMarkdownRenderer()

	buf := markdown.ToHTML(data, parser, renderer)
	return string(buf), nil
}

func ParseMarkdownFileToHTML(ctx echo.Context, filepath string) (string, error) {
	file, err := os.ReadFile(filepath)
	if err != nil {
		ctx.Logger().Error(err)
		return "", err
	}
	return ParseMarkdownBytesToHTML(file)
}
