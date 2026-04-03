import SwiftUI
import SpendlyCore

// MARK: - Root View

public struct IncidentHierarchyRootView: View {
    @State private var viewModel = IncidentHierarchyViewModel()
    @Environment(\.colorScheme) private var colorScheme

    public var body: some View {
        SPScreenWrapper {
            VStack(spacing: SpendlySpacing.xxl) {

                // MARK: Section Header
                sectionHeader

                // MARK: Search Bar
                SPSearchBar(searchText: $viewModel.searchText)

                // MARK: System Branches & Assemblies
                branchesSection

                // MARK: Common Issue Templates
                issueTemplatesSection

                // MARK: Asset Management
                assetManagementSection
            }
        }
        .sheet(isPresented: $viewModel.showAddBranchSheet) {
            addBranchSheet
        }
        .sheet(isPresented: $viewModel.showEditBranchSheet) {
            editBranchSheet
        }
        .sheet(isPresented: $viewModel.showAddAssemblySheet) {
            addAssemblySheet
        }
        .sheet(isPresented: $viewModel.showEditAssemblySheet) {
            editAssemblySheet
        }
        .sheet(isPresented: $viewModel.showCreateTemplateSheet) {
            createTemplateSheet
        }
        .sheet(isPresented: $viewModel.showEditTemplateSheet) {
            editTemplateSheet
        }
        .alert("Delete Confirmation", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Cancel", role: .cancel) { viewModel.cancelDelete() }
            Button("Delete", role: .destructive) { viewModel.confirmDelete() }
        } message: {
            Text("Are you sure you want to delete \"\(viewModel.deleteTargetName)\"? This action cannot be undone.")
        }
    }
}

// MARK: - Section Header

private extension IncidentHierarchyRootView {

    var sectionHeader: some View {
        HStack(alignment: .center) {
            Text("INCIDENT & ISSUE MANAGEMENT")
                .font(SpendlyFont.caption())
                .fontWeight(.bold)
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                .tracking(0.8)

            Spacer()

            Text("HIERARCHICAL CONFIG")
                .font(.system(size: 9, weight: .bold))
                .foregroundStyle(Color(hex: "#6366f1"))
                .padding(.horizontal, SpendlySpacing.sm)
                .padding(.vertical, 3)
                .background(Color(hex: "#6366f1").opacity(0.12))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))
        }
        .padding(.bottom, SpendlySpacing.xs)
        .overlay(alignment: .bottom) {
            SPDivider()
        }
    }
}

// MARK: - System Branches & Assemblies

private extension IncidentHierarchyRootView {

    var branchesSection: some View {
        VStack(spacing: SpendlySpacing.lg) {

            // Section Title Row
            HStack {
                Text("SYSTEM BRANCHES & ASSEMBLIES")
                    .font(.system(size: 10, weight: .semibold))
                    .foregroundStyle(SpendlyColors.secondary)
                    .tracking(0.6)

                Spacer()

                Button { viewModel.beginAddBranch() } label: {
                    Text("+ Add Branch")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundStyle(SpendlyColors.primary)
                }
            }

            // Branch Cards
            ForEach(viewModel.filteredBranches) { branch in
                branchCard(branch)
            }
        }
    }

    func branchCard(_ branch: HierarchyBranch) -> some View {
        VStack(spacing: 0) {
            // Branch Header
            Button {
                withAnimation(.easeInOut(duration: 0.2)) {
                    viewModel.toggleBranchExpansion(branch)
                }
            } label: {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: branch.icon)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundStyle(SpendlyColors.info)
                        .frame(width: 24)

                    Text(branch.name)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Spacer()

                    // Edit button
                    Button {
                        viewModel.beginEditBranch(branch)
                    } label: {
                        Image(systemName: SpendlyIcon.edit.systemName)
                            .font(.system(size: 13))
                            .foregroundStyle(SpendlyColors.secondary.opacity(0.6))
                    }
                    .buttonStyle(.plain)

                    // Delete button
                    Button {
                        viewModel.requestDeleteBranch(branch)
                    } label: {
                        Image(systemName: SpendlyIcon.delete.systemName)
                            .font(.system(size: 13))
                            .foregroundStyle(SpendlyColors.secondary.opacity(0.6))
                    }
                    .buttonStyle(.plain)
                }
                .padding(SpendlySpacing.lg)
                .background(SpendlyColors.background(for: colorScheme))
            }
            .buttonStyle(.plain)

            // Divider between header and body
            if branch.isExpanded {
                SPDivider()
            }

