import SwiftUI
import Combine
import SpendlyCore

// MARK: - JobExecutionViewModel

@Observable
final class JobExecutionViewModel {

    // MARK: - Schedule Data

    var jobs: [JobDisplayModel] = JobExecutionMockData.jobs
    var weekDays: [WeekDay] = JobExecutionMockData.generateWeekDays()
    var selectedDayIndex: Int = 0

    // MARK: - Timer State

    var activeJobID: UUID?
    var timerSeconds: TimeInterval = 0
    var isTimerRunning: Bool = false
    var isPaused: Bool = false

    // MARK: - Offline / Sync

    var syncStatus: SyncStatus = .synced
    var isOffline: Bool = false
    var pendingSyncCount: Int = 0

    // MARK: - Navigation

    var showTimerView: Bool = false
    var showPhotoCapture: Bool = false
    var showMaterialLog: Bool = false
    var selectedJob: JobDisplayModel?

    // MARK: - Break Timer

    var isOnBreak: Bool = false
    var breakSeconds: TimeInterval = 0

    // MARK: - Month / Year Display

    var monthYearLabel: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: Date())
    }

    // MARK: - Timer Publisher (Combine)

    private var timerCancellable: AnyCancellable?
    private var breakTimerCancellable: AnyCancellable?

    // MARK: - Init

    init() {
        // Find today's index in the week
        let todayIndex = weekDays.firstIndex(where: { $0.isSelected }) ?? 0
        self.selectedDayIndex = todayIndex

        // If there's an in-progress job, set it as active
        if let inProgressJob = jobs.first(where: { $0.status == .inProgress }) {
            activeJobID = inProgressJob.id
            timerSeconds = inProgressJob.elapsedSeconds
            startTimer()
        }
    }

    // MARK: - Day Selection

    func selectDay(at index: Int) {
        for i in weekDays.indices {
            weekDays[i].isSelected = (i == index)
        }
        selectedDayIndex = index
    }

    // MARK: - Job Selection & Navigation

    func openJob(_ job: JobDisplayModel) {
        selectedJob = job
        showTimerView = true
    }

    // MARK: - Timer Controls

    func startTimer() {
        guard !isTimerRunning else { return }
        isTimerRunning = true
        isPaused = false

        timerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isTimerRunning, !self.isPaused else { return }
                self.timerSeconds += 1
                // Update the elapsed time on the active job
                if let idx = self.jobs.firstIndex(where: { $0.id == self.activeJobID }) {
                    self.jobs[idx].elapsedSeconds = self.timerSeconds
                }
            }
    }

    func pauseTimer() {
        isPaused = true
    }

    func resumeTimer() {
        isPaused = false
    }

    func togglePause() {
        if isPaused {
            resumeTimer()
        } else {
            pauseTimer()
        }
    }

    func finishJob() {
        isTimerRunning = false
        isPaused = false
        timerCancellable?.cancel()
        timerCancellable = nil

        if let idx = jobs.firstIndex(where: { $0.id == activeJobID }) {
            jobs[idx].status = .completed
            jobs[idx].elapsedSeconds = timerSeconds
        }

        // Queue for sync if offline
        if isOffline {
            pendingSyncCount += 1
            syncStatus = .pendingSync(count: pendingSyncCount)
        }

        activeJobID = nil
        timerSeconds = 0
        showTimerView = false
    }

    func startJob(_ job: JobDisplayModel) {
        // Mark previous active job as paused if needed
        if let currentIdx = jobs.firstIndex(where: { $0.id == activeJobID }) {
            jobs[currentIdx].isPaused = true
        }

        guard let idx = jobs.firstIndex(where: { $0.id == job.id }) else { return }
        jobs[idx].status = .inProgress

        activeJobID = job.id
        timerSeconds = job.elapsedSeconds
        selectedJob = jobs[idx]
        startTimer()
    }

    // MARK: - Break Timer

    func startBreak() {
        isOnBreak = true
        pauseTimer()
        breakSeconds = 0

        breakTimerCancellable = Timer.publish(every: 1, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self, self.isOnBreak else { return }
                self.breakSeconds += 1
            }
    }

    func endBreak() {
        isOnBreak = false
        breakTimerCancellable?.cancel()
        breakTimerCancellable = nil
        resumeTimer()
    }

    // MARK: - Checklist

    func toggleChecklistItem(jobID: UUID, itemID: UUID) {
        guard let jobIdx = jobs.firstIndex(where: { $0.id == jobID }),
              let itemIdx = jobs[jobIdx].checklist.firstIndex(where: { $0.id == itemID }) else { return }
        jobs[jobIdx].checklist[itemIdx].isCompleted.toggle()

        // Keep selectedJob in sync
        if selectedJob?.id == jobID {
            selectedJob = jobs[jobIdx]
        }
    }

    // MARK: - Materials

    func addMaterial(to jobID: UUID, material: MaterialItem) {
        guard let idx = jobs.firstIndex(where: { $0.id == jobID }) else { return }
        jobs[idx].materials.append(material)

        if selectedJob?.id == jobID {
            selectedJob = jobs[idx]
        }

        if isOffline {
            pendingSyncCount += 1
            syncStatus = .pendingSync(count: pendingSyncCount)
        }
    }

    func removeMaterial(from jobID: UUID, materialID: UUID) {
        guard let idx = jobs.firstIndex(where: { $0.id == jobID }) else { return }
        jobs[idx].materials.removeAll { $0.id == materialID }

        if selectedJob?.id == jobID {
            selectedJob = jobs[idx]
        }
    }

    // MARK: - Photos

    func addPhoto(to jobID: UUID, photo: PhotoCaptureItem) {
        guard let idx = jobs.firstIndex(where: { $0.id == jobID }) else { return }
        jobs[idx].photos.append(photo)

        if selectedJob?.id == jobID {
            selectedJob = jobs[idx]
        }

        if isOffline {
            pendingSyncCount += 1
            syncStatus = .pendingSync(count: pendingSyncCount)
        }
    }

    func removePhoto(from jobID: UUID, photoID: UUID) {
        guard let idx = jobs.firstIndex(where: { $0.id == jobID }) else { return }
        jobs[idx].photos.removeAll { $0.id == photoID }

        if selectedJob?.id == jobID {
            selectedJob = jobs[idx]
        }
    }

    // MARK: - Offline Sync

    func toggleOfflineMode() {
        isOffline.toggle()
        if isOffline {
            syncStatus = pendingSyncCount > 0
                ? .pendingSync(count: pendingSyncCount)
                : .offline
        } else {
            simulateSync()
        }
    }

    func simulateSync() {
        guard pendingSyncCount > 0 else {
            syncStatus = .synced
            return
        }
        syncStatus = .syncing

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            guard let self else { return }
            self.pendingSyncCount = 0
            self.syncStatus = .synced
        }
    }

    // MARK: - Timer Formatting

    var formattedHours: String {
        let hours = Int(timerSeconds) / 3600
        return String(format: "%02d", hours)
    }

    var formattedMinutes: String {
        let minutes = (Int(timerSeconds) % 3600) / 60
        return String(format: "%02d", minutes)
    }

    var formattedSeconds: String {
        let seconds = Int(timerSeconds) % 60
        return String(format: "%02d", seconds)
    }

    var formattedBreakTime: String {
        let minutes = Int(breakSeconds) / 60
        let seconds = Int(breakSeconds) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    func formattedEstimatedTime(for job: JobDisplayModel) -> String {
        let hours = Int(job.estimatedDurationSeconds) / 3600
        let minutes = (Int(job.estimatedDurationSeconds) % 3600) / 60
        let seconds = Int(job.estimatedDurationSeconds) % 60
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }

    // MARK: - Active Job Helpers

    var activeJob: JobDisplayModel? {
        jobs.first { $0.id == activeJobID }
    }

    var jobsForSelectedDay: [JobDisplayModel] {
        // For mock data, return all jobs regardless of selected day
        jobs
    }

    // MARK: - Cost Visibility

    var canViewCosts: Bool {
        // In production, this would check role permissions
        true
    }

    var totalMaterialsCost: Double {
        guard let job = selectedJob else { return 0 }
        return job.materials.reduce(0) { $0 + $1.totalCost }
    }

    // MARK: - Cleanup

    func cleanup() {
        timerCancellable?.cancel()
        breakTimerCancellable?.cancel()
    }
}
