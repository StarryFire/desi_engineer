package cmd

import (
	"net/http"
	"strings"
)

/*
Note that this approach buffers the entire response in memory, which might not be appropriate for very large responses.
*/
type ResponseModifierMiddleware struct {
	ResponseWriter http.ResponseWriter
	buf            strings.Builder
}

func (r *ResponseModifierMiddleware) Write(b []byte) (int, error) {
	return r.buf.Write(b)
}

func (r *ResponseModifierMiddleware) Header() http.Header {
	return r.ResponseWriter.Header()
}

func (r *ResponseModifierMiddleware) WriteHeader(statusCode int) {
	r.ResponseWriter.WriteHeader(statusCode)
}

func ResponseModifierMiddlewareHandler(next http.Handler) http.Handler {
	return http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		rmw := &ResponseModifierMiddleware{
			ResponseWriter: w,
		}
		next.ServeHTTP(rmw, r)

		// modifiedBody := strings.ToUpper(rmw.buf.String())
		modifiedBody := rmw.buf.String()
		w.Write([]byte(modifiedBody))
	})
}
