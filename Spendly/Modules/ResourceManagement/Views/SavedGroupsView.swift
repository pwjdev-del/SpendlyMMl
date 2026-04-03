import SwiftUI
import SpendlyCore

struct SavedGroupsView: View {
    @Bindable var vm: ResourceManagementViewModel
    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: SpendlySpacing.md) {

                // MARK: - Search
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundStyle(SpendlyColors.secondary)
                    TextField("Search groups...", text: $vm.groupSearchText)
                        .font(SpendlyFont.body())
                }
                .padding(SpendlySpacing.sm)
                .background(SpendlyColors.surface(for: colorScheme))
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))

                // MARK: - Create Group
                Button {
                    vm.showingCreateGroup = true
                } label: {
                    Label("Create New Group", systemImage: "plus.circle.fill")
                        .font(SpendlyFont.headline())
                        .frame(maxWidth: .infinity)
                        .padding(SpendlySpacing.sm)
                }
                .buttonStyle(.borderedProminent)
                .tint(SpendlyColors.primary)

                // MARK: - Groups List
                if vm.filteredGroups.isEmpty {
                    ContentUnavailableView(
                        "No Groups",
                        systemImage: "person.3",
                        description: Text("Create a group to organize technicians.")
                    )
                    .frame(maxWidth: .infinity)
                    .padding(.top, SpendlySpacing.xl)
                } else {
                    LazyVStack(spacing: SpendlySpacing.sm) {
                        ForEach(vm.filteredGroups) { group in
                            groupCard(group)
                        }
                    }
                }
            }
            .padding(SpendlySpacing.md)
        }
        .sheet(isPresented: $vm.showingCreateGroup) {
            createGroupSheet
        }
    }

    // MARK: - Group Card

    private func groupCard(_ group: SavedTechGroup) -> some View {
        VStack(alignment: .leading, spacing: SpendlySpacing.sm) {
            Button {
                vm.toggleGroupExpansion(group)
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(group.name)
                            .font(SpendlyFont.headline())
                            .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                        Text("\(group.technicianCount) technicians")
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondary)
                    }
                    Spacer()
                    Image(systemName: vm.expandedGroupID == group.id ? "chevron.up" : "chevron.down")
                        .font(.caption)
                        .foregroundStyle(SpendlyColors.secondary)
                }
            }
            .buttonStyle(.plain)

            if vm.expandedGroupID == group.id {
                Divider()

                let members = vm.membersForGroup(group)
                if members.isEmpty {
                    Text("No matching technicians loaded.")
                        .font(SpendlyFont.caption())
                        .foregroundStyle(SpendlyColors.secondary)
                        .padding(.vertical, SpendlySpacing.xs)
                } else {
                    ForEach(members) { tech in
                        HStack(spacing: SpendlySpacing.sm) {
                            Circle()
                                .fill(SpendlyColors.primary.opacity(0.15))
                                .frame(width: 32, height: 32)
                                .overlay(
                                    Text(tech.initials)
                                        .font(SpendlyFont.caption())
                                        .foregroundStyle(SpendlyColors.primary)
                                )
                            VStack(alignment: .leading) {
                                Text(tech.name)
                                    .font(SpendlyFont.body())
                                    .foregroundStyle(SpendlyColors.foreground(for: colorScheme))
                                Text(tech.specialty)
                                    .font(SpendlyFont.caption())
                                    .foregroundStyle(SpendlyColors.secondary)
                            }
                            Spacer()
                            SPBadge(tech.status.label, style: tech.status.badgeStyle)
                        }
                    }
                }

                HStack {
                    Spacer()
                    Button(role: .destructive) {
                        vm.deleteGroup(group)
                    } label: {
                        Label("Delete Group", systemImage: "trash")
                            .font(SpendlyFont.caption())
                    }
                }
            }
        }
        .padding(SpendlySpacing.md)
        .background(SpendlyColors.surface(for: colorScheme))
        .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large))
    }

    // MARK: - Create Group Sheet

    private var createGroupSheet: some View {
        NavigationStack {
            VStack(spacing: SpendlySpacing.lg) {
                TextField("Group Name", text: $vm.newGroupName)
                    .textFieldStyle(.roundedBorder)
                    .padding(.horizontal, SpendlySpacing.md)

                Spacer()
            }
            .padding(.top, SpendlySpacing.lg)
            .navigationTitle("New Group")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        vm.showingCreateGroup = false
                        vm.newGroupName = ""
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        vm.createGroup()
                    }
                    .disabled(vm.newGroupName.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
        .presentationDetents([.medium])
    }
}
