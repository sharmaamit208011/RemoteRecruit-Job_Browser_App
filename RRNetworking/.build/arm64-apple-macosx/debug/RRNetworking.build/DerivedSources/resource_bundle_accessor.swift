import Foundation

extension Foundation.Bundle {
    static let module: Bundle = {
        let mainPath = Bundle.main.bundleURL.appendingPathComponent("RRNetworking_RRNetworking.bundle").path
        let buildPath = "/Users/dinkumar10/Downloads/RemoteRecruit_iOS_v2/RRNetworking/.build/arm64-apple-macosx/debug/RRNetworking_RRNetworking.bundle"

        let preferredBundle = Bundle(path: mainPath)

        guard let bundle = preferredBundle ?? Bundle(path: buildPath) else {
            // Users can write a function called fatalError themselves, we should be resilient against that.
            Swift.fatalError("could not load resource bundle: from \(mainPath) or \(buildPath)")
        }

        return bundle
    }()
}