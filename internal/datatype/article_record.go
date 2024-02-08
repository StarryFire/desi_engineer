package datatype

type ArticleRecords map[ArticleSlug]ArticleRecord
type ArticleRecord struct {
	Title       string      `yaml:"title"`
	Description string      `yaml:"description"`
	Date        ArticleTime `yaml:"date"`
	Tags        []string    `yaml:"tags"`
	Draft       bool        `yaml:"draft"`
}
