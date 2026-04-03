import SwiftUI

// MARK: - Column Definition

public struct SPDataColumn: Identifiable {
    public let id = UUID()
    public let header: String
    public let alignment: HorizontalAlignment
    public let width: CGFloat?

    public init(
        header: String,
        alignment: HorizontalAlignment = .leading,
        width: CGFloat? = nil
    ) {
        self.header = header
        self.alignment = alignment
        self.width = width
    }
}

// MARK: - Row

public struct SPDataRow: Identifiable {
    public let id = UUID()
    public let cells: [String]

    public init(cells: [String]) {
        self.cells = cells
    }
}

// MARK: - SPDataTable

public struct SPDataTable: View {
    private let columns: [SPDataColumn]
    private let rows: [SPDataRow]

    @Environment(\.colorScheme) private var colorScheme

    public init(columns: [SPDataColumn], rows: [SPDataRow]) {
        self.columns = columns
        self.rows = rows
    }

    public var body: some View {
        VStack(spacing: 0) {
            // Header row
            HStack(spacing: 0) {
                ForEach(columns) { column in
                    cellContent(column.header, alignment: column.alignment, isHeader: true)
                        .frame(maxWidth: column.width ?? .infinity, alignment: textAlignment(column.alignment))
                }
            }
            .padding(.vertical, SpendlySpacing.sm)
            .background(SpendlyColors.background(for: colorScheme))

            SPDivider()

            // Data rows
            ForEach(rows) { row in
                HStack(spacing: 0) {
                    ForEach(Array(zip(columns.indices, columns)), id: \.0) { index, column in
                        let cellText = index < row.cells.count ? row.cells[index] : ""
                        cellContent(cellText, alignment: column.alignment, isHeader: false)
                            .frame(maxWidth: column.width ?? .infinity, alignment: textAlignment(column.alignment))
                    }
                }
                .padding(.vertical, SpendlySpacing.sm)

                SPDivider()
            }
        }
    }

    private func cellContent(_ text: String, alignment: HorizontalAlignment, isHeader: Bool) -> some View {
        Text(text)
            .font(isHeader ? SpendlyFont.bodySemibold() : SpendlyFont.body())
            .foregroundStyle(
                isHeader
                    ? SpendlyColors.secondaryForeground(for: colorScheme)
                    : SpendlyColors.foreground(for: colorScheme)
            )
            .padding(.horizontal, SpendlySpacing.sm)
            .monospacedDigit()
    }

    private func textAlignment(_ alignment: HorizontalAlignment) -> Alignment {
        switch alignment {
        case .trailing: return .trailing
        case .center:   return .center
        default:        return .leading
        }
    }
}

// MARK: - Preview

#Preview {
    SPDataTable(
        columns: [
            SPDataColumn(header: "Invoice"),
            SPDataColumn(header: "Client"),
            SPDataColumn(header: "Amount", alignment: .trailing),
            SPDataColumn(header: "Status"),
        ],
        rows: [
            SPDataRow(cells: ["INV-001", "Acme Corp", "$1,250.00", "Paid"]),
            SPDataRow(cells: ["INV-002", "Globex", "$3,400.00", "Pending"]),
            SPDataRow(cells: ["INV-003", "Wayne Ent.", "$890.50", "Overdue"]),
        ]
    )
    .padding()
}
