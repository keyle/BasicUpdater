// The Swift Programming Language
// https://docs.swift.org/swift-book

import Cocoa
import CoreText
import Foundation
import SwiftUI

private struct Updater: Codable {
    let product: String
    let version: String
    let file: String
}

let updateCheckKey = "lastUpdateCheck"

public class PackageUpdater {
    let baseUrl: String
    let backOffDays: Int

    public init(targetURL: String, backOffDays: Int) {
        self.baseUrl = targetURL
        self.backOffDays = backOffDays
    }

    @MainActor
    public func checkForUpdate() async {
        Task {
            let lastCheck = UserDefaults.standard.object(forKey: updateCheckKey) as? Date ?? Date.distantPast
            let daysAgo = Calendar.current.date(byAdding: .day, value: -1 * backOffDays, to: Date())!

            // Ensure at least a week has passed since the last check
            guard lastCheck < daysAgo else { return }

            guard let url = URL(string: "\(baseUrl)/updater.json"),
                  let updater = await self.loadUpdaterJson(at: url)
            else { return }

            if compareVersion(online: updater) {
                promptUserToUpdate(base: baseUrl, updater: updater)
            }

            UserDefaults.standard.set(Date(), forKey: updateCheckKey)
        }
    }

    private func loadUpdaterJson(at url: URL) async -> Updater? {
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            return try JSONDecoder().decode(Updater.self, from: data)
        } catch {
            print(error)
        }
        return nil
    }

    private func compareVersion(online: Updater) -> Bool {
        let appVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        return appVersion != online.version
    }

    @MainActor
    private func promptUserToUpdate(base: String, updater: Updater) {
        let alert = NSAlert()
        alert.messageText = "Update Available"
        alert.informativeText = "A new version (\(updater.version)) is available. Would you like to download it?"
        alert.alertStyle = .informational

        alert.addButton(withTitle: "Download")
        alert.addButton(withTitle: "Cancel")

        let response = alert.runModal()

        if response == .alertFirstButtonReturn {
            if let downloadURL = URL(string: "\(base)/\(updater.file)") {
                NSWorkspace.shared.open(downloadURL)
            }
        }
    }
}
