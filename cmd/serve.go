/*
Copyright © 2024 Kartik Sharma <desiengineer.dev@gmail.com>

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

	http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/
package cmd

import (
	"fmt"
	stdLog "log"
	"net/http"
	"os"
	"time"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/labstack/gommon/log"
	"github.com/spf13/cobra"
	"github.com/starryfire/desi_engineer/config/projectconfig"
	"github.com/starryfire/desi_engineer/config/projectconstant"
	"github.com/starryfire/desi_engineer/internal/blog"
	"github.com/starryfire/desi_engineer/internal/componentutil"
	"github.com/starryfire/desi_engineer/internal/projectmiddleware"
	"github.com/starryfire/desi_engineer/internal/proxy"
	"github.com/starryfire/desi_engineer/internal/templutil"
)

func serve(host string, port int) {
	r := echo.New()
	r.HTTPErrorHandler = templutil.GetCustomErrorHandler(componentutil.DEFAULT_ERROR_HANDLER_TEMPL_COMPONENT)
	if projectconfig.ENV == projectconstant.ENV_DEV {
		// To disable caching for all routes (both asset and html files)
		// in dev environment
		r.Use(projectmiddleware.NoCache())
	}

	// logger settings
	// customizing echo logger
	logger := log.New("[BLOG]")
	logger.SetOutput(os.Stdout)
	r.Logger = logger
	// copied from echo.New() method
	r.StdLogger = stdLog.New(r.Logger.Output(), r.Logger.Prefix()+": ", 0)
	// docs: https://echo.labstack.com/docs/customization#log-header
	r.Logger.SetHeader("${prefix} ${long_file}:${line} ${level}")
	// by default this is set to log.ERROR
	if projectconfig.ENV == projectconstant.ENV_DEV {
		r.Logger.SetLevel(log.DEBUG)
	} else {
		r.Logger.SetLevel(log.INFO)
	}
	// customizing request logger
	r.Use(middleware.LoggerWithConfig(middleware.LoggerConfig{
		Format: "${status} ${method} ${uri} ${latency_human} ${error}\n",
		Output: r.Logger.Output(), // for showing colored output
	}))

	// Remove all trailing slashes..ensures that /hello/ redirects to /hello
	// required for avoiding duplication of content which adversely affects SEO
	r.Use(
		middleware.RemoveTrailingSlashWithConfig(middleware.TrailingSlashConfig{
			RedirectCode: http.StatusPermanentRedirect,
		}),
	)

	blog.AppendRoutes(r)

	if projectconfig.ENV == projectconstant.ENV_DEV {
		// Simply reloads the web browser page Xs after the server is started
		go func() {
			proxy.StartProxy(
				fmt.Sprintf("http://%s:7331", host),
				fmt.Sprintf("http://%s:%d", host, port),
				5*time.Second,
			)
		}()
	}

	err := r.Start(fmt.Sprintf("%s:%d", host, port))
	if err != nil {
		r.Logger.Fatal(err)
	}
}

// serveCmd represents the serve command
var serveCmd = &cobra.Command{
	Use:   "serve",
	Short: "Starts the server",
	Long: `Starts the server on the specified host and port and serves
markdown files as HTML`,
	Run: func(cmd *cobra.Command, args []string) {
		host, err := cmd.Flags().GetString("host")
		if err != nil {
			log.Fatal(err)
		}
		port, err := cmd.Flags().GetInt("port")
		if err != nil {
			log.Fatal(err)
		}
		serve(host, port)
	},
}

func init() {
	rootCmd.AddCommand(serveCmd)

	serveCmd.Flags().StringP("host", "h", projectconfig.DEFAULT_SERVER_HOST, "Host for the server to listen on")
	serveCmd.Flags().IntP("port", "p", projectconfig.DEFAULT_SERVER_PORT, "Port for the server to listen on")
}
