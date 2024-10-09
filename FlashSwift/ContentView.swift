import SwiftUI
import WebKit
import GCDWebServer

struct ContentView: View {
    var body: some View {
        WebView()
            .edgesIgnoringSafeArea(.all) // Make the web view full-screen
            .onAppear {
                // Lock orientation to landscape when view appears
                UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
                AppDelegate.orientationLock = .landscape
            }
            .onDisappear {
                // Reset orientation lock when view disappears
                AppDelegate.orientationLock = .all
            }
    }
}

struct WebView: UIViewRepresentable {
    let webServer = GCDWebServer()

    func makeUIView(context: Context) -> WKWebView {
        let webView = WKWebView()
        webView.navigationDelegate = context.coordinator

        // Start the local web server
        startWebServer()

        // Set the navigation delegate to capture console messages
        webView.configuration.userContentController.add(context.coordinator, name: "consoleHandler")
        webView.configuration.preferences.setValue(true, forKey: "developerExtrasEnabled")

        // Enable JavaScript
        let preferences = WKWebpagePreferences()
        preferences.allowsContentJavaScript = true
        webView.configuration.defaultWebpagePreferences = preferences

        // Disable scroll
        webView.scrollView.isScrollEnabled = false

        // Load the HTML content from the local server
        if let url = URL(string: "http://localhost:8080/index.html") {
            let request = URLRequest(url: url)
            print("Loading URL: \(url.absoluteString)")
            webView.load(request)
        } else {
            print("Error: Failed to create URL for index.html")
        }

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // Update the web view if needed
    }

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    class Coordinator: NSObject, WKNavigationDelegate, WKScriptMessageHandler {
        func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
            print("JavaScript console: \(message.body)")
        }
    }

    private func startWebServer() {
        if let resourcePath = Bundle.main.resourcePath {
            webServer.addGETHandler(forBasePath: "/", directoryPath: resourcePath, indexFilename: "index.html", cacheAge: 3600, allowRangeRequests: true)
        }
        do {
            try webServer.start(options: [
                GCDWebServerOption_Port: 8080,
                GCDWebServerOption_BindToLocalhost: true
            ])
            print("GCDWebServer started on port 8080")
        } catch {
            print("Failed to start GCDWebServer: \(error)")
        }
    }
}

// AppDelegate to control orientation lock
class AppDelegate: UIResponder, UIApplicationDelegate {
    static var orientationLock = UIInterfaceOrientationMask.all

    func application(_ application: UIApplication, supportedInterfaceOrientationsFor window: UIWindow?) -> UIInterfaceOrientationMask {
        return AppDelegate.orientationLock
    }
}

#Preview {
    ContentView()
}