            // Expandable Assembly List
            if branch.isExpanded {
                VStack(spacing: SpendlySpacing.sm) {
                    // Sub-header
                    HStack {
                        Text("Sub-Category Assemblies")
                            .font(.system(size: 11))
                            .foregroundStyle(SpendlyColors.secondary)

                        Spacer()

                        Button {
                            viewModel.beginAddAssembly(for: branch.id)
                        } label: {
                            Text("+ Add")
                                .font(.system(size: 12, weight: .semibold))
                                .foregroundStyle(SpendlyColors.primary)
                        }
                    }
                    .padding(.bottom, SpendlySpacing.xs)

                    // Assembly Items
                    ForEach(branch.assemblies) { assembly in
                        assemblyRow(assembly, in: branch)
                    }
                }
                .padding(SpendlySpacing.lg)
            }
        }
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                .strokeBorder(
                    colorScheme == .dark
                        ? Color.white.opacity(0.08)
                        : Color.black.opacity(0.08),
                    lineWidth: 1
                )
        )
    }

    func assemblyRow(_ assembly: SubCategoryAssembly, in branch: HierarchyBranch) -> some View {
        HStack {
            Text(assembly.name)
                .font(.system(size: 12, weight: .medium))
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme).opacity(0.85))

            Spacer()

            Image(systemName: SpendlyIcon.chevronRight.systemName)
                .font(.system(size: 11))
                .foregroundStyle(SpendlyColors.secondary.opacity(0.35))
        }
        .padding(.horizontal, SpendlySpacing.md)
        .padding(.vertical, SpendlySpacing.sm + 2)
        .background(
            colorScheme == .dark
                ? SpendlyColors.info.opacity(0.06)
                : SpendlyColors.info.opacity(0.04)
        )
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small + 2, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.small + 2, style: .continuous)
                .strokeBorder(SpendlyColors.info.opacity(0.15), lineWidth: 1)
        )
        .contextMenu {
            Button {
                viewModel.beginEditAssembly(assembly, in: branch.id)
            } label: {
                Label("Edit", systemImage: SpendlyIcon.edit.systemName)
            }
            Button(role: .destructive) {
                viewModel.requestDeleteAssembly(assembly, in: branch.id)
            } label: {
                Label("Delete", systemImage: SpendlyIcon.delete.systemName)
            }
        }
    }
}

// MARK: - Common Issue Templates

private extension IncidentHierarchyRootView {

    var issueTemplatesSection: some View {
        SPCard(elevation: .low) {
            VStack(spacing: SpendlySpacing.md) {
                // Header
                HStack {
                    Text("Common Issue Templates")
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Spacer()

                    Button { viewModel.beginCreateTemplate() } label: {
                        Text("+ Create Template")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundStyle(SpendlyColors.primary)
                    }
                }

                // Template Cards
                ForEach(viewModel.filteredTemplates) { template in
                    templateCard(template)
                }

                if viewModel.filteredTemplates.isEmpty {
                    Text("No templates match your search.")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, SpendlySpacing.md)
                }
            }
        }
    }

    func templateCard(_ template: IssueTemplate) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
            // Top row: category path + action buttons
            HStack(alignment: .top) {
                Text(template.categoryPath.uppercased())
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(Color(hex: "#6366f1"))
                    .tracking(0.3)

                Spacer()

                Button {
                    viewModel.beginEditTemplate(template)
                } label: {
                    Image(systemName: SpendlyIcon.edit.systemName)
                        .font(.system(size: 12))
                        .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                }
                .buttonStyle(.plain)

                Button {
                    viewModel.requestDeleteTemplate(template)
                } label: {
                    Image(systemName: SpendlyIcon.delete.systemName)
                        .font(.system(size: 12))
                        .foregroundStyle(SpendlyColors.secondary.opacity(0.5))
                }
                .buttonStyle(.plain)
            }

            Text(template.title)
                .font(.system(size: 12, weight: .semibold))
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            Text("\"\(template.descriptionSnippet)\"")
                .font(.system(size: 10))
                .italic()
                .foregroundStyle(SpendlyColors.secondary)
                .lineLimit(2)
        }
        .padding(SpendlySpacing.md)
        .background(
            colorScheme == .dark
                ? Color.white.opacity(0.03)
                : Color.black.opacity(0.02)
        )
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small + 2, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: SpendlyRadius.small + 2, style: .continuous)
                .strokeBorder(
                    colorScheme == .dark
                        ? Color.white.opacity(0.06)
                        : Color.black.opacity(0.05),
                    lineWidth: 1
                )
        )
    }
}

// MARK: - Asset Management

private extension IncidentHierarchyRootView {

