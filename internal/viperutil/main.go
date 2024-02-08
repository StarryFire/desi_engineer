package viperutil

import (
	"fmt"

	"github.com/spf13/viper"
)

func ReadConfigFile(secrets_file_path string) {
	viper.SetConfigFile(secrets_file_path)
	err := viper.ReadInConfig()
	if err != nil {
		panic(fmt.Errorf("cannot parse config file: %v", err))
	}
}
