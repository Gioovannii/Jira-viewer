import SwiftUI
import WebKit

struct OAuthWebView: NSViewRepresentable {
    let url: URL
    let onCallback: (URL) -> Void
    let onClose: () -> Void

    func makeNSView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator
        return webView
    }

    func updateNSView(_ webView: WKWebView, context: Context) {
        let request = URLRequest(url: url)
        webView.load(request)
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(onCallback: onCallback, onClose: onClose)
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        let onCallback: (URL) -> Void
        let onClose: () -> Void

        init(onCallback: @escaping (URL) -> Void, onClose: @escaping () -> Void) {
            self.onCallback = onCallback
            self.onClose = onClose
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }

            // Check if this is our OAuth callback
            if url.scheme == "jiraviewer" && url.host == "oauth-callback" {
                onCallback(url)
                onClose()
                decisionHandler(.cancel)
                return
            }

            decisionHandler(.allow)
        }
    }
}

struct OAuthLoginWindow: View {
    let oauthManager: OAuthManager
    @Environment(\.dismiss) var dismiss
    @State private var authURL: URL?
    @State private var isLoading = true

    var body: some View {
        VStack(spacing: 0) {
            if isLoading {
                ProgressView("Chargement de la page de connexion...")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }

            if let authURL = authURL {
                OAuthWebView(
                    url: authURL,
                    onCallback: { callbackURL in
                        Task {
                            await oauthManager.handleCallback(url: callbackURL)
                            dismiss()
                        }
                    },
                    onClose: {
                        dismiss()
                    }
                )
                .onAppear {
                    isLoading = false
                }
            }
        }
        .frame(width: 600, height: 800)
        .onAppear {
            authURL = oauthManager.startOAuthFlow()
        }
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Annuler") {
                    dismiss()
                }
            }
        }
    }
}
