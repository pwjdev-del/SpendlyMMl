import SwiftUI

// MARK: - Tab Item

public struct SPTabItem: Identifiable {
    public let id = UUID()
    public let icon: String
    public let activeIcon: String
    public let title: String

    public init(icon: String, activeIcon: String, title: String) {
        self.icon = icon
        self.activeIcon = activeIcon
        self.title = title
    }
}

// MARK: - SPTabBar

public struct SPTabBar: View {
    private let tabs: [SPTabItem]
    @Binding private var selectedIndex: Int

    @Environment(\.colorScheme) private var colorScheme

    public init(tabs: [SPTabItem], selectedIndex: Binding<Int>) {
        self.tabs = tabs
        self._selectedIndex = selectedIndex
    }

    public var body: some View {
        HStack {
            ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        selectedIndex = index
                    }
                } label: {
                    VStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: index == selectedIndex ? tab.activeIcon : tab.icon)
                            .font(.system(size: 20))
                            .symbolRenderingMode(.monochrome)

                        Text(tab.title)
                            .font(SpendlyFont.caption())
                    }
                    .foregroundStyle(
                        index == selectedIndex
                            ? SpendlyColors.primary
                            : SpendlyColors.secondary
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.top, SpendlySpacing.sm)
        .padding(.bottom, SpendlySpacing.xs)
        .background(SpendlyColors.surface(for: colorScheme))
    }
}

// MARK: - Preview

#Preview {
    VStack {
        Spacer()
        SPTabBar(
            tabs: [
                SPTabItem(icon: "square.grid.2x2", activeIcon: "square.grid.2x2.fill", title: "Dashboard"),
                SPTabItem(icon: "doc.text", activeIcon: "doc.text.fill", title: "Jobs"),
                SPTabItem(icon: "calendar", activeIcon: "calendar", title: "Schedule"),
                SPTabItem(icon: "person", activeIcon: "person.fill", title: "Profile"),
            ],
            selectedIndex: .constant(0)
        )
    }
}
