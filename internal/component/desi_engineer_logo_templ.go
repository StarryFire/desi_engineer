// Code generated by templ - DO NOT EDIT.

// templ: version: v0.2.501
package component

//lint:file-ignore SA4006 This context is only used if a nested component is present.

import "github.com/a-h/templ"
import "context"
import "io"
import "bytes"

type DesiEngineerLogoProps struct {
	Class string
}

func DesiEngineerLogo(props DesiEngineerLogoProps) templ.Component {
	return templ.ComponentFunc(func(ctx context.Context, templ_7745c5c3_W io.Writer) (templ_7745c5c3_Err error) {
		templ_7745c5c3_Buffer, templ_7745c5c3_IsBuffer := templ_7745c5c3_W.(*bytes.Buffer)
		if !templ_7745c5c3_IsBuffer {
			templ_7745c5c3_Buffer = templ.GetBuffer()
			defer templ.ReleaseBuffer(templ_7745c5c3_Buffer)
		}
		ctx = templ.InitializeContext(ctx)
		templ_7745c5c3_Var1 := templ.GetChildren(ctx)
		if templ_7745c5c3_Var1 == nil {
			templ_7745c5c3_Var1 = templ.NopComponent
		}
		ctx = templ.ClearChildren(ctx)
		var templ_7745c5c3_Var2 = []any{props.Class}
		templ_7745c5c3_Err = templ.RenderCSSItems(ctx, templ_7745c5c3_Buffer, templ_7745c5c3_Var2...)
		if templ_7745c5c3_Err != nil {
			return templ_7745c5c3_Err
		}
		_, templ_7745c5c3_Err = templ_7745c5c3_Buffer.WriteString("<svg class=\"")
		if templ_7745c5c3_Err != nil {
			return templ_7745c5c3_Err
		}
		_, templ_7745c5c3_Err = templ_7745c5c3_Buffer.WriteString(templ.EscapeString(templ.CSSClasses(templ_7745c5c3_Var2).String()))
		if templ_7745c5c3_Err != nil {
			return templ_7745c5c3_Err
		}
		_, templ_7745c5c3_Err = templ_7745c5c3_Buffer.WriteString("\" viewBox=\"0 0 479 80\" fill=\"none\" xmlns=\"http://www.w3.org/2000/svg\"><path fill-rule=\"evenodd\" clip-rule=\"evenodd\" stroke=\"currentColor\" fill=\"currentColor\" d=\"M169.051 3.41642L172.468 0L175.849 3.38102L179.23 0L182.611 3.38102L185.992 0L189.373 3.38102L192.754 0L196.135 3.38102L199.516 0L202.897 3.38102L206.278 0L209.695 3.41642L206.278 6.83283L202.897 3.45181L199.516 6.83283L196.135 3.45181L192.754 6.83283L189.373 3.45181L185.992 6.83283L182.611 3.45182L179.23 6.83283L175.849 3.45181L172.503 6.79744L175.884 10.1785L172.503 13.5596L175.884 16.9408L172.503 20.3219L175.884 23.7029L172.503 27.0839L175.884 30.4649L172.503 33.846L175.849 37.1916L179.23 33.8106L182.611 37.1916L185.992 33.8106L189.373 37.1916L192.754 33.8106L196.17 37.227L192.754 40.6434L189.373 37.2624L185.992 40.6434L182.611 37.2624L179.23 40.6434L175.849 37.2624L172.503 40.6082L175.884 43.9893L172.503 47.3704L175.884 50.7514L172.503 54.1324L175.884 57.5135L172.504 60.8942L175.849 64.2395L179.23 60.8585L182.611 64.2395L185.992 60.8585L189.373 64.2395L192.754 60.8585L196.135 64.2395L199.516 60.8585L202.897 64.2395L206.278 60.8585L209.695 64.2749L206.278 67.6913L202.897 64.3103L199.516 67.6913L196.135 64.3103L192.754 67.6913L189.373 64.3103L185.992 67.6913L182.611 64.3103L179.23 67.6913L175.849 64.3103L172.468 67.6913L169.051 64.2749L172.432 60.8942L169.051 57.5135L172.432 54.1324L169.051 50.7514L172.432 47.3704L169.051 43.9893L172.433 40.6082L169.087 37.2624L165.706 40.6434L162.325 37.2623L158.944 40.6434L155.563 37.2625L152.182 40.6434L148.801 37.2623L145.42 40.6434L142.038 37.2624L138.657 40.6434L135.276 37.2624L131.895 40.6434L128.514 37.2624L125.133 40.6434L121.752 37.2625L118.371 40.6434L114.99 37.2623L111.609 40.6434L108.228 37.2625L104.847 40.6434L101.466 37.2624L98.0853 40.6434L94.7043 37.2624L91.3233 40.6434L87.9422 37.2624L84.5612 40.6434L81.1801 37.2623L77.799 40.6434L74.418 37.2625L71.0371 40.6434L67.6561 37.2624L64.275 40.6434L60.8939 37.2623L57.5128 40.6434L54.1318 37.2624L50.7508 40.6434L47.3698 37.2624L43.9887 40.6434L40.6077 37.2624L37.2267 40.6434L33.8456 37.2624L30.4646 40.6434L27.0836 37.2624L23.7026 40.6434L20.3215 37.2624L16.9405 40.6434L13.5596 37.2625L10.1786 40.6434L6.79752 37.2623L3.41642 40.6434L0 37.227L3.41642 33.8106L6.79752 37.1917L10.1786 33.8106L13.5596 37.1915L16.9405 33.8106L20.3215 37.1916L23.7026 33.8106L27.0836 37.1916L30.4646 33.8106L33.8456 37.1916L37.2267 33.8106L40.6077 37.1916L43.9887 33.8106L47.3698 37.1916L50.7508 33.8106L54.1318 37.1916L57.5128 33.8106L60.8939 37.1917L64.275 33.8106L67.6561 37.1916L71.0371 33.8106L74.418 37.1915L77.799 33.8106L81.1801 37.1917L84.5612 33.8106L87.9422 37.1916L91.3233 33.8106L94.7043 37.1916L98.0853 33.8106L101.466 37.1916L104.847 33.8106L108.228 37.1915L111.609 33.8106L114.99 37.1917L118.371 33.8106L121.752 37.1915L125.133 33.8106L128.514 37.1916L131.895 33.8106L135.276 37.1916L138.657 33.8106L142.038 37.1916L145.42 33.8106L148.801 37.1917L152.182 33.8106L155.563 37.1915L158.944 33.8106L162.325 37.1917L165.706 33.8106L169.087 37.1916L172.432 33.846L169.051 30.4649L172.432 27.0839L169.051 23.7029L172.432 20.3219L169.051 16.9408L172.433 13.5596L169.051 10.1785L172.432 6.79744L169.051 3.41642ZM212.781 41.8991V66.0493H222.441V46.7291H236.931V66.0493H246.591V46.7291H241.761V41.8991H212.781ZM256.251 66.0493V70.8793H280.401V66.0493H285.231V41.8991H256.251V46.7291H251.421V56.3892H256.251V61.2193H275.571V66.0493H256.251ZM275.571 56.3892H261.081V46.7291H275.571V56.3892ZM304.551 32.239V37.0691H314.211V32.239H304.551ZM294.891 61.2193V66.0493H323.871V61.2193H314.211V41.8991H299.721V46.7291H304.551V61.2193H294.891ZM328.702 41.8991V66.0493H338.362V46.7291H352.852V66.0493H362.512V46.7291H357.682V41.8991H328.702ZM372.172 61.2193V66.0493H396.322V61.2193H377.002V56.3892H401.152V46.7291H396.322V41.8991H372.172V46.7291H367.342V61.2193H372.172ZM391.492 51.5592H377.002V46.7291H391.492V51.5592ZM410.812 61.2193V66.0493H434.962V61.2193H415.642V56.3892H439.792V46.7291H434.962V41.8991H410.812V46.7291H405.982V61.2193H410.812ZM430.132 51.5592H415.642V46.7291H430.132V51.5592ZM463.943 46.7291H459.113V41.8991H449.452V66.0493H459.113V51.5592H463.943V46.7291ZM463.943 46.7291V41.8991H478.433V46.7291H463.943ZM14.7094 45.7634V79.5737H38.8596V74.7437H43.6897V69.9136H48.5197V55.4235H43.6897V50.5935H38.8596V45.7634H14.7094ZM34.0296 74.7437H24.3695V50.5935H34.0296V55.4235H38.8596V69.9136H34.0296V74.7437ZM53.3498 45.7634V79.5737H87.16V74.7437H63.0098V65.0836H82.33V60.2536H63.0098V50.5935H87.16V45.7634H53.3498ZM96.8201 74.7437V79.5737H120.97V74.7437H125.8V65.0836H120.97V60.2536H101.65V50.5935H116.14V55.4235H125.8V50.5935H120.97V45.7634H96.8201V50.5935H91.9901V60.2536H96.8201V65.0836H116.14V74.7437H101.65V69.9136H91.9901V74.7437H96.8201ZM135.46 74.7437V79.5737H164.441V74.7437H154.781V50.5935H164.441V45.7634H135.46V50.5935H145.12V74.7437H135.46Z\"></path></svg>")
		if templ_7745c5c3_Err != nil {
			return templ_7745c5c3_Err
		}
		if !templ_7745c5c3_IsBuffer {
			_, templ_7745c5c3_Err = templ_7745c5c3_Buffer.WriteTo(templ_7745c5c3_W)
		}
		return templ_7745c5c3_Err
	})
}