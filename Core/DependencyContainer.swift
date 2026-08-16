import Foundation
import SwiftUI

/// 依赖注入容器
/// 统一管理 App 级别的依赖（Repository、Service、Network、Storage 等）
/// 未来扩展：在此添加新的 Repository / Service 实例
final class DependencyContainer: ObservableObject {

    // MARK: - 单例

    static let shared = DependencyContainer()

    // MARK: - 初始化

    init() {
        // 未来在此注入 Repository / Service
        // 例如：
        // self.journalRepository = SwiftDataJournalRepository()
        // self.assetRepository = LocalAssetRepository()
    }
}