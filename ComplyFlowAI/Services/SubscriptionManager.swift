import Foundation
import StoreKit

@MainActor
final class SubscriptionManager: ObservableObject {
    enum ProductID: String, CaseIterable {
        case proMonthly = "com.complyflowai.pro.monthly"
        case proYearly = "com.complyflowai.pro.yearly"
        case businessMonthly = "com.complyflowai.business.monthly"
    }

    @Published private(set) var products: [Product] = []
    @Published private(set) var purchasedProductIDs: Set<String> = []
    @Published private(set) var currentPlan: SubscriptionPlan = .free
    @Published private(set) var renewsAt: Date?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private var updatesTask: Task<Void, Never>?

    var isActive: Bool {
        currentPlan != .free
    }

    var subscriptionStatusText: String {
        guard isActive else { return "Free plan" }
        if let renewsAt {
            return "\(currentPlan.rawValue) active until \(renewsAt.formatted(date: .abbreviated, time: .omitted))"
        }
        return "\(currentPlan.rawValue) active"
    }

    func start() async {
        guard updatesTask == nil else { return }
        updatesTask = listenForTransactions()
        await loadProducts()
        await updateCustomerProductStatus()
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }
        do {
            products = try await Product.products(for: ProductID.allCases.map(\.rawValue)).sorted { $0.displayPrice < $1.displayPrice }
        } catch {
            errorMessage = "StoreKit products are not available yet. Configure the product IDs in App Store Connect or a StoreKit configuration file."
        }
    }

    func purchase(_ product: Product) async {
        isLoading = true
        defer { isLoading = false }
        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                let transaction = try checkVerified(verification)
                await transaction.finish()
                await updateCustomerProductStatus()
            case .userCancelled:
                break
            case .pending:
                errorMessage = "Purchase is pending approval."
            @unknown default:
                break
            }
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func restorePurchases() async {
        do {
            try await AppStore.sync()
            await updateCustomerProductStatus()
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func product(for id: ProductID) -> Product? {
        products.first { $0.id == id.rawValue }
    }

    private func listenForTransactions() -> Task<Void, Never> {
        Task { [weak self] in
            for await result in Transaction.updates {
                guard let self else { continue }
                do {
                    let transaction = try self.checkVerified(result)
                    await transaction.finish()
                    await self.updateCustomerProductStatus()
                } catch {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    private func updateCustomerProductStatus() async {
        var purchasedIDs: Set<String> = []
        var latestExpiration: Date?

        for await result in Transaction.currentEntitlements {
            do {
                let transaction = try checkVerified(result)
                guard transaction.revocationDate == nil else { continue }
                purchasedIDs.insert(transaction.productID)
                if let expirationDate = transaction.expirationDate {
                    latestExpiration = max(latestExpiration ?? expirationDate, expirationDate)
                }
            } catch {
                errorMessage = error.localizedDescription
            }
        }

        purchasedProductIDs = purchasedIDs
        renewsAt = latestExpiration
        if purchasedIDs.contains(ProductID.businessMonthly.rawValue) {
            currentPlan = .business
        } else if purchasedIDs.contains(ProductID.proMonthly.rawValue) || purchasedIDs.contains(ProductID.proYearly.rawValue) {
            currentPlan = .pro
        } else {
            currentPlan = .free
        }
    }

    private func checkVerified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .unverified:
            throw PurchaseVerificationError.failedVerification
        case .verified(let safe):
            return safe
        }
    }
}

private enum PurchaseVerificationError: LocalizedError {
    case failedVerification

    var errorDescription: String? {
        "The App Store could not verify this transaction."
    }
}
