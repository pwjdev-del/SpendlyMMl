import Foundation

// MARK: - Mock Data

enum IncidentHierarchyMockData {

    static let branches: [HierarchyBranch] = [
        HierarchyBranch(
            name: "Electrical & Programming Issues",
            icon: "bolt",
            assemblies: [
                SubCategoryAssembly(name: "Servo & Drive Faults"),
                SubCategoryAssembly(name: "Control Logic & Software"),
                SubCategoryAssembly(name: "Safety Circuits"),
            ]
        ),
        HierarchyBranch(
            name: "Mechanical & Hardware Issues",
            icon: "gearshape",
            assemblies: [
                SubCategoryAssembly(name: "Seal Array Failures"),
                SubCategoryAssembly(name: "Pouch Transport & Feeders"),
            ]
        ),
        HierarchyBranch(
            name: "Pneumatic System Issues",
            icon: "wind",
            assemblies: [
                SubCategoryAssembly(name: "Cylinder Failures"),
                SubCategoryAssembly(name: "Air Supply"),
            ]
        ),
    ]

    static let issueTemplates: [IssueTemplate] = [
        IssueTemplate(
            categoryPath: "Mechanical > Drive Train",
            title: "Excessive Vibration during high-load",
            descriptionSnippet: "Check mounting bolts and alignment of primary gear..."
        ),
        IssueTemplate(
            categoryPath: "Electrical > Servo Faults",
            title: "Communication Timeout Error",
            descriptionSnippet: "Reset the controller unit and check RS485 wiring continuity..."
        ),
    ]

    static let assetImages: [AssetImage] = [
        AssetImage(label: "Plumbing", systemIcon: "wrench.and.screwdriver"),
        AssetImage(label: "Electrical", systemIcon: "bolt"),
    ]
}