    var assetManagementSection: some View {
        VStack(spacing: SpendlySpacing.lg) {

            // Section Title
            HStack {
                Text("ASSET MANAGEMENT")
                    .font(SpendlyFont.caption())
                    .fontWeight(.bold)
                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                    .tracking(0.8)

                Spacer()

                Text("IMAGE LIBRARY")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundStyle(SpendlyColors.info)
                    .padding(.horizontal, SpendlySpacing.sm)
                    .padding(.vertical, 3)
                    .background(SpendlyColors.info.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small, style: .continuous))
            }

            // App Icon & Login Hero Grid
            HStack(spacing: SpendlySpacing.lg) {
                assetUploadBox(title: "Main App Icon", subtitle: "1024x1024px")
                assetUploadBox(title: "Login Hero", subtitle: "16:9 Aspect")
            }

            // Service Image Gallery
            VStack(spacing: SpendlySpacing.md) {
                HStack {
                    Text("Service Image Gallery")
                        .font(SpendlyFont.bodyMedium())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    Spacer()

                    Button {} label: {
                        Text("+ Add New")
                            .font(.system(size: 12, weight: .semibold))
                            .foregroundStyle(SpendlyColors.primary)
                    }
                }

                // Gallery Grid
                LazyVGrid(columns: [
                    GridItem(.flexible(), spacing: SpendlySpacing.md),
                    GridItem(.flexible(), spacing: SpendlySpacing.md),
                    GridItem(.flexible(), spacing: SpendlySpacing.md),
                ], spacing: SpendlySpacing.md) {
                    ForEach(viewModel.assetImages) { asset in
                        assetThumbnail(asset)
                    }
                    // Add Placeholder
                    addAssetPlaceholder
                }
            }
        }
    }

    func assetUploadBox(title: String, subtitle: String) -> some View {
        VStack(spacing: SpendlySpacing.sm) {
            Text(title)
                .font(SpendlyFont.bodyMedium())
                .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

            VStack(spacing: SpendlySpacing.xs) {
                Image(systemName: "photo")
                    .font(.system(size: 22))
                    .foregroundStyle(SpendlyColors.secondary.opacity(0.4))

                Text(subtitle)
                    .font(.system(size: 9))
                    .foregroundStyle(SpendlyColors.secondary)
            }
            .frame(maxWidth: .infinity)
            .aspectRatio(1, contentMode: .fit)
            .background(
                colorScheme == .dark
                    ? Color.white.opacity(0.04)
                    : Color.black.opacity(0.03)
            )
            .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                    .strokeBorder(
                        colorScheme == .dark
                            ? Color.white.opacity(0.12)
                            : Color.black.opacity(0.12),
                        style: StrokeStyle(lineWidth: 2, dash: [6, 4])
                    )
            )
        }
    }

    func assetThumbnail(_ asset: AssetImage) -> some View {
        ZStack(alignment: .bottom) {
            RoundedRectangle(cornerRadius: SpendlyRadius.small + 2, style: .continuous)
                .fill(
                    colorScheme == .dark
                        ? SpendlyColors.surfaceDark
                        : SpendlyColors.backgroundLight
                )
                .aspectRatio(1, contentMode: .fit)
                .overlay {
                    Image(systemName: asset.systemIcon)
                        .font(.system(size: 28))
                        .foregroundStyle(SpendlyColors.secondary.opacity(0.4))
                }
                .overlay(
                    RoundedRectangle(cornerRadius: SpendlyRadius.small + 2, style: .continuous)
                        .strokeBorder(
                            colorScheme == .dark
                                ? Color.white.opacity(0.08)
                                : Color.black.opacity(0.08),
                            lineWidth: 1
                        )
                )

            // Label overlay at bottom
            Text(asset.label)
                .font(.system(size: 8, weight: .medium))
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 3)
                .background(Color.black.opacity(0.6))
                .clipShape(
                    UnevenRoundedRectangle(
                        bottomLeadingRadius: SpendlyRadius.small + 2,
                        bottomTrailingRadius: SpendlyRadius.small + 2,
                        style: .continuous
                    )
                )
        }
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.small + 2, style: .continuous))
    }

    var addAssetPlaceholder: some View {
        RoundedRectangle(cornerRadius: SpendlyRadius.small + 2, style: .continuous)
            .fill(
                colorScheme == .dark
                    ? Color.white.opacity(0.03)
                    : Color.black.opacity(0.02)
            )
            .aspectRatio(1, contentMode: .fit)
            .overlay {
                Image(systemName: "plus")
                    .font(.system(size: 22, weight: .light))
                    .foregroundStyle(SpendlyColors.secondary.opacity(0.3))
            }
            .overlay(
                RoundedRectangle(cornerRadius: SpendlyRadius.small + 2, style: .continuous)
                    .strokeBorder(
                        colorScheme == .dark
                            ? Color.white.opacity(0.1)
                            : Color.black.opacity(0.1),
                        style: StrokeStyle(lineWidth: 2, dash: [5, 4])
                    )
            )
    }
}

