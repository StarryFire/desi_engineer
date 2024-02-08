package yamlutil

import (
	"os"

	"github.com/labstack/echo/v4"
	"gopkg.in/yaml.v3"
)

func UnmarshalYamlString[T any](ctx echo.Context, yamlInput string) (T, error) {
	var t T

	err := yaml.Unmarshal([]byte(yamlInput), &t)
	if err != nil {
		ctx.Logger().Error(err)
		return t, err
	}
	return t, nil
}

// Loads the yaml file content into memory all at once
// and then parses it into the go struct
// use this for small yaml files
func UnmarshalYamlFile[T any](ctx echo.Context, filepath string) (T, error) {
	var t T
	file, err := os.ReadFile(filepath)
	if err != nil {
		ctx.Logger().Error(err)
		return t, err
	}

	err = yaml.Unmarshal(file, &t)
	if err != nil {
		ctx.Logger().Error(err)
		return t, err
	}
	return t, nil
}

// Doesn't load the yaml file into memory all at once
// i.e. streams the file content into go struct
// use this for very large yaml files
func DecodeYamlFile[T any](ctx echo.Context, filepath string) (T, error) {
	var t T
	file, err := os.OpenFile(filepath, os.O_RDONLY, 0600)
	if err != nil {
		ctx.Logger().Error(err)
		return t, err
	}
	defer file.Close()

	dec := yaml.NewDecoder(file)
	err = dec.Decode(&t)
	if err != nil {
		ctx.Logger().Error(err)
		return t, err
	}

	return t, nil
}
