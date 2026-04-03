import SwiftUI

// MARK: - Timeline Item

public struct SPTimelineItem: Identifiable {
    public let id = UUID()
    public let title: String
    public let subtitle: String?
    public let status: SPTimelineStatus
    public let time: String

    public init(title: String, subtitle: String? = nil, status: SPTimelineStatus = .default, time: String) {
        self.title = title
        self.subtitle = subtitle
        self.status = status
        self.time = time
    }
}

public enum SPTimelineStatus {
    case completed
    case active
    case upcoming
    case `default`

    var dotColor: Color {
        switch self {
        case .completed: return SpendlyColors.success
        case .active:    return SpendlyColors.primary
        case .upcoming:  return SpendlyColors.secondary.opacity(0.4)
        case .default:   return SpendlyColors.secondary
        }
    }
}

// MARK: - SPTimeline

public struct SPTimeline: View {
    private let items: [SPTimelineItem]

    @Environment(\.colorScheme) private var colorScheme

    public init(items: [SPTimelineItem]) {
        self.items = items
    }

    public var body: some View {
        VStack(spacing: 0) {
            ForEach(Array(items.enumerated()), id: \.element.id) { index, item in
                HStack(alignment: .top, spacing: SpendlySpacing.md) {
                    // Dot & line
                    VStack(spacing: 0) {
                        Circle()
                            .fill(item.status.dotColor)
                            .frame(width: 10, height: 10)
                            .padding(.top, 5)

                        if index < items.count - 1 {
                            Rectangle()
                                .fill(SpendlyColors.secondary.opacity(0.2))
                                .frame(width: 2)
                                .frame(minHeight: 40)
                        }
                    }
                    .frame(width: 10)

                    // Content
                    VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                        HStack {
                            Text(item.title)
                                .font(SpendlyFont.bodyMedium())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Spacer()
                            Text(item.time)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }

                        if let subtitle = item.subtitle {
                            Text(subtitle)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        }
                    }
                    .padding(.bottom, SpendlySpacing.lg)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SPTimeline(items: [
        SPTimelineItem(title: "Job Created", subtitle: "Work order #1024", status: .completed, time: "9:00 AM"),
        SPTimelineItem(title: "Technician Assigned", subtitle: "John D.", status: .completed, time: "9:15 AM"),
        SPTimelineItem(title: "En Route", status: .active, time: "10:00 AM"),
        SPTimelineItem(title: "Job Completed", status: .upcoming, time: "Pending"),
    ])
    .padding()
}