// MARK: - Sheets

private extension IncidentHierarchyRootView {

    // MARK: Add Branch Sheet

    var addBranchSheet: some View {
        NavigationStack {
            formSheetContent(title: "Add Branch") {
                viewModel.confirmAddBranch()
            } content: {
                VStack(spacing: SpendlySpacing.lg) {
                    SPInput("Branch Name", icon: "text.cursor", text: $viewModel.formName)

                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        Text("Icon")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)

                        iconPicker
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: Edit Branch Sheet

    var editBranchSheet: some View {
        NavigationStack {
            formSheetContent(title: "Edit Branch") {
                viewModel.confirmEditBranch()
            } content: {
                VStack(spacing: SpendlySpacing.lg) {
                    SPInput("Branch Name", icon: "text.cursor", text: $viewModel.formName)

                    VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
                        Text("Icon")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)

                        iconPicker
                    }
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: Add Assembly Sheet

    var addAssemblySheet: some View {
        NavigationStack {
            formSheetContent(title: "Add Assembly") {
                viewModel.confirmAddAssembly()
            } content: {
                SPInput("Assembly Name", icon: "rectangle.3.group", text: $viewModel.formName)
            }
        }
        .presentationDetents([.height(240)])
        .presentationDragIndicator(.visible)
    }

    // MARK: Edit Assembly Sheet

    var editAssemblySheet: some View {
        NavigationStack {
            formSheetContent(title: "Edit Assembly") {
                viewModel.confirmEditAssembly()
            } content: {
                SPInput("Assembly Name", icon: "rectangle.3.group", text: $viewModel.formName)
            }
        }
        .presentationDetents([.height(240)])
        .presentationDragIndicator(.visible)
    }

    // MARK: Create Template Sheet

    var createTemplateSheet: some View {
        NavigationStack {
            formSheetContent(title: "Create Template") {
                viewModel.confirmCreateTemplate()
            } content: {
                VStack(spacing: SpendlySpacing.lg) {
                    SPInput("Template Title", icon: "doc.text", text: $viewModel.formName)
                    SPInput("Category Path (e.g. Mechanical > Drive)", icon: "folder", text: $viewModel.formCategoryPath)
                    SPInput("Description / Steps", icon: "text.alignleft", text: $viewModel.formDescription)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: Edit Template Sheet

    var editTemplateSheet: some View {
        NavigationStack {
            formSheetContent(title: "Edit Template") {
                viewModel.confirmEditTemplate()
            } content: {
                VStack(spacing: SpendlySpacing.lg) {
                    SPInput("Template Title", icon: "doc.text", text: $viewModel.formName)
                    SPInput("Category Path", icon: "folder", text: $viewModel.formCategoryPath)
                    SPInput("Description / Steps", icon: "text.alignleft", text: $viewModel.formDescription)
                }
            }
        }
        .presentationDetents([.medium])
        .presentationDragIndicator(.visible)
    }

    // MARK: Shared Form Sheet Builder

    func formSheetContent<Content: View>(
        title: String,
        saveAction: @escaping () -> Void,
        @ViewBuilder content: () -> Content
    ) -> some View {
        VStack(spacing: SpendlySpacing.xl) {
            content()
            SPButton("Save", icon: "checkmark", style: .primary, action: saveAction)
        }
        .padding(SpendlySpacing.lg)
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: Icon Picker

    var iconPicker: some View {
        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: SpendlySpacing.sm) {
            ForEach(BranchIconOption.allCases, id: \.rawValue) { option in
                Button {
                    viewModel.formIcon = option.rawValue
                } label: {
                    VStack(spacing: SpendlySpacing.xs) {
                        Image(systemName: option.rawValue)
                            .font(.system(size: 18))
                            .frame(width: 36, height: 36)

                        Text(option.displayName)
                            .font(.system(size: 9, weight: .medium))
                    }
                    .foregroundStyle(
                        viewModel.formIcon == option.rawValue
                            ? SpendlyColors.primary
                            : SpendlyColors.secondary
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, SpendlySpacing.sm)
                    .background(
                        viewModel.formIcon == option.rawValue
                            ? SpendlyColors.primary.opacity(0.08)
                            : Color.clear
                    )
                    .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendlyRadius.medium, style: .continuous)
                            .strokeBorder(
                                viewModel.formIcon == option.rawValue
                                    ? SpendlyColors.primary.opacity(0.3)
                                    : Color.clear,
                                lineWidth: 1.5
                            )
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}

// MARK: - Preview

#Preview("Light") {
    IncidentHierarchyRootView()
        .environment(\.colorScheme, .light)
}

#Preview("Dark") {
    IncidentHierarchyRootView()
        .environment(\.colorScheme, .dark)
}
