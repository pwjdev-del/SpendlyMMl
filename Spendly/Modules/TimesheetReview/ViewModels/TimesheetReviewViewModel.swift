import Foundation
import SwiftUI
import SpendlyCore

// MARK: - View Model

@Observable
final class TimesheetReviewViewModel {

    // MARK: Tab Selection

    enum Tab: String, CaseIterable {
        case mySummary = "My Summary"
        case teamApprovals = "Team Approvals"
    }

    var selectedTab: Tab = .mySummary

    // MARK: Timesheet Entries

    var entries: [TimesheetDayEntry] = TimesheetReviewMockData.weekEntries
    var comments: [TimesheetComment] = TimesheetReviewMockData.sampleComments
    var teamTimesheets: [TeamTimesheetSummary] = TimesheetReviewMockData.teamTimesheets

    // MARK: Computed — Weekly Totals

    var totalRegularHours: Double {
        entries.reduce(0) { $0 + $1.regularHours }
    }

    var totalOvertimeHours: Double {
        entries.reduce(0) { $0 + $1.overtimeHours }
    }

    var totalHours: Double {
        totalRegularHours + totalOvertimeHours
    }

    var totalBreakMinutes: Int {
        entries.reduce(0) { $0 + $1.breakMinutes }
    }

    var formattedBreakHours: String {
        let hours = Double(totalBreakMinutes) / 60.0
        return String(format: "%.1fh", hours)
    }

    var hasOvertime: Bool {
        totalOvertimeHours > 0
    }

    var billableHours: Double {
        totalRegularHours
    }

    var activeProjects: Int {
        Set(entries.compactMap { $0.projectName != "—" ? $0.projectName : nil }).count
    }

    var weeklyStatus: TimesheetEntryStatus {
        if entries.allSatisfy({ $0.status == .approved }) { return .approved }
        if entries.contains(where: { $0.status == .rejected }) { return .rejected }
        if entries.contains(where: { $0.status == .submitted }) { return .submitted }
        return .draft
    }

    // MARK: Selection

    var selectedEntries: [TimesheetDayEntry] {
        entries.filter { $0.isSelected }
    }

    var hasSelection: Bool {
        !selectedEntries.isEmpty
    }

    var allSubmittedSelected: Bool {
        let submittedEntries = entries.filter { $0.status == .submitted }
        guard !submittedEntries.isEmpty else { return false }
        return submittedEntries.allSatisfy { $0.isSelected }
    }

