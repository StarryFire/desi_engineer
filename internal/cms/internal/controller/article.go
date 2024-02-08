package controller

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/starryfire/desi_engineer/internal/cms/internal/util"
	"github.com/starryfire/desi_engineer/internal/cms/internal/view"
	"github.com/starryfire/desi_engineer/internal/component"
	"github.com/starryfire/desi_engineer/internal/componentutil"
	"github.com/starryfire/desi_engineer/internal/datatype"
	"github.com/starryfire/desi_engineer/internal/templutil"
)

type ArticleRequest struct {
	Slug datatype.ArticleSlug `param:"slug"`
}

func renderRecord(ctx echo.Context, slug datatype.ArticleSlug, record datatype.ArticleRecord) {
	articlePage := view.ArticlePage(view.ArticlePageProps{
		Title:       record.Title,
		Description: record.Description,
		Slug:        slug,
		ArticleMainContentProps: view.ArticleMainContentProps{
			Title:       record.Title,
			Tags:        record.Tags,
			PublishedAt: record.Date,
			FilePath:    util.GetArticleFilePath(slug),
			IsDraft:     record.Draft,
		},
	})
	templutil.Render(
		ctx,
		http.StatusOK,
		articlePage,
		componentutil.DEFAULT_ERROR_HANDLER_TEMPL_COMPONENT,
	)
}

func ServeArticlePage(ctx echo.Context) error {
	var articleRequest ArticleRequest
	err := ctx.Bind(&articleRequest)
	if err != nil {
		ctx.Logger().Error(err)
		templutil.Render(
			ctx,
			http.StatusNotFound,
			component.NotFound(),
			componentutil.DEFAULT_ERROR_HANDLER_TEMPL_COMPONENT,
		)
		return nil
	}

	record, err := util.GetArticleRecord(ctx, articleRequest.Slug)
	if err == nil {
		if util.IsArticleVisible(record) {
			renderRecord(ctx, articleRequest.Slug, record)
			return nil
		}
	}

	templutil.Render(
		ctx,
		http.StatusNotFound,
		component.NotFound(),
		componentutil.DEFAULT_ERROR_HANDLER_TEMPL_COMPONENT,
	)
	return nil
}
