package blogconfig

import (
	_ "embed"
)

//go:embed articles.yaml
var ARTICLES_LIST string

const (
	HOME_PAGE_TITLE       = "Home"
	HOME_PAGE_DESCRIPTION = "A guide for software engineers to build their own business."
)
