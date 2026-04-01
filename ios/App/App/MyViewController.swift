import UIKit
import Capacitor
import WebKit

class MyViewController: CAPBridgeViewController, WKNavigationDelegate {

    override open func viewDidLoad() {
        super.viewDidLoad()

        guard let webView = self.webView else { return }
        webView.navigationDelegate = self
        webView.scrollView.contentInsetAdjustmentBehavior = .never
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        let js = """
        (function() {
          try {
            const desiredViewport = 'width=device-width, initial-scale=1, viewport-fit=cover';
            let meta = document.querySelector('meta[name="viewport"]');

            if (meta) {
              meta.setAttribute('content', desiredViewport);
            } else {
              meta = document.createElement('meta');
              meta.setAttribute('name', 'viewport');
              meta.setAttribute('content', desiredViewport);
              document.head.appendChild(meta);
            }

            const styleId = 'faithline-ios-safearea-fix';
            let style = document.getElementById(styleId);

            if (!style) {
              style = document.createElement('style');
              style.id = styleId;
              document.head.appendChild(style);
            }

            style.innerHTML = `
              html, body {
                margin: 0 !important;
                padding: 0 !important;
                overflow-x: hidden !important;
              }

              header, nav, .navbar, .site-header, .topbar, .header, .nav {
                padding-top: max(0px, calc(env(safe-area-inset-top, 0px) - 10px)) !important;
                box-sizing: border-box !important;
              }
            `;
          } catch (e) {
            console.log('Safe-area injection failed', e);
          }
        })();
        """

        webView.evaluateJavaScript(js) { _, error in
            if let error = error {
                print("JS/CSS injection error: \(error)")
            } else {
                print("Safe-area patch injected successfully")
            }
        }
    }
}
