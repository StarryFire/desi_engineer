package datatype

import (
	"strings"

	"gopkg.in/yaml.v3"
)

type ArticleSlug string

func (t ArticleSlug) MarshalYAML() (interface{}, error) {
	slug := strings.ReplaceAll(string(t), "-", "_")
	return []byte(slug), nil
}

func (t *ArticleSlug) UnmarshalYAML(b *yaml.Node) error {
	slug := strings.ReplaceAll(b.Value, "_", "-")
	*t = ArticleSlug(slug)
	return nil
}

func (t *ArticleSlug) UnmarshalParam(param string) error {
	*t = ArticleSlug(param)
	return nil
}

func (t ArticleSlug) FileSlug() string {
	return strings.ReplaceAll(string(t), "-", "_")
}

func (t ArticleSlug) URLSlug() string {
	return string(t)
}
