import SwiftUI

public struct SPToggle: View {
    @Binding private var isOn: Bool
    private let label: String

    public init(isOn: Binding<Bool>, label: String) {
        self._isOn = isOn
        self.label = label
    }

    public var body: some View {
        Toggle(isOn: $isOn) {
            Text(label)
                .font(SpendlyFont.body())
        }
        .tint(SpendlyColors.primary)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: SpendlySpacing.lg) {
        SPToggle(isOn: .constant(true), label: "Push Notifications")
        SPToggle(isOn: .constant(false), label: "Dark Mode")
    }
    .padding()
}
