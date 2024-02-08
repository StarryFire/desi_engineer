package viewutil

import (
	"fmt"

	"github.com/labstack/echo/v4"
	"github.com/starryfire/desi_engineer/config/projectconstant"
)

// GetPaginationIndices returns a list of indices that should be displayed in the pagination.
func GetPaginationIndices(currentPage int, totalPages int, maxIndices int) []int {
	result := make([]int, 0)
	// how many indices are there after the current page
	next := totalPages - currentPage

	// maxIndices/2 indices should be there after the current page index
	// otherwise the indices before the current page index will be more than maxIndices/2
	missingIndicesInNext := -1 * min(next-maxIndices/2, 0)
	for i := max(currentPage-maxIndices/2-missingIndicesInNext, 1); i <= currentPage; i++ {
		result = append(result, i)
	}
	for i := currentPage + 1; i <= totalPages && len(result) < maxIndices; i++ {
		result = append(result, i)
	}

	return result
}

func GetPaginationIndexURL(ctx echo.Context, index int) string {
	url := ctx.Echo().Reverse(projectconstant.HOME_PAGE_ROUTE_NAME)
	if index == 1 {
		return url
	}
	return fmt.Sprintf("%s?page=%d", url, index)
}
