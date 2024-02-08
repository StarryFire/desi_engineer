module github.com/starryfire/desi_engineer

go 1.21

// dev: v0.2.508, prod: v0.2.501
require github.com/a-h/templ v0.2.501

require (
	github.com/gomarkdown/markdown v0.0.0-20231222211730-1d6d20845b47
	github.com/labstack/echo/v4 v4.11.4
	github.com/labstack/gommon v0.4.2
	gopkg.in/yaml.v3 v3.0.1
)

require (
	github.com/cenkalti/backoff/v4 v4.2.1 // indirect
	github.com/cli/browser v1.3.0 // indirect
	github.com/fogleman/gg v1.3.0 // indirect
	github.com/fsnotify/fsnotify v1.7.0 // indirect
	github.com/golang-jwt/jwt v3.2.2+incompatible // indirect
	github.com/golang/freetype v0.0.0-20170609003504-e2365dfdc4a0 // indirect
	github.com/hashicorp/hcl v1.0.0 // indirect
	github.com/inconshreveable/mousetrap v1.1.0 // indirect
	github.com/magiconair/properties v1.8.7 // indirect
	github.com/mattn/go-colorable v0.1.13 // indirect
	github.com/mattn/go-isatty v0.0.20 // indirect
	github.com/mitchellh/mapstructure v1.5.0 // indirect
	github.com/pelletier/go-toml/v2 v2.1.1 // indirect
	github.com/sagikazarmark/locafero v0.4.0 // indirect
	github.com/sagikazarmark/slog-shim v0.1.0 // indirect
	github.com/sourcegraph/conc v0.3.0 // indirect
	github.com/spf13/afero v1.11.0 // indirect
	github.com/spf13/cast v1.6.0 // indirect
	github.com/spf13/cobra v1.8.0 // indirect
	github.com/spf13/pflag v1.0.5 // indirect
	github.com/spf13/viper v1.18.2 // indirect
	github.com/subosito/gotenv v1.6.0 // indirect
	github.com/valyala/bytebufferpool v1.0.0 // indirect
	github.com/valyala/fasttemplate v1.2.2 // indirect
	go.uber.org/atomic v1.11.0 // indirect
	go.uber.org/multierr v1.11.0 // indirect
	golang.org/x/crypto v0.17.0 // indirect
	golang.org/x/exp v0.0.0-20240119083558-1b970713d09a // indirect
	golang.org/x/image v0.15.0 // indirect
	golang.org/x/net v0.19.0 // indirect
	golang.org/x/sys v0.16.0 // indirect
	golang.org/x/text v0.14.0 // indirect
	golang.org/x/time v0.5.0 // indirect
	gopkg.in/ini.v1 v1.67.0 // indirect
)

// For more info: https://stackoverflow.com/a/55347424/5872905
// If there is version mismatch error, simply update the versions to be the required one in both replace and require statements
// go.work is useless since I can't run go run ./... inside src when there is a version mismatch
// b/w the local version of a module and the remote version of a module in go.mod
// Comment this out when building for prod
// replace github.com/a-h/templ v0.2.508 => /Users/Kartik/Desktop/Business/projects/templ
