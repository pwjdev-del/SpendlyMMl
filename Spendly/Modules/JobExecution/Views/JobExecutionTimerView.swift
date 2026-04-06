import SwiftUI
import SpendlyCore

// MARK: - JobExecutionTimerView

struct JobExecutionTimerView: View {

    @Bindable var viewModel: JobExecutionViewModel

    @Environment(\.colorScheme) private var colorScheme
    @Environment(\.dismiss) private var dismiss

    @State private var showMaterialSheet: Bool = false
    @State private var showPhotoCapture: Bool = false
    @State private var showJobInfoSheet: Bool = false
    @State private var materialName: String = ""
    @State private var materialQuantity: String = "1"
    @State private var materialCost: String = ""

    /// Always read the live job from the viewModel's jobs array so mutations are visible.
    /// This is non-optional because the view should only be shown when a job is selected.
    private var job: JobDisplayModel {
        if let sel = viewModel.selectedJob,
           let live = viewModel.jobs.first(where: { $0.id == sel.id }) {
            return live
        }
        // Fallback to selectedJob; in practice this view is only shown when selectedJob != nil
        return viewModel.selectedJob ?? JobDisplayModel.placeholder
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Header
                timerHeader

                // Sync indicator
                if viewModel.isOffline {
                    syncIndicator
                }

                // Content
                ScrollView {
                    VStack(spacing: 0) {
                        timerSection
                        materialsAction
                        photosSection
                        jobDetailsSection
                    }
                    .padding(.bottom, 40)
                }
                .background(SpendlyColors.background(for: colorScheme))
            }
            .background(SpendlyColors.background(for: colorScheme))
            .navigationBarHidden(true)
            .sheet(isPresented: $showMaterialSheet) {
                materialLogSheet
            }
            .sheet(isPresented: $showPhotoCapture) {
                PhotoCaptureView(viewModel: viewModel, jobID: job.id)
            }
            .sheet(isPresented: $showJobInfoSheet) {
                jobInfoSheet
            }
        }
    }

    // MARK: - Header

    private var timerHeader: some View {
        HStack(spacing: SpendlySpacing.md) {
            Button {
                dismiss()
            } label: {
                Image(systemName: SpendlyIcon.arrowBack.systemName)
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .frame(width: 40, height: 40)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text("Active Execution")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                Text("Job \(job.jobNumber) \u{2022} \(job.jobType.rawValue)")
                    .font(SpendlyFont.caption())
                    .foregroundStyle(SpendlyColors.secondary)
            }

            Spacer()

            Button {
                showJobInfoSheet = true
            } label: {
                Image(systemName: SpendlyIcon.info.systemName)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .frame(width: 40, height: 40)
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.vertical, SpendlySpacing.sm)
        .background(SpendlyColors.surface(for: colorScheme))
    }

    // MARK: - Sync Indicator

    private var syncIndicator: some View {
        VStack(spacing: SpendlySpacing.sm) {
            // Offline banner
            HStack(spacing: SpendlySpacing.sm) {
                Image(systemName: "wifi.slash")
                    .font(.system(size: 12, weight: .bold))
                Text("OFFLINE MODE: ACTIVE")
                    .font(.system(size: 11, weight: .bold))
                    .tracking(0.8)
                Spacer()
                if case .pendingSync(let count) = viewModel.syncStatus {
                    Text("\(count) items pending sync")
                        .font(.system(size: 10, weight: .bold))
                        .padding(.horizontal, SpendlySpacing.sm)
                        .padding(.vertical, 2)
                        .background(Color.white.opacity(0.2))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small))
                }
            }
            .foregroundStyle(.white)
            .padding(.horizontal, SpendlySpacing.lg)
            .padding(.vertical, SpendlySpacing.sm)
            .background(SpendlyColors.warning)

            // Sync progress bar
            if case .syncing = viewModel.syncStatus {
                HStack(spacing: SpendlySpacing.md) {
                    Image(systemName: "arrow.triangle.2.circlepath")
                        .font(.system(size: 14, weight: .medium))
                    Text("Syncing to Cloud...")
                        .font(SpendlyFont.caption())
                        .fontWeight(.medium)
                    Spacer()
                    GeometryReader { geo in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.2))
                            .frame(width: geo.size.width)
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(.white)
                                    .frame(width: geo.size.width * 0.66)
                            }
                    }
                    .frame(width: 64, height: 6)
                }
                .foregroundStyle(.white)
                .padding(.horizontal, SpendlySpacing.lg)
                .padding(.vertical, SpendlySpacing.md)
                .background(SpendlyColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                .padding(.horizontal, SpendlySpacing.lg)
            }
        }
    }

    // MARK: - Timer Section

    private var timerSection: some View {
        VStack(spacing: SpendlySpacing.xxl) {
            // Estimated vs Actual time labels
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("ACTUAL TIME")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(SpendlyColors.secondary)
                    Text(viewModel.isPaused ? "Paused" : "In Progress")
                        .font(SpendlyFont.caption())
                        .fontWeight(.semibold)
                        .foregroundStyle(viewModel.isPaused ? SpendlyColors.warning : SpendlyColors.primary)
                }
                Spacer()
                VStack(alignment: .trailing, spacing: 2) {
                    Text("ESTIMATED TIME")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(SpendlyColors.secondary)
                    Text(viewModel.formattedEstimatedTime(for: job))
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }
            }

            // Timer digits
            HStack(spacing: SpendlySpacing.md) {
                timerDigitBox(value: viewModel.formattedHours, label: "HOURS")
                timerDigitBox(value: viewModel.formattedMinutes, label: "MINUTES")
                timerDigitBox(value: viewModel.formattedSeconds, label: "SECONDS")
            }

            // Control buttons
            HStack(spacing: SpendlySpacing.lg) {
                // Pause / Resume
                Button {
                    viewModel.togglePause()
                } label: {
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: viewModel.isPaused ? SpendlyIcon.play.systemName : SpendlyIcon.pause.systemName)
                            .font(.system(size: 16, weight: .bold))
                        Text(viewModel.isPaused ? "Resume" : "Pause Job")
                            .font(SpendlyFont.bodySemibold())
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundStyle(.white)
                    .background(SpendlyColors.primary)
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
                }

                // Finish
                Button {
                    viewModel.finishJob()
                } label: {
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: SpendlyIcon.stop.systemName)
                            .font(.system(size: 16, weight: .bold))
                        Text("Finish")
                            .font(SpendlyFont.bodySemibold())
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 56)
                    .foregroundStyle(.white)
                    .background(SpendlyColors.error)
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
                }
            }

            // Break timer
            if viewModel.isOnBreak {
                HStack {
                    Image(systemName: "cup.and.saucer.fill")
                        .foregroundStyle(SpendlyColors.warning)
                    Text("Break: \(viewModel.formattedBreakTime)")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.warning)
                    Spacer()
                    Button {
                        viewModel.endBreak()
                    } label: {
                        Text("End Break")
                            .font(SpendlyFont.caption())
                            .fontWeight(.bold)
                            .foregroundStyle(.white)
                            .padding(.horizontal, SpendlySpacing.md)
                            .padding(.vertical, SpendlySpacing.sm)
                            .background(SpendlyColors.warning)
                            .clipShape(Capsule())
                    }
                }
                .padding(SpendlySpacing.md)
                .background(SpendlyColors.warning.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
            } else if job.status == .inProgress {
                Button {
                    viewModel.startBreak()
                } label: {
                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: "cup.and.saucer")
                            .font(.system(size: 13))
                        Text("Take Break")
                            .font(SpendlyFont.caption())
                            .fontWeight(.semibold)
                    }
                    .foregroundStyle(SpendlyColors.secondary)
                }
            }
        }
        .padding(SpendlySpacing.xxl)
        .background(SpendlyColors.surface(for: colorScheme))
        .padding(.bottom, SpendlySpacing.lg)
    }

    private func timerDigitBox(value: String, label: String) -> some View {
        VStack(spacing: SpendlySpacing.sm) {
            Text(value)
                .font(.system(size: 32, weight: .bold, design: .monospaced))
                .foregroundStyle(SpendlyColors.primary)
                .frame(maxWidth: .infinity)
                .frame(height: 80)
                .background(SpendlyColors.primary.opacity(0.05))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                        .strokeBorder(SpendlyColors.primary.opacity(0.1), lineWidth: 2)
                )
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))

            Text(label)
                .font(.system(size: 10, weight: .bold))
                .tracking(1)
                .foregroundStyle(SpendlyColors.secondary)
        }
    }

    // MARK: - Materials Quick Action

    private var materialsAction: some View {
        VStack(spacing: 0) {
            Button {
                showMaterialSheet = true
            } label: {
                HStack {
                    HStack(spacing: SpendlySpacing.md) {
                        Image(systemName: SpendlyIcon.inventory.systemName)
                            .font(.system(size: 22))
                            .foregroundStyle(SpendlyColors.primary)
                        Text("Log Materials Used")
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    }
                    Spacer()
                    HStack(spacing: SpendlySpacing.sm) {
                        if viewModel.isOffline {
                            Text("LOCAL")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundStyle(SpendlyColors.warning)
                                .padding(.horizontal, SpendlySpacing.sm)
                                .padding(.vertical, 2)
                                .background(SpendlyColors.warning.opacity(0.15))
                                .clipShape(Capsule())
                        }
                        Image(systemName: SpendlyIcon.addCircle.systemName)
                            .font(.system(size: 20))
                            .foregroundStyle(SpendlyColors.primary)
                    }
                }
                .padding(SpendlySpacing.lg)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous)
                        .strokeBorder(
                            SpendlyColors.secondary.opacity(0.2),
                            style: StrokeStyle(lineWidth: 2, dash: [8, 4])
                        )
                )
            }
            .buttonStyle(.plain)

            // Show logged materials
            if !job.materials.isEmpty {
                VStack(spacing: SpendlySpacing.sm) {
                    ForEach(job.materials) { material in
                        HStack {
                            Text(material.name)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Spacer()
                            Text("x\(material.quantity)")
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                            if viewModel.canViewCosts {
                                Text("$\(String(format: "%.2f", material.totalCost))")
                                    .font(SpendlyFont.caption())
                                    .fontWeight(.semibold)
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            }
                        }
                        .padding(.horizontal, SpendlySpacing.lg)
                        .padding(.vertical, SpendlySpacing.sm)
                    }
                    if viewModel.canViewCosts {
                        Divider()
                            .padding(.horizontal, SpendlySpacing.lg)
                        HStack {
                            Text("Total Materials")
                                .font(SpendlyFont.caption())
                                .fontWeight(.bold)
                            Spacer()
                            Text("$\(String(format: "%.2f", viewModel.totalMaterialsCost))")
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.primary)
                        }
                        .padding(.horizontal, SpendlySpacing.lg)
                        .padding(.vertical, SpendlySpacing.sm)
                    }
                }
                .padding(.top, SpendlySpacing.sm)
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.bottom, SpendlySpacing.xxl)
    }

    // MARK: - Photos Section

    private var photosSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.md) {
            HStack {
                Text("Job Photos")
                    .font(SpendlyFont.headline())
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                Spacer()
                let pendingCount = job.photos.count
                if pendingCount > 0 && viewModel.isOffline {
                    Text("\(pendingCount) Pending Upload")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.5)
                        .foregroundStyle(SpendlyColors.secondary)
                }
            }

            HStack(spacing: SpendlySpacing.lg) {
                photoPlaceholder(label: "Before Photos") {
                    showPhotoCapture = true
                }
                photoPlaceholder(label: "After Photos") {
                    showPhotoCapture = true
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
        .padding(.bottom, SpendlySpacing.xxl)
    }

    private func photoPlaceholder(label: String, action: @escaping () -> Void) -> some View {
        VStack(spacing: SpendlySpacing.sm) {
            Button(action: action) {
                VStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "camera.badge.ellipsis")
                        .font(.system(size: 28))
                        .foregroundStyle(SpendlyColors.secondary)
                    Text("UPLOAD")
                        .font(.system(size: 10, weight: .bold))
                        .tracking(0.8)
                        .foregroundStyle(SpendlyColors.secondary)
                }
                .frame(maxWidth: .infinity)
                .aspectRatio(1, contentMode: .fit)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                        .strokeBorder(
                            SpendlyColors.secondary.opacity(0.2),
                            style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                        )
                )
            }
            .buttonStyle(.plain)

            Text(label)
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
        }
    }

    // MARK: - Job Details Section

    private var jobDetailsSection: some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
            Text("Job Details")
                .font(SpendlyFont.title())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .padding(.horizontal, SpendlySpacing.lg)

            // Client Info Card
            clientInfoCard

            // Tasks Checklist
            taskChecklistCard
        }
    }

    // MARK: - Client Info Card

    private var clientInfoCard: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {
                // Client name
                HStack(spacing: SpendlySpacing.md) {
                    Image(systemName: SpendlyIcon.person.systemName)
                        .font(.system(size: 16))
                        .foregroundStyle(SpendlyColors.primary)
                    Text(job.client.name)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                }

                // Address
                HStack(spacing: SpendlySpacing.md) {
                    Image(systemName: SpendlyIcon.location.systemName)
                        .font(.system(size: 14))
                        .foregroundStyle(SpendlyColors.secondary)
                    Text(job.client.address)
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                }

                // Notes
                if !job.client.notes.isEmpty {
                    HStack(spacing: 0) {
                        Rectangle()
                            .fill(SpendlyColors.primary.opacity(0.4))
                            .frame(width: 4)

                        Text("\"\(job.client.notes)\"")
                            .font(SpendlyFont.caption())
                            .italic()
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                            .padding(SpendlySpacing.md)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(SpendlyColors.background(for: colorScheme))
                    }
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small))
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
    }

    // MARK: - Tasks Checklist Card

    private var taskChecklistCard: some View {
        SPCard(elevation: .low) {
            VStack(alignment: .leading, spacing: SpendlySpacing.lg) {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: "checklist")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Text("Required Tasks")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    Spacer()
                    Text("\(job.completedTaskCount)/\(job.totalTaskCount)")
                        .font(SpendlyFont.caption())
                        .fontWeight(.bold)
                        .foregroundStyle(SpendlyColors.secondary)
                }

                VStack(spacing: SpendlySpacing.lg) {
                    ForEach(job.checklist) { item in
                        checklistRow(item: item)
                    }
                }
            }
        }
        .padding(.horizontal, SpendlySpacing.lg)
    }

    private func checklistRow(item: ChecklistItem) -> some View {
        Button {
            viewModel.toggleChecklistItem(jobID: job.id, itemID: item.id)
        } label: {
            HStack(spacing: SpendlySpacing.md) {
                ZStack {
                    RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous)
                        .strokeBorder(
                            item.isCompleted ? SpendlyColors.primary : SpendlyColors.secondary.opacity(0.3),
                            lineWidth: 1.5
                        )
                        .frame(width: 24, height: 24)

                    if item.isCompleted {
                        RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous)
                            .fill(SpendlyColors.primary)
                            .frame(width: 24, height: 24)
                            .overlay(
                                Image(systemName: "checkmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundStyle(.white)
                            )
                    }
                }

                Text(item.title)
                    .font(SpendlyFont.caption())
                    .foregroundStyle(
                        item.isCompleted
                            ? SpendlyColors.secondary
                            : SpendlyColors.foreground(for: colorScheme)
                    )
                    .strikethrough(item.isCompleted)

                Spacer()
            }
        }
        .buttonStyle(.plain)
    }

    // MARK: - Material Log Sheet

    private var materialLogSheet: some View {
        NavigationStack {
            VStack(spacing: SpendlySpacing.xl) {
                VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                    Text("Material Name")
                        .font(SpendlyFont.caption())
                        .fontWeight(.semibold)
                        .foregroundStyle(SpendlyColors.secondary)
                    TextField("e.g., HVAC Filter Cartridge", text: $materialName)
                        .font(SpendlyFont.body())
                        .padding(SpendlySpacing.md)
                        .background(SpendlyColors.background(for: colorScheme))
                        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                }

                HStack(spacing: SpendlySpacing.lg) {
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        Text("Quantity")
                            .font(SpendlyFont.caption())
                            .fontWeight(.semibold)
                            .foregroundStyle(SpendlyColors.secondary)
                        TextField("1", text: $materialQuantity)
                            .font(SpendlyFont.body())
                            .keyboardType(.numberPad)
                            .padding(SpendlySpacing.md)
                            .background(SpendlyColors.background(for: colorScheme))
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                    }

                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        Text("Unit Cost ($)")
                            .font(SpendlyFont.caption())
                            .fontWeight(.semibold)
                            .foregroundStyle(SpendlyColors.secondary)
                        TextField("0.00", text: $materialCost)
                            .font(SpendlyFont.body())
                            .keyboardType(.decimalPad)
                            .padding(SpendlySpacing.md)
                            .background(SpendlyColors.background(for: colorScheme))
                            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium))
                    }
                }

                SPButton("Add Material", icon: "plus", style: .primary) {
                    let quantity = Int(materialQuantity) ?? 1
                    let cost = Double(materialCost) ?? 0.0
                    guard !materialName.isEmpty else { return }

                    let material = MaterialItem(
                        name: materialName,
                        quantity: quantity,
                        unitCost: cost
                    )
                    viewModel.addMaterial(to: job.id, material: material)

                    // Reset fields
                    materialName = ""
                    materialQuantity = "1"
                    materialCost = ""
                    showMaterialSheet = false
                }

                Spacer()
            }
            .padding(SpendlySpacing.xl)
            .navigationTitle("Log Materials")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showMaterialSheet = false
                    }
                }
            }
        }
        .presentationDetents([.medium])
    }

    // MARK: - Job Info Sheet

    private var jobInfoSheet: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SpendlySpacing.xl) {
                    // Job header
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        SPBadge(job.status.rawValue, style: job.status.badgeStyle)
                        Text(job.title)
                            .font(SpendlyFont.title())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text("Job \(job.jobNumber) -- \(job.jobType.rawValue)")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }

                    Divider()

                    // Schedule
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        Label("Schedule", systemImage: SpendlyIcon.schedule.systemName)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text(job.scheduledTimeRange)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }

                    // Location
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        Label("Location", systemImage: SpendlyIcon.location.systemName)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text(job.location)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }

                    // Client
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        Label("Client", systemImage: SpendlyIcon.person.systemName)
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text(job.client.name)
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        if !job.client.phone.isEmpty {
                            Text(job.client.phone)
                                .font(SpendlyFont.caption())
                                .foregroundStyle(SpendlyColors.secondary)
                        }
                        Text(job.client.address)
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }

                    // Notes
                    if !job.client.notes.isEmpty {
                        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                            Label("Notes", systemImage: "note.text")
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Text(job.client.notes)
                                .font(SpendlyFont.body())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        }
                    }

                    // Progress
                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        Label("Checklist Progress", systemImage: "checklist")
                            .font(SpendlyFont.bodySemibold())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text("\(job.completedTaskCount) of \(job.totalTaskCount) tasks completed")
                            .font(SpendlyFont.body())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        ProgressView(value: job.totalTaskCount > 0 ? Double(job.completedTaskCount) / Double(job.totalTaskCount) : 0)
                            .tint(SpendlyColors.primary)
                    }

                    // Materials summary
                    if !job.materials.isEmpty {
                        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                            Label("Materials", systemImage: SpendlyIcon.inventory.systemName)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Text("\(job.materials.count) items logged")
                                .font(SpendlyFont.body())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                            if viewModel.canViewCosts {
                                Text("Total: $\(String(format: "%.2f", job.materials.reduce(0) { $0 + $1.totalCost }))")
                                    .font(SpendlyFont.bodySemibold())
                                    .foregroundStyle(SpendlyColors.primary)
                            }
                        }
                    }

                    // Photos summary
                    if !job.photos.isEmpty {
                        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                            Label("Photos", systemImage: SpendlyIcon.camera.systemName)
                                .font(SpendlyFont.bodySemibold())
                                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                            Text("\(job.photos.count) photos captured")
                                .font(SpendlyFont.body())
                                .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                        }
                    }
                }
                .padding(SpendlySpacing.xl)
            }
            .background(SpendlyColors.background(for: colorScheme))
            .navigationTitle("Job Summary")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        showJobInfoSheet = false
                    }
                    .font(SpendlyFont.bodySemibold())
                    .foregroundStyle(SpendlyColors.primary)
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    let vm = JobExecutionViewModel()
    JobExecutionTimerView(viewModel: vm)
}
