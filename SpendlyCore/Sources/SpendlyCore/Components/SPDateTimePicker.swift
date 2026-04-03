import SwiftUI

// MARK: - Picker Mode

public enum SPDateTimePickerMode {
    case date
    case time
    case dateAndTime

    var components: DatePickerComponents {
        switch self {
        case .date:        return .date
        case .time:        return .hourAndMinute
        case .dateAndTime: return [.date, .hourAndMinute]
        }
    }
}

// MARK: - SPDateTimePicker

public struct SPDateTimePicker: View {
    @Binding private var selection: Date
    private let mode: SPDateTimePickerMode
    private let label: String

    @Environment(\.colorScheme) private var colorScheme

    public init(
        _ label: String = "",
        selection: Binding<Date>,
        mode: SPDateTimePickerMode = .dateAndTime
    ) {
        self.label = label
        self._selection = selection
        self.mode = mode
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            if !label.isEmpty {
                Text(label)
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }

            DatePicker(
                "",
                selection: $selection,
                displayedComponents: mode.components
            )
            .datePickerStyle(.compact)
            .labelsHidden()
            .tint(SpendlyColors.primary)
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: SpendlySpacing.xl) {
        SPDateTimePicker("Start Date", selection: .constant(Date()), mode: .date)
        SPDateTimePicker("Time", selection: .constant(Date()), mode: .time)
        SPDateTimePicker("Date & Time", selection: .constant(Date()), mode: .dateAndTime)
    }
    .padding()
}
