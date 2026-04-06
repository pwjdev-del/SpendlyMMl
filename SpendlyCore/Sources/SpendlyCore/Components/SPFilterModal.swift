import SwiftUI

// MARK: - Filter Section Types

public enum SPFilterType {
    case checkbox
    case radio
    case dateRange
    case range(min: Double, max: Double)
    case dropdown
}

public struct SPFilterOption: Identifiable {
    public let id = UUID()
    public let label: String
    public var isSelected: Bool

    public init(label: String, isSelected: Bool = false) {
        self.label = label
        self.isSelected = isSelected
    }
}

public struct SPFilterSection: Identifiable {
    public let id = UUID()
    public let title: String
    public let type: SPFilterType
    public var options: [SPFilterOption]
    public var rangeValue: Double?

    public init(title: String, type: SPFilterType, options: [SPFilterOption], rangeValue: Double? = nil) {
        self.title = title
        self.type = type
        self.options = options
        self.rangeValue = rangeValue
    }
}

// MARK: - SPFilterModal

public struct SPFilterModal: View {
    @Binding private var isPresented: Bool
    @Binding private var sections: [SPFilterSection]

    @Environment(\.colorScheme) private var colorScheme
    @State private var dateFrom: Date = Date()
    @State private var dateTo: Date = Date()
    public init(
        isPresented: Binding<Bool>,
        sections: Binding<[SPFilterSection]>
    ) {
        self._isPresented = isPresented
        self._sections = sections
    }

    public var body: some View {
        ZStack(alignment: .bottom) {
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .onTapGesture {
                        withAnimation(.easeInOut(duration: 0.25)) {
                            isPresented = false
                        }
                    }

                VStack(spacing: 0) {
                    // Handle + Header
                    VStack(spacing: SpendlySpacing.md) {
                        Capsule()
                            .fill(SpendlyColors.secondary.opacity(0.3))
                            .frame(width: 36, height: 5)
                            .padding(.top, SpendlySpacing.sm)

                        HStack {
                            Text("Filters")
                                .font(SpendlyFont.headline())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                            Spacer()

                            Button("Reset") {
                                resetFilters()
                            }
                            .font(SpendlyFont.bodyMedium())
                            .foregroundStyle(SpendlyColors.accent)
                        }
                        .padding(.horizontal, SpendlySpacing.lg)
                    }

                    SPDivider()
                        .padding(.vertical, SpendlySpacing.sm)

                    // Sections
                    ScrollView {
                        VStack(alignment: .leading, spacing: SpendlySpacing.xl) {
                            ForEach($sections) { $section in
                                filterSectionView(section: $section)
                            }
                        }
                        .padding(.horizontal, SpendlySpacing.lg)
                        .padding(.bottom, SpendlySpacing.lg)
                    }
                    .frame(maxHeight: 400)

                    // Apply button
                    SPButton("Apply Filters", icon: SpendlyIcon.checkCircle.systemName, style: .primary) {
                        withAnimation {
                            isPresented = false
                        }
                    }
                    .padding(.horizontal, SpendlySpacing.lg)
                    .padding(.bottom, SpendlySpacing.xxl)
                }
                .frame(maxWidth: .infinity)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(
                    UnevenRoundedRectangle(
                        topLeadingRadius: SpendlyRadius.xl,
                        topTrailingRadius: SpendlyRadius.xl,
                        style: .continuous
                    )
                )
                .transition(.move(edge: .bottom).combined(with: .opacity))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isPresented)
        .ignoresSafeArea(edges: .bottom)
    }

