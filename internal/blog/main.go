package blog

import (
	"net/http"

	"github.com/labstack/echo/v4"
	"github.com/labstack/echo/v4/middleware"
	"github.com/starryfire/desi_engineer/config/projectconstant"
	"github.com/starryfire/desi_engineer/internal/blog/internal/controller"
	"github.com/starryfire/desi_engineer/internal/blog/internal/route"
)

func Serve(r *echo.Echo) {
	fsGroup := r.Group("")
	appendFSRoutes(fsGroup)

	rootGroup := r.Group("")
	appendRootRoutes(rootGroup)
}

func appendFSRoutes(g *echo.Group) {
	// We will not use trailing slash middleware in this group because we are serving files from a filesystem in this case.
	// Hence, /hello is used to refer to a file and /hello/ is used to refer to a directory.
	// Both will serve different files, the former will serve /hello.html whereas the latter will serve /hello/index.html

	// uncomment this once you build the sitemap.xml
	// g.File("/sitemap.xml", "assets/sitemap/sitemap.xml")

	/*
		If multiple routes in the inbuilt radix tree match the requested url, only the first matched
		route and its middlewares will be executed.
		Due to this, /favicon.svg will match this route but /favicon.svg/ will match the /:slug route
	*/
	g.File("/favicon.svg", "assets/favicon/favicon.svg")

	staticGroup := g.Group("/static")
	route.AppendStaticRoutes(staticGroup)
}

func appendRootRoutes(g *echo.Group) {
	/*
		Things to think about, when deciding on a url structure:
		- Users can visit either url on your website i.e. one ending with slash or one not ending with slash. Ideally you should be serving both urls to avoid losing traffic.
		- You won't have to add code to serve the same content for /hello and /hello/ in your codebase

		There will be duplication of content problems with SEO because /hello and /hello/ will be considered different urls by search engines but will be hosting
		the same content. You can avoid this by either redirecting /hello to /hello/ (or vice-versa) or
		by making either /hello or /hello/ the canonical url for the content by adding canonical metatag to the content.
		Ref: https://moz.com/learn/seo/canonicalization

		You can also follow a practice of not ending urls with a slash which is a more cleaner url structure in my opinion
		and is widely followed for RESTful APIs.

		SEO doesn't care about the url structure as long as it is consistent.

		So I have decided to remove trailing slash from my url structure and this will be followed throughout the codebase.
		I am also redirecting every url with a trailing slash to the one without one, so we don't need to add canonical tags to our html content.
	*/
	g.Use(
		middleware.RemoveTrailingSlashWithConfig(middleware.TrailingSlashConfig{
			RedirectCode: http.StatusTemporaryRedirect,
		}),
	)

	homePageRoute := g.GET("/", controller.ServeHomePage)
	homePageRoute.Name = projectconstant.HOME_PAGE_ROUTE_NAME

	apiGroup := g.Group("/api")
	route.AppendAPIRoutes(apiGroup)

	articleGroup := g.Group("/:slug")
	route.AppendArticleRoutes(articleGroup)
}
