package util

import (
	"strings"

	"github.com/starryfire/desi_engineer/config/projectconfig"
)

func GetFullURL(url string) string {
	return strings.Join([]string{projectconfig.HTTP_PROTOCOL, "://", projectconfig.DOMAIN, url}, "")
}
