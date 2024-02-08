package projectconfig

import (
	"github.com/spf13/viper"
	"github.com/starryfire/desi_engineer/config/projectconstant"
	"github.com/starryfire/desi_engineer/internal/viperutil"
)

var (
	// used for cache invalidation/busting on client machines
	VERSION = "v1"

	ENV string
)

func init() {
	viperutil.ReadConfigFile(projectconstant.SECRETS_FILE_PATH)

	viper.SetDefault("global.environment", projectconstant.ENV_DEV)
	ENV = viper.GetString("global.environment")
}
