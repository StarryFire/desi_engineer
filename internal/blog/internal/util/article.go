package util

import (
	"fmt"

	"github.com/labstack/echo/v4"
	"github.com/starryfire/desi_engineer/config/blogconfig"
	"github.com/starryfire/desi_engineer/config/projectconfig"
	"github.com/starryfire/desi_engineer/config/projectconstant"
	"github.com/starryfire/desi_engineer/internal/datatype"
	"github.com/starryfire/desi_engineer/internal/yamlutil"
)

func IsArticleVisible(article datatype.ArticleRecord) bool {
	return !article.Draft || (article.Draft && projectconfig.ENV == projectconstant.ENV_DEV)
}

func GetArticleFilePath(article datatype.ArticleSlug) string {
	return projectconstant.ARTICLE_RECORDS_DIRECTORY + article.FileSlug() + ".md"
}

func GetArticleRecords(ctx echo.Context) (datatype.ArticleRecords, error) {
	return yamlutil.UnmarshalYamlString[datatype.ArticleRecords](ctx, blogconfig.ARTICLES_LIST)
}

func GetArticleRecord(ctx echo.Context, slug datatype.ArticleSlug) (datatype.ArticleRecord, error) {
	articleRecords, err := GetArticleRecords(ctx)
	if err != nil {
		ctx.Logger().Error(err)
		return datatype.ArticleRecord{}, err
	}
	if record, ok := articleRecords[slug]; ok {
		return record, nil
	}
	return datatype.ArticleRecord{}, fmt.Errorf("article record not found for slug: %s", slug)
}