    @ViewBuilder
    private func filterSectionView(section: Binding<SPFilterSection>) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Text(section.wrappedValue.title)
                .font(SpendlyFont.bodySemibold())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            switch section.wrappedValue.type {
            case .checkbox:
                ForEach(section.options) { $option in
                    checkboxRow(option: $option)
                }

            case .radio:
                ForEach(section.options) { $option in
                    radioRow(option: $option, section: section)
                }

            case .dateRange:
                HStack(spacing: SpendlySpacing.md) {
                    VStack(alignment: .leading) {
                        Text("From")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                        DatePicker("", selection: $dateFrom, displayedComponents: .date)
                            .labelsHidden()
                    }
                    VStack(alignment: .leading) {
                        Text("To")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                        DatePicker("", selection: $dateTo, displayedComponents: .date)
                            .labelsHidden()
                    }
                }

            case .range(let min, let max):
                VStack {
                    Slider(
                        value: Binding(
                            get: { section.wrappedValue.rangeValue ?? min },
                            set: { section.wrappedValue.rangeValue = $0 }
                        ),
                        in: min...max
                    )
                    .tint(SpendlyColors.primary)
                    HStack {
                        Text(String(format: "%.0f", min))
                            .font(SpendlyFont.caption())
                        Spacer()
                        Text(String(format: "%.0f", section.wrappedValue.rangeValue ?? min))
                            .font(SpendlyFont.bodyMedium())
                            .foregroundStyle(SpendlyColors.primary)
                        Spacer()
                        Text(String(format: "%.0f", max))
                            .font(SpendlyFont.caption())
                    }
                    .foregroundStyle(SpendlyColors.secondary)
                }

            case .dropdown:
                Menu {
                    ForEach(section.options) { $option in
                        Button {
                            option.isSelected.toggle()
                        } label: {
                            HStack {
                                Text(option.label)
                                if option.isSelected {
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                } label: {
                    HStack {
                        Text(selectedLabel(for: section.wrappedValue))
                            .font(SpendlyFont.body())
                        Spacer()
                        Image(systemName: "chevron.down")
                            .font(.system(size: 12))
                    }
                    .padding(SpendlySpacing.md)
                    .background(SpendlyColors.background(for: colorScheme))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                }
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
            }
        }
    }

    private func checkboxRow(option: Binding<SPFilterOption>) -> some View {
        Button {
            option.wrappedValue.isSelected.toggle()
        } label: {
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: option.wrappedValue.isSelected ? "checkmark.square.fill" : "square")
                    .foregroundStyle(option.wrappedValue.isSelected ? SpendlyColors.primary : SpendlyColors.secondary)
                Text(option.wrappedValue.label)
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
            }
            .padding(.vertical, SpendlySpacing.xs)
        }
    }

    private func radioRow(option: Binding<SPFilterOption>, section: Binding<SPFilterSection>) -> some View {
        Button {
            for i in section.wrappedValue.options.indices {
                section.wrappedValue.options[i].isSelected = false
            }
            option.wrappedValue.isSelected = true
        } label: {
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: option.wrappedValue.isSelected ? "circle.inset.filled" : "circle")
                    .foregroundStyle(option.wrappedValue.isSelected ? SpendlyColors.primary : SpendlyColors.secondary)
                Text(option.wrappedValue.label)
                    .font(SpendlyFont.body())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
            }
            .padding(.vertical, SpendlySpacing.xs)
        }
    }

    private func selectedLabel(for section: SPFilterSection) -> String {
        let selected = section.options.filter(\.isSelected).map(\.label)
        return selected.isEmpty ? "Select..." : selected.joined(separator: ", ")
    }

    private func resetFilters() {
        for sectionIndex in sections.indices {
            for optionIndex in sections[sectionIndex].options.indices {
                sections[sectionIndex].options[optionIndex].isSelected = false
            }
            sections[sectionIndex].rangeValue = nil
        }
    }
}

// MARK: - Preview

#Preview {
    SPFilterModal(
        isPresented: .constant(true),
        sections: .constant([
            SPFilterSection(title: "Status", type: .checkbox, options: [
                SPFilterOption(label: "Active", isSelected: true),
                SPFilterOption(label: "Pending"),
                SPFilterOption(label: "Completed"),
            ]),
            SPFilterSection(title: "Priority", type: .radio, options: [
                SPFilterOption(label: "High"),
                SPFilterOption(label: "Medium", isSelected: true),
                SPFilterOption(label: "Low"),
            ]),
        ])
    )
}
