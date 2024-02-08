package controller

import (
	"math"
	"net/http"
	"sort"

	"github.com/labstack/echo/v4"
	"github.com/starryfire/desi_engineer/internal/cms/internal/util"
	"github.com/starryfire/desi_engineer/internal/cms/internal/view"
	"github.com/starryfire/desi_engineer/internal/componentutil"
	"github.com/starryfire/desi_engineer/internal/templutil"
)

type HomePageRequest struct {
	Page int `query:"page"`
}

func ServeHomePage(ctx echo.Context) error {
	const (
		PAGE_SIZE = 5
	)

	articleRecords, err := util.GetArticleRecords(ctx)
	if err != nil {
		ctx.Logger().Error(err)
		return err
	}

	var homePageRequest HomePageRequest
	err = ctx.Bind(&homePageRequest)
	if err != nil {
		// log the error and continue with the flow
		ctx.Logger().Error(err)
	}

	posts := make([]view.HomePostProps, 0)
	for slug, record := range articleRecords {
		if util.IsArticleVisible(record) {
			posts = append(posts, view.HomePostProps{
				Slug:          slug,
				ArticleRecord: record,
			})
		}
	}

	// sorts in descending order
	sort.SliceStable(posts, func(i, j int) bool {
		return posts[i].Date.Time.After(posts[j].Date.Time)
	})
	// there will always be 1 page at the very least
	total_pages := max(int(math.Ceil(float64(len(posts))/PAGE_SIZE)), 1)
	homePageRequest.Page = homePageRequest.Page - 1
	homePageRequest.Page = max(homePageRequest.Page, 0)
	homePageRequest.Page = min(homePageRequest.Page, total_pages-1)

	start_index := homePageRequest.Page * PAGE_SIZE
	end_index := min(start_index+PAGE_SIZE, len(posts))
	posts = posts[start_index:end_index]

	templutil.Render(
		ctx,
		http.StatusOK,
		view.HomePage(
			view.HomePageProps{
				HomeMainContentProps: view.HomeMainContentProps{
					TotalPages:     total_pages,
					CurrentPage:    homePageRequest.Page + 1,
					PaginationSize: PAGE_SIZE,
					Posts:          posts,
				},
			},
		),
		componentutil.DEFAULT_ERROR_HANDLER_TEMPL_COMPONENT,
	)
	return nil
}
