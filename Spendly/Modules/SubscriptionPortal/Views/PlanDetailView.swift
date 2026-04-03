import SwiftUI
import SpendlyCore

struct PlanDetailView: View {
    let plan: SubscriptionPlan
    @Bindable var viewModel: SubscriptionPortalViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {

                // MARK: - Plan Header
                VStack(spacing: SpendlySpacing.sm) {
                    if plan.isPopular {
                        SPBadge("Most Popular", style: .custom(SpendlyColors.primary))
                    }

                    Text(plan.name)
                        .font(SpendlyFont.largeTitle())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Text(viewModel.planPrice(plan))
                        .font(SpendlyFont.title())
                        .foregroundStyle(SpendlyColors.primary)
                    + Text(" /mo")
                        .font(SpendlyFont.body())
                        .foregroundStyle(SpendlyColors.secondary)

                    if viewModel.isAnnualToggle {
                        Text("Save \(viewModel.annualSavingsForPlan(plan)) per year")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.success)
                    }
                }
                .frame(maxWidth: .infinity)
                .padding(SpendlySpacing.lg)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))

                // MARK: - Capacity
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Capacity")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    HStack(spacing: SpendlySpacing.lg) {
                        Label("\(plan.maxTechnicians) Technicians", systemImage: "person.3")
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Spacer()
                        Label("\(plan.storageGB) GB Storage", systemImage: "externaldrive")
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                }
                .padding(SpendlySpacing.md)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))

                // MARK: - Features
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Included Features")
                        .font(SpendlyFont.headline())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    ForEach(plan.features, id: \.self) { feature in
                        HStack(spacing: SpendlySpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(SpendlyColors.success)
                                .font(.body)
                            Text(feature)
                                .font(SpendlyFont.body())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        }
                    }
                }
                .padding(SpendlySpacing.md)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))

                // MARK: - Action
                Button {
                    // In production: navigate to upgrade flow
                } label: {
                    Text("Select \(plan.name) Plan")
                        .font(SpendlyFont.headline())
                        .frame(maxWidth: .infinity)
                        .padding(SpendlySpacing.sm)
                }
                .buttonStyle(.borderedProminent)
                .tint(SpendlyColors.primary)
            }
            .padding(SpendlySpacing.md)
        }
        .background(SpendlyColors.background(for: colorScheme))
        .navigationTitle(plan.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}
