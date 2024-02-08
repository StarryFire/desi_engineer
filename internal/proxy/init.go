package proxy

import (
	"fmt"
	"net/http"
	"net/url"
	"time"

	"github.com/labstack/gommon/color"
)

// func openURL(w io.Writer, url string) error {
// 	backoff := backoff.NewExponentialBackOff()
// 	backoff.InitialInterval = time.Second
// 	var client http.Client
// 	client.Timeout = 1 * time.Second
// 	for {
// 		if _, err := client.Get(url); err == nil {
// 			break
// 		}
// 		d := backoff.NextBackOff()
// 		fmt.Fprintf(w, "Server not ready. Retrying in %v...\n", d)
// 		time.Sleep(d)
// 	}
// 	return browser.OpenURL(url)
// }

func StartProxy(delegatorURL string, targetURL string, reloadDelay time.Duration) error {
	target, err := url.Parse(targetURL)
	if err != nil {
		return fmt.Errorf("failed to parse target url: %w", err)
	}

	delegator, err := url.Parse(delegatorURL)
	if err != nil {
		return fmt.Errorf("failed to parse proxy url: %w", err)
	}

	p := New(delegator, target)

	go func() {
		// Send reload event 5s after restarting the proxy server
		time.Sleep(reloadDelay)
		p.SendSSE("message", "reload")
	}()

	// go func() {
	// 	fmt.Fprintf(w, "Opening URL: %s\n", p.Delegator.String())
	// 	if err := openURL(w, p.Delegator.String()); err != nil {
	// 		fmt.Fprintf(w, "Error opening URL: %v\n", err)
	// 	}
	// }()

	// fmt.Fprintf(w, "Proxying from %s to target: %s\n", p.Delegator.String(), p.Target.String())
	proxyURL := color.Green(fmt.Sprintf("http://%s", p.Delegator.Host))
	color.Printf("Proxy started @ %s\n", proxyURL)
	if err := http.ListenAndServe(delegator.Host, p); err != nil {
		fmt.Printf("Error starting proxy: %v\n", err)
	}

	return nil
}
