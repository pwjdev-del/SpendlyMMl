import SwiftUI

// MARK: - Chart Type

public enum SPChartType {
    case bar
    case line
    case radar
    case pie
}

// MARK: - Chart Data Point

public struct SPChartDataPoint: Identifiable {
    public let id = UUID()
    public let label: String
    public let value: Double

    public init(label: String, value: Double) {
        self.label = label
        self.value = value
    }
}

// MARK: - SPChartCard

public struct SPChartCard: View {
    private let title: String
    private let chartType: SPChartType
    private let data: [SPChartDataPoint]

    @Environment(\.colorScheme) private var colorScheme

    public init(
        title: String,
        chartType: SPChartType = .bar,
        data: [SPChartDataPoint]
    ) {
        self.title = title
        self.chartType = chartType
        self.data = data
    }

    public var body: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                Text(title)
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                chartContent
                    .frame(height: 180)
            }
        }
    }

    @ViewBuilder
    private var chartContent: some View {
        switch chartType {
        case .bar:
            barChart
        case .line:
            lineChart
        case .pie:
            pieChart
        case .radar:
            radarPlaceholder
        }
    }

    // MARK: Bar Chart

    private var barChart: some View {
        let maxValue = data.map(\.value).max() ?? 1
        return GeometryReader { geo in
            HStack(alignment: .bottom, spacing: SpendlySpacing.xs) {
                ForEach(data) { point in
                    VStack(spacing: SpendlySpacing.xs) {
                        RoundedRectangle(cornerRadius: SpendlyRadius.small)
                            .fill(SpendlyColors.primary)
                            .frame(
                                height: max(4, geo.size.height * 0.8 * (point.value / maxValue))
                            )

                        Text(point.label)
                            .font(.system(size: 10))
                            .foregroundStyle(SpendlyColors.secondary)
                            .lineLimit(1)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
    }

    // MARK: Line Chart

    private var lineChart: some View {
        let maxValue = data.map(\.value).max() ?? 1
        return GeometryReader { geo in
            let stepX = data.count > 1 ? geo.size.width / CGFloat(data.count - 1) : geo.size.width
            let chartHeight = geo.size.height * 0.85

            ZStack {
                // Line
                Path { path in
                    for (index, point) in data.enumerated() {
                        let x = CGFloat(index) * stepX
                        let y = chartHeight - (chartHeight * point.value / maxValue)
                        if index == 0 {
                            path.move(to: CGPoint(x: x, y: y))
                        } else {
                            path.addLine(to: CGPoint(x: x, y: y))
                        }
                    }
                }
                .stroke(SpendlyColors.primary, lineWidth: 2)

                // Dots
                ForEach(Array(data.enumerated()), id: \.element.id) { index, point in
                    let x = CGFloat(index) * stepX
                    let y = chartHeight - (chartHeight * point.value / maxValue)
                    Circle()
                        .fill(SpendlyColors.primary)
                        .frame(width: 6, height: 6)
                        .position(x: x, y: y)
                }
            }
        }
    }

    // MARK: Pie Chart

    private var pieChart: some View {
        let total = data.map(\.value).reduce(0, +)
        let colors: [Color] = [
            SpendlyColors.primary,
            SpendlyColors.accent,
            SpendlyColors.success,
            SpendlyColors.info,
            SpendlyColors.warning,
            SpendlyColors.error,
            SpendlyColors.secondary,
        ]

        return GeometryReader { geo in
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)
            let radius = min(geo.size.width, geo.size.height) / 2 * 0.85

            ZStack {
                var startAngle = Angle.degrees(-90)
                ForEach(Array(data.enumerated()), id: \.element.id) { index, point in
                    let sweep = Angle.degrees(360 * point.value / max(total, 1))
                    let endAngle = startAngle + sweep

                    Path { path in
                        path.move(to: center)
                        path.addArc(center: center, radius: radius,
                                    startAngle: startAngle, endAngle: endAngle, clockwise: false)
                        path.closeSubpath()
                    }
                    .fill(colors[index % colors.count])

                    let _ = (startAngle = endAngle)
                }
            }
        }
    }

    // MARK: Radar Placeholder

    private var radarPlaceholder: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                VStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 32))
                        .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                    Text("Radar chart placeholder")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                }
                Spacer()
            }
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: SpendlySpacing.lg) {
        SPChartCard(title: "Revenue by Month", chartType: .bar, data: [
            SPChartDataPoint(label: "Jan", value: 12),
            SPChartDataPoint(label: "Feb", value: 19),
            SPChartDataPoint(label: "Mar", value: 8),
            SPChartDataPoint(label: "Apr", value: 25),
            SPChartDataPoint(label: "May", value: 15),
        ])

        SPChartCard(title: "Trends", chartType: .line, data: [
            SPChartDataPoint(label: "W1", value: 5),
            SPChartDataPoint(label: "W2", value: 12),
            SPChartDataPoint(label: "W3", value: 8),
            SPChartDataPoint(label: "W4", value: 20),
        ])
    }
    .padding()
}
