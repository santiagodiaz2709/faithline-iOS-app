import UIKit
import StoreKit

final class ReviewManager {

    static let shared = ReviewManager()

    private let engagementCountKey = "review_positive_engagement_count"
    private let lastPromptDateKey = "review_last_prompt_date"
    private let lastPromptVersionKey = "review_last_prompt_version"

    private let minimumEngagementCount = 3
    private let minimumDaysBetweenPrompts = 7

    private init() {}

    func trackPositiveEngagement(from viewController: UIViewController?) {
        let count = UserDefaults.standard.integer(forKey: engagementCountKey) + 1
        UserDefaults.standard.set(count, forKey: engagementCountKey)

        guard shouldRequestReview(count: count) else { return }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.6) {
            self.requestNativeReviewPrompt(from: viewController)
        }
    }

    func requestNativeReviewPrompt(from viewController: UIViewController?) {
        DispatchQueue.main.async {
            guard let scene = viewController?.view.window?.windowScene ??
                    UIApplication.shared.connectedScenes
                        .first(where: { $0.activationState == .foregroundActive }) as? UIWindowScene
            else { return }

            SKStoreReviewController.requestReview(in: scene)

            UserDefaults.standard.set(Date(), forKey: self.lastPromptDateKey)

            let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
            UserDefaults.standard.set(version, forKey: self.lastPromptVersionKey)
        }
    }

    func openAppStoreReviewPage() {
        guard let url = URL(string: "itms-apps://itunes.apple.com/app/id6759672567?action=write-review") else {
            return
        }

        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }

    private func shouldRequestReview(count: Int) -> Bool {
        guard count >= minimumEngagementCount else { return false }

        let currentVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? ""
        let lastPromptVersion = UserDefaults.standard.string(forKey: lastPromptVersionKey)

        if lastPromptVersion == currentVersion {
            return false
        }

        if let lastDate = UserDefaults.standard.object(forKey: lastPromptDateKey) as? Date {
            let days = Calendar.current.dateComponents([.day], from: lastDate, to: Date()).day ?? 0
            if days < minimumDaysBetweenPrompts {
                return false
            }
        }

        return true
    }
}
