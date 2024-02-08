package datatype

import (
	"fmt"
	"log"
	"time"

	"github.com/starryfire/desi_engineer/config/projectconstant"
	"gopkg.in/yaml.v3"
)

type ArticleTime struct {
	time.Time
}

func (t ArticleTime) MarshalYAML() (interface{}, error) {
	date := t.Format(projectconstant.DATE_FORMAT)
	date = fmt.Sprintf(`"%s"`, date)
	return []byte(date), nil
}

func (t *ArticleTime) UnmarshalYAML(b *yaml.Node) error {
	date, err := time.Parse(projectconstant.DATE_FORMAT, b.Value)
	if err != nil {
		log.Println(err)
		return err
	}
	t.Time = date
	return nil
}