    func toggleEntrySelection(_ entry: TimesheetDayEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            entries[idx].isSelected.toggle()
        }
    }

    func toggleSelectAllSubmitted() {
        let shouldSelect = !allSubmittedSelected
        withAnimation(.easeInOut(duration: 0.2)) {
            for idx in entries.indices where entries[idx].status == .submitted {
                entries[idx].isSelected = shouldSelect
            }
        }
    }

    // MARK: Team Selection

    var selectedTeamTimesheets: [TeamTimesheetSummary] {
        teamTimesheets.filter { $0.isSelected }
    }

    var hasTeamSelection: Bool {
        !selectedTeamTimesheets.isEmpty
    }

    var allTeamSelected: Bool {
        let pending = teamTimesheets.filter { $0.status == .submitted }
        guard !pending.isEmpty else { return false }
        return pending.allSatisfy { $0.isSelected }
    }

    func toggleTeamSelection(_ summary: TeamTimesheetSummary) {
        guard let idx = teamTimesheets.firstIndex(where: { $0.id == summary.id }) else { return }
        withAnimation(.easeInOut(duration: 0.2)) {
            teamTimesheets[idx].isSelected.toggle()
        }
    }

    func toggleSelectAllTeam() {
        let shouldSelect = !allTeamSelected
        withAnimation(.easeInOut(duration: 0.2)) {
            for idx in teamTimesheets.indices where teamTimesheets[idx].status == .submitted {
                teamTimesheets[idx].isSelected = shouldSelect
            }
        }
    }

    // MARK: Sheets / Alerts

    var showingRejectSheet: Bool = false
    var rejectionReason: String = ""
    var entryToReject: TimesheetDayEntry?
    var teamMemberToReject: TeamTimesheetSummary?

    var showingCommentSheet: Bool = false
    var newCommentText: String = ""

    var showingSubmitConfirmation: Bool = false
    var showingApprovalConfirmation: Bool = false
    var showingBulkApprovalConfirmation: Bool = false
    var showingBulkTeamApprovalConfirmation: Bool = false

    var selectedEntryDetail: TimesheetDayEntry?
    var showingEntryDetail: Bool = false

    // MARK: Actions — Approve Entry

    func approveEntry(_ entry: TimesheetDayEntry) {
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            entries[idx].status = .approved
            entries[idx].isSelected = false
        }
        showingApprovalConfirmation = true
    }

    // MARK: Actions — Reject Entry

    func beginRejectEntry(_ entry: TimesheetDayEntry) {
        entryToReject = entry
        rejectionReason = ""
        showingRejectSheet = true
    }

    func executeRejectEntry() {
        guard let entry = entryToReject else { return }
        guard let idx = entries.firstIndex(where: { $0.id == entry.id }) else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            entries[idx].status = .rejected
            entries[idx].rejectionReason = rejectionReason.isEmpty ? "No reason provided" : rejectionReason
            entries[idx].isSelected = false
        }
        showingRejectSheet = false
        entryToReject = nil
        rejectionReason = ""
    }

    // MARK: Actions — Bulk Approve

    func bulkApproveSelected() {
        withAnimation(.easeInOut(duration: 0.25)) {
            for idx in entries.indices where entries[idx].isSelected && entries[idx].status == .submitted {
                entries[idx].status = .approved
                entries[idx].isSelected = false
            }
        }
        showingBulkApprovalConfirmation = true
    }

    // MARK: Actions — Submit for Approval

    func submitForApproval() {
        withAnimation(.easeInOut(duration: 0.25)) {
            for idx in entries.indices where entries[idx].status == .draft {
                entries[idx].status = .submitted
            }
        }
        showingSubmitConfirmation = true
    }

    // MARK: Actions — Team Approve

    func approveTeamMember(_ summary: TeamTimesheetSummary) {
        guard let idx = teamTimesheets.firstIndex(where: { $0.id == summary.id }) else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            teamTimesheets[idx].status = .approved
            teamTimesheets[idx].isSelected = false
        }
    }

    func beginRejectTeamMember(_ summary: TeamTimesheetSummary) {
        teamMemberToReject = summary
        rejectionReason = ""
        showingRejectSheet = true
    }

    func executeRejectTeamMember() {
        guard let summary = teamMemberToReject else { return }
        guard let idx = teamTimesheets.firstIndex(where: { $0.id == summary.id }) else { return }
        withAnimation(.easeInOut(duration: 0.25)) {
            teamTimesheets[idx].status = .rejected
            teamTimesheets[idx].isSelected = false
        }
        showingRejectSheet = false
        teamMemberToReject = nil
        rejectionReason = ""
    }

    func bulkApproveTeam() {
        withAnimation(.easeInOut(duration: 0.25)) {
            for idx in teamTimesheets.indices where teamTimesheets[idx].isSelected && teamTimesheets[idx].status == .submitted {
                teamTimesheets[idx].status = .approved
                teamTimesheets[idx].isSelected = false
            }
        }
        showingBulkTeamApprovalConfirmation = true
    }

    // MARK: Actions — Add Comment

    func addComment() {
        guard !newCommentText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        let comment = TimesheetComment(
            id: UUID(),
            author: "You",
            text: newCommentText,
            date: Date(),
            isManager: false
        )
        withAnimation(.easeInOut(duration: 0.25)) {
            comments.append(comment)
        }
        newCommentText = ""
        showingCommentSheet = false
    }

    // MARK: Formatting

    func badgeStyle(for status: TimesheetEntryStatus) -> SPBadgeStyle {
        switch status {
        case .draft:     return .neutral
        case .submitted: return .warning
        case .approved:  return .success
        case .rejected:  return .error
        }
    }

    func statusLabel(for status: TimesheetEntryStatus) -> String {
        switch status {
        case .draft:     return "Draft"
        case .submitted: return "Pending"
        case .approved:  return "Approved"
        case .rejected:  return "Rejected"
        }
    }

    func formatHours(_ hours: Double) -> String {
        if hours == 0 { return "—" }
        return String(format: "%.1fh", hours)
    }

    func formatBreak(_ minutes: Int) -> String {
        if minutes == 0 { return "—" }
        if minutes < 60 { return "\(minutes)m" }
        let h = minutes / 60
        let m = minutes % 60
        return m > 0 ? "\(h)h \(m)m" : "\(h)h"
    }

    static let shortDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()

    static let fullDateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, yyyy"
        return f
    }()

    func formatShortDate(_ date: Date) -> String {
        Self.shortDateFormatter.string(from: date)
    }

    func formatFullDate(_ date: Date) -> String {
        Self.fullDateFormatter.string(from: date)
    }
}
