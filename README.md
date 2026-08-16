# PaperCraft Journal

数字手账创作工具 - 自由排版、素材系统、模板系统、作品社区。

## 产品定位

数字手账创作工具，而不是日记 App。

### 核心能力
- 自由排版 Canvas
- 胶带、贴纸、印章、画笔等素材系统
- 模板系统
- 作品社区
- 后续支持 AI 自动排版

## 技术栈

- Swift
- SwiftUI
- MVVM
- SwiftData
- async/await
- Repository Pattern
- Dependency Injection

## 架构

Feature-based Architecture，高扩展性，支持长期维护，为 Canvas Engine 预留能力。

```
PaperCraftJournal/
├── Core/                    # 核心基础设施 ✅
│   ├── DependencyContainer  # 依赖注入容器
│   └── DesignSystem/        # 设计系统（颜色、字体、间距、组件）
├── Views/                   # 主界面视图 ✅
│   ├── ContentView          # 画布 + 元素层 + 底部工具栏
│   ├── ScrapbookElementView # 元素视图（拖拽 / 缩放 / 旋转手势）
│   ├── ScrapbookElementRenders # 元素渲染（贴纸 / 照片 / 文字 / 胶带）
│   ├── ScrapbookToolbar     # 工具栏
│   └── RootView             # 根视图
├── ViewModels/              # 视图模型 ✅
│   └── ScrapbookViewModel   # 元素集合、层级、选中状态
├── Models/                  # 数据模型 ✅
│   └── ScrapbookElement     # 元素协议 + 贴纸 / 文字 / 胶带
├── Services/                # 服务层（规划中）
├── Template/                # 模板功能模块（规划中）
│   ├── Views/
│   ├── Models/
│   └── Services/
├── Community/               # 社区功能模块（规划中）
│   ├── Views/
│   ├── ViewModels/
│   └── Services/
├── Profile/                 # 个人中心模块（规划中）
│   └── Views/
├── Domain/                  # 领域层（规划中）
│   ├── Entities/
│   ├── UseCases/
│   └── RepositoryInterfaces/
├── Data/                    # 数据层（规划中）
│   ├── API/
│   ├── LocalStorage/
│   ├── Repository/
│   └── DTO/
├── Resources/               # 资源文件
│   ├── Assets.xcassets/
│   ├── Stickers/
│   ├── Templates/
│   ├── Fonts/
│   └── Sounds/
└── Tests/
```

> `✅` = 当前已实现，`规划中` = 架构预留，待后续迭代填充。

## 当前已实现功能

- **自由排版画布**：纸张纹理背景 + 自由元素层，元素按 zIndex 控制层级，拖拽松手后自动置顶
- **四类元素**：符号贴纸（星形 / 心形 / 火花 / 猫）、照片贴纸、剪切贴纸（不规则形状）、文字块、和纸胶带
- **手势交互**：
  - 拖拽：`DragGesture(minimumDistance: 0)` 点到即拖，手势中只更新 `@GestureState`，松手才保存并置顶
  - 缩放 / 旋转：双指 `MagnificationGesture` / `RotationGesture`，与拖拽并行识别
- **选中管理**：
  - 按下元素即选中；缩放 / 旋转开始同样触发选中
  - 点击或拖拽画布空白处清空选中（空白层 `DragGesture(minimumDistance: 0)`）
  - 元素命中区贴合可见内容（`contentShape` 位于 `position` 之前），重叠时由 zIndex 决定上层优先
- **工具栏**：添加贴纸 / 文字 / 胶带 / 照片 / 剪切贴纸（PhotosPicker）

## 开发进度

### Phase 1 ✅ 基础架构搭建
- [x] 创建 Feature-based 目录结构
- [x] 重构 App 入口（只负责依赖初始化与启动）
- [x] 创建 DependencyContainer（依赖注入容器）
- [x] 创建 RootView（根视图）
- [x] 创建基础 DesignSystem（颜色、字体、间距、按钮、卡片）

### Phase 2 ✅ Editor 基础骨架
- [x] CanvasDocument（ScrapbookViewModel 管理元素集合与层级）
- [x] CanvasElement（`ScrapbookElement` 协议 + 贴纸 / 文字 / 胶带模型）
- [x] ElementType（`ScrapbookElementType` 枚举）
- [x] CanvasView（ContentView 画布 + 元素层 + 底部工具栏）
- [x] EditorViewModel（ScrapbookViewModel）
- [x] 元素渲染（贴纸 / 照片 / 剪切贴纸 / 文字 / 和纸胶带）
- [x] 手势交互（拖拽 / 缩放 / 旋转、选中管理、置顶）

### Phase 3 ⏳ Repository 层
- [ ] JournalRepository
- [ ] SwiftData 基础
- [ ] 本地保存接口

### Phase 4 ⏳ Asset Library
- [ ] Asset 模型
- [ ] AssetRepository
- [ ] 素材读取

## 快速开始

1. 使用 Xcode 打开 `PaperCraftJournal.xcodeproj`
2. 选择模拟器或真机
3. Run

## License

MIT