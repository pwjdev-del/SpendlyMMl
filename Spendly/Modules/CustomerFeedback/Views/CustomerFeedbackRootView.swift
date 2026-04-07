import SwiftUI
import SpendlyCore

struct CustomerFeedbackRootView: View {
    @State private var viewModel = CustomerFeedbackViewModel()
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        SPScreenWrapper {
            VStack(spacing: 0) {
                // KPI Cards
                kpiSection

                // Tab Selector
                tabSelector

                // Content
                ScrollView {
                    LazyVStack(spacing: SpendlySpacing.sm) {
                        switch viewModel.selectedTab {
                        case .responses:
                            responsesContent
                        case .pending:
                            pendingContent
                        case .analytics:
                            analyticsContent
                        }
                    }
                    .padding(.horizontal, SpendlySpacing.md)
                    .padding(.bottom, SpendlySpacing.xxl)
                }
            }
        }
        .navigationTitle("Customer Feedback")
        .sheet(isPresented: $viewModel.showFeedbackDetail) {
            feedbackDetailSheet
        }
        .sheet(isPresented: $viewModel.showSurveyForm) {
            surveyFormSheet
        }
    }

    // MARK: - KPI Section

    private var kpiSection: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: SpendlySpacing.sm) {
                SPMetricCard(title: "CSAT Score", value: "\(viewModel.csatScore)%", trend: viewModel.csatScore >= 80 ? "Good" : "Needs Attention", trendDirection: viewModel.csatScore >= 80 ? .up : .down)
                SPMetricCard(title: "Avg Rating", value: String(format: "%.1f/5", viewModel.averageOverallRating), trend: nil, trendDirection: .flat)
                SPMetricCard(title: "NPS", value: "\(viewModel.npsScore)", trend: viewModel.npsScore >= 50 ? "Excellent" : "OK", trendDirection: viewModel.npsScore >= 50 ? .up : .flat)
                SPMetricCard(title: "Pending", value: "\(viewModel.pendingCount)", trend: viewModel.pendingCount > 0 ? "Action Needed" : nil, trendDirection: viewModel.pendingCount > 0 ? .down : .flat)
            }
            .padding(.horizontal, SpendlySpacing.md)
        }
        .padding(.vertical, SpendlySpacing.sm)
    }

    // MARK: - Tab Selector

    private var tabSelector: some View {
        HStack(spacing: SpendlySpacing.sm) {
            ForEach(FeedbackTab.allCases, id: \.self) { tab in
                Button {
                    withAnimation(.easeInOut(duration: 0.2)) {
                        viewModel.selectedTab = tab
                    }
                } label: {
                    HStack(spacing: 4) {
                        Text(tab.rawValue)
                        if tab == .pending && viewModel.pendingCount > 0 {
                            Text("\(viewModel.pendingCount)")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(.white)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 1)
                                .background(SpendlyColors.error, in: Capsule())
                        }
                    }
                    .font(SpendlyFont.bodySmall(weight: viewModel.selectedTab == tab ? .semibold : .regular))
                    .foregroundStyle(viewModel.selectedTab == tab ? .white : SpendlyColors.secondaryForeground(for: colorScheme))
                    .padding(.horizontal, SpendlySpacing.md)
                    .padding(.vertical, SpendlySpacing.xs)
                    .background(
                        viewModel.selectedTab == tab ? SpendlyColors.primary : SpendlyColors.secondaryBackground(for: colorScheme),
                        in: Capsule()
                    )
                }
            }
            Spacer()
        }
        .padding(.horizontal, SpendlySpacing.md)
        .padding(.bottom, SpendlySpacing.sm)
    }

    // MARK: - Responses Content

    private var responsesContent: some View {
        Group {
            SPSearchBar(text: $viewModel.searchText, placeholder: "Search feedback...")
                .padding(.bottom, SpendlySpacing.xs)

            if viewModel.filteredFeedback.isEmpty {
                SPEmptyState(title: "No Feedback Yet", subtitle: "Customer feedback will appear here after service completion.", icon: "star")
            } else {
                ForEach(viewModel.filteredFeedback) { feedback in
                    feedbackCard(feedback)
                }
            }
        }
    }

    private func feedbackCard(_ feedback: FeedbackDisplayModel) -> some View {
        SPCard {
            VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(feedback.customerName)
                            .font(SpendlyFont.bodySmall(weight: .semibold))
                            .foregroundStyle(SpendlyColors.primaryForeground(for: colorScheme))
                        if let ticket = feedback.ticketNumber {
                            Text(ticket)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        }
                    }
                    Spacer()
                    starsView(rating: feedback.overallRating)
                }

                Text(feedback.serviceSummary)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    .lineLimit(2)

                if let comments = feedback.comments {
                    Text("\"\(comments)\"")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        .italic()
                        .lineLimit(2)
                }

                HStack {
                    if let tech = feedback.technicianName {
                        Label(tech, systemImage: "person")
                    }
                    Spacer()
                    if let recommend = feedback.wouldRecommend {
                        Label(recommend ? "Would Recommend" : "Would Not Recommend", systemImage: recommend ? "hand.thumbsup.fill" : "hand.thumbsdown")
                            .foregroundStyle(recommend ? SpendlyColors.success : SpendlyColors.error)
                    }
                    Spacer()
                    Text(viewModel.relativeDate(feedback.submittedAt))
                }
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            }
        }
        .onTapGesture {
            viewModel.selectFeedback(feedback)
        }
    }

    // MARK: - Pending Content

    private var pendingContent: some View {
        Group {
            if viewModel.pendingSurveys.isEmpty {
                SPEmptyState(title: "No Pending Surveys", subtitle: "All customers have submitted their feedback.", icon: "checkmark.circle")
            } else {
                ForEach(viewModel.pendingSurveys) { survey in
                    SPCard {
                        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text(survey.customerName)
                                        .font(SpendlyFont.bodySmall(weight: .semibold))
                                        .foregroundStyle(SpendlyColors.primaryForeground(for: colorScheme))
                                    Text(survey.ticketNumber)
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                                }
                                Spacer()
                                SPBadge(text: "Awaiting Response", style: .warning)
                            }

                            Text(survey.serviceSummary)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                            HStack {
                                Label(survey.technicianName, systemImage: "person")
                                Spacer()
                                Text("Completed \(viewModel.relativeDate(survey.completedAt))")
                            }
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                            HStack {
                                Spacer()
                                SPButton(title: "Send Reminder", style: .secondary, size: .small) {
                                    // In production: sends email reminder
                                }
                                SPButton(title: "Fill Survey", style: .primary, size: .small) {
                                    viewModel.startSurvey(for: survey)
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    // MARK: - Analytics Content

    private var analyticsContent: some View {
        VStack(spacing: SpendlySpacing.md) {
            // Rating Breakdown
            SPCard {
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Rating Breakdown")
                        .font(SpendlyFont.bodySmall(weight: .semibold))
                        .foregroundStyle(SpendlyColors.primaryForeground(for: colorScheme))

                    ForEach(viewModel.ratingDistribution.reversed(), id: \.0) { stars, count in
                        HStack(spacing: SpendlySpacing.sm) {
                            starsView(rating: stars)
                            SPProgressBar(progress: viewModel.totalResponses > 0 ? Double(count) / Double(viewModel.totalResponses) : 0, style: .primary)
                            Text("\(count)")
                                .font(SpendlyFont.caption(weight: .medium))
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                                .frame(width: 24, alignment: .trailing)
                        }
                    }
                }
            }

            // Category Ratings
            SPCard {
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Category Averages")
                        .font(SpendlyFont.bodySmall(weight: .semibold))
                        .foregroundStyle(SpendlyColors.primaryForeground(for: colorScheme))

                    categoryRatingRow(title: "Response Time", value: viewModel.averageResponseTimeRating)
                    categoryRatingRow(title: "Professionalism", value: viewModel.averageProfessionalismRating)
                    categoryRatingRow(title: "Resolution Quality", value: viewModel.averageResolutionRating)
                }
            }

            // Summary Stats
            SPCard {
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Summary")
                        .font(SpendlyFont.bodySmall(weight: .semibold))
                        .foregroundStyle(SpendlyColors.primaryForeground(for: colorScheme))

                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: SpendlySpacing.sm) {
                        statCell(title: "Total Responses", value: "\(viewModel.totalResponses)")
                        statCell(title: "CSAT Score", value: "\(viewModel.csatScore)%")
                        statCell(title: "NPS Score", value: "\(viewModel.npsScore)")
                        statCell(title: "Avg Rating", value: String(format: "%.1f", viewModel.averageOverallRating))
                    }
                }
            }
        }
    }

    // MARK: - Helpers

    private func starsView(rating: Int) -> some View {
        HStack(spacing: 2) {
            ForEach(1...5, id: \.self) { star in
                Image(systemName: star <= rating ? "star.fill" : "star")
                    .font(.system(size: 12))
                    .foregroundStyle(star <= rating ? SpendlyColors.warning : SpendlyColors.secondaryForeground(for: colorScheme).opacity(0.3))
            }
        }
    }

    private func categoryRatingRow(title: String, value: Double) -> some View {
        HStack {
            Text(title)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            Spacer()
            starsView(rating: Int(value.rounded()))
            Text(String(format: "%.1f", value))
                .font(SpendlyFont.caption(weight: .medium))
                .foregroundStyle(SpendlyColors.primaryForeground(for: colorScheme))
                .frame(width: 28, alignment: .trailing)
        }
    }

    private func statCell(title: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.primary)
            Text(title)
                .font(SpendlyFont.caption())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
        }
        .frame(maxWidth: .infinity)
        .padding(SpendlySpacing.sm)
        .background(SpendlyColors.secondaryBackground(for: colorScheme), in: RoundedRectangle(cornerRadius: SpendlyCornerRadius.sm))
    }

    // MARK: - Feedback Detail Sheet

    private var feedbackDetailSheet: some View {
        NavigationStack {
            if let feedback = viewModel.selectedFeedback {
                ScrollView {
                    VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                        // Header
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text(feedback.customerName)
                                    .font(SpendlyFont.headline())
                                if let ticket = feedback.ticketNumber {
                                    Text(ticket)
                                        .font(SpendlyFont.bodySmall())
                                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                                }
                            }
                            Spacer()
                            VStack(alignment: .trailing, spacing: 2) {
                                starsView(rating: feedback.overallRating)
                                Text("\(feedback.overallRating)/5")
                                    .font(SpendlyFont.caption(weight: .medium))
                            }
                        }

                        Text(feedback.serviceSummary)
                            .font(SpendlyFont.bodySmall())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))

                        SPDivider()

                        // Category Ratings
                        if let rt = feedback.responseTimeRating {
                            ratingDetailRow(title: "Response Time", rating: rt)
                        }
                        if let pr = feedback.professionalismRating {
                            ratingDetailRow(title: "Professionalism", rating: pr)
                        }
                        if let rr = feedback.resolutionRating {
                            ratingDetailRow(title: "Resolution Quality", rating: rr)
                        }

                        SPDivider()

                        // Comments
                        if let comments = feedback.comments {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Comments")
                                    .font(SpendlyFont.bodySmall(weight: .semibold))
                                Text(comments)
                                    .font(SpendlyFont.bodySmall())
                                    .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                            }
                        }

                        // Recommendation
                        if let recommend = feedback.wouldRecommend {
                            HStack {
                                Image(systemName: recommend ? "hand.thumbsup.fill" : "hand.thumbsdown.fill")
                                    .foregroundStyle(recommend ? SpendlyColors.success : SpendlyColors.error)
                                Text(recommend ? "Customer would recommend" : "Customer would not recommend")
                                    .font(SpendlyFont.bodySmall())
                            }
                        }

                        // Meta
                        HStack {
                            if let tech = feedback.technicianName {
                                Label(tech, systemImage: "person")
                            }
                            Spacer()
                            Text(viewModel.formattedDate(feedback.submittedAt))
                        }
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }
                    .padding(SpendlySpacing.md)
                }
                .navigationTitle("Feedback Details")
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Done") { viewModel.showFeedbackDetail = false }
                    }
                }
            }
        }
    }

    private func ratingDetailRow(title: String, rating: Int) -> some View {
        HStack {
            Text(title)
                .font(SpendlyFont.bodySmall())
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
            Spacer()
            starsView(rating: rating)
        }
    }

    // MARK: - Survey Form Sheet

    private var surveyFormSheet: some View {
        NavigationStack {
            Form {
                if let survey = viewModel.selectedSurvey {
                    Section("Service Details") {
                        LabeledContent("Ticket", value: survey.ticketNumber)
                        LabeledContent("Customer", value: survey.customerName)
                        LabeledContent("Technician", value: survey.technicianName)
                        Text(survey.serviceSummary)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }

                    Section("Overall Rating *") {
                        starRatingPicker(rating: $viewModel.surveyOverallRating)
                    }

                    Section("Detailed Ratings (Optional)") {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Response Time")
                                .font(.caption)
                            starRatingPicker(rating: $viewModel.surveyResponseTimeRating)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Professionalism")
                                .font(.caption)
                            starRatingPicker(rating: $viewModel.surveyProfessionalismRating)
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Resolution Quality")
                                .font(.caption)
                            starRatingPicker(rating: $viewModel.surveyResolutionRating)
                        }
                    }

                    Section("Would You Recommend?") {
                        HStack {
                            Button {
                                viewModel.surveyWouldRecommend = true
                            } label: {
                                Label("Yes", systemImage: viewModel.surveyWouldRecommend == true ? "hand.thumbsup.fill" : "hand.thumbsup")
                                    .foregroundStyle(viewModel.surveyWouldRecommend == true ? SpendlyColors.success : .secondary)
                            }
                            .buttonStyle(.bordered)

                            Button {
                                viewModel.surveyWouldRecommend = false
                            } label: {
                                Label("No", systemImage: viewModel.surveyWouldRecommend == false ? "hand.thumbsdown.fill" : "hand.thumbsdown")
                                    .foregroundStyle(viewModel.surveyWouldRecommend == false ? SpendlyColors.error : .secondary)
                            }
                            .buttonStyle(.bordered)
                        }
                    }

                    Section("Comments") {
                        TextField("Share your experience...", text: $viewModel.surveyComments, axis: .vertical)
                            .lineLimit(4...8)
                    }
                }
            }
            .navigationTitle("Customer Survey")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { viewModel.showSurveyForm = false }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button(viewModel.isSubmittingSurvey ? "Submitting..." : "Submit") {
                        viewModel.submitSurvey()
                    }
                    .disabled(viewModel.surveyOverallRating == 0 || viewModel.isSubmittingSurvey)
                }
            }
        }
    }

    private func starRatingPicker(rating: Binding<Int>) -> some View {
        HStack(spacing: 8) {
            ForEach(1...5, id: \.self) { star in
                Button {
                    rating.wrappedValue = star
                } label: {
                    Image(systemName: star <= rating.wrappedValue ? "star.fill" : "star")
                        .font(.title3)
                        .foregroundStyle(star <= rating.wrappedValue ? SpendlyColors.warning : .secondary.opacity(0.4))
                }
                .buttonStyle(.plain)
            }
        }
    }
}

#Preview {
    NavigationStack {
        CustomerFeedbackRootView()
    }
}
