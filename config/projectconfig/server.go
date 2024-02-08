package projectconfig

import (
	"github.com/spf13/viper"
	"github.com/starryfire/desi_engineer/config/projectconstant"
	"github.com/starryfire/desi_engineer/internal/viperutil"
)

var (
	DEFAULT_SERVER_HOST string
	DEFAULT_SERVER_PORT int
	DOMAIN              string
	HTTP_PROTOCOL       string
)

func init() {
	viperutil.ReadConfigFile(projectconstant.SECRETS_FILE_PATH)

	viper.SetDefault("server.default_host", "127.0.0.1")
	viper.SetDefault("server.default_port", 3000)
	viper.SetDefault("server.domain", "localhost")
	viper.SetDefault("server.http_protocol", "http")

	DEFAULT_SERVER_HOST = viper.GetString("server.default_host")
	DEFAULT_SERVER_PORT = viper.GetInt("server.default_port")
	DOMAIN = viper.GetString("server.domain")
	HTTP_PROTOCOL = viper.GetString("server.http_protocol")
}
