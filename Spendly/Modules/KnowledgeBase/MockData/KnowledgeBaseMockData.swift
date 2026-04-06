import Foundation
import SpendlyCore

// MARK: - Knowledge Base Display Model

/// Lightweight view-model struct used for UI display in the Knowledge Base module.
/// Maps loosely to `Article` from CoreModels but adds KB-specific display fields
/// (author name, read time, thumbnail, category icon, view count, bookmarked state).
/// Represents a file attachment on an article (name + optional size label).
struct KBAttachment: Identifiable, Hashable, Codable {
    let id: UUID
    let fileName: String
    let fileSize: String          // human-readable, e.g. "2.4 MB"

    init(id: UUID = UUID(), fileName: String, fileSize: String = "") {
        self.id = id
        self.fileName = fileName
        self.fileSize = fileSize
    }
}

struct KBArticle: Identifiable, Hashable, Codable {
    let id: UUID
    let title: String
    let summary: String
    let content: String
    let category: KBCategory
    let authorName: String
    let authorInitials: String
    let readTimeMinutes: Int
    let viewCount: Int
    let createdAt: Date
    let updatedAt: Date
    let status: ArticleStatus
    let tags: [String]
    var isBookmarked: Bool
    var privateNotes: [KBNote]
    var attachments: [KBAttachment]

    // Computed
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy"
        return formatter.string(from: updatedAt)
    }

    var readTimeLabel: String {
        "\(readTimeMinutes) min read"
    }
}

// MARK: - Knowledge Base Category

enum KBCategory: String, CaseIterable, Hashable, Identifiable, Codable {
    case commonRepairs     = "Common Repairs"
    case machineManuals    = "Machine Manuals"
    case troubleshooting   = "Troubleshooting"
    case historicalSolutions = "Historical Solutions"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .commonRepairs:       return "wrench.and.screwdriver"
        case .machineManuals:      return "book.closed"
        case .troubleshooting:     return "exclamationmark.triangle"
        case .historicalSolutions: return "clock.arrow.counterclockwise"
        }
    }

    var color: SPBadgeStyle {
        switch self {
        case .commonRepairs:       return .info
        case .machineManuals:      return .custom(.indigo)
        case .troubleshooting:     return .warning
        case .historicalSolutions: return .success
        }
    }

    var backgroundHex: String {
        switch self {
        case .commonRepairs:       return "#3b82f6"
        case .machineManuals:      return "#6366f1"
        case .troubleshooting:     return "#f59e0b"
        case .historicalSolutions: return "#10b981"
        }
    }
}

// MARK: - Private Note

struct KBNote: Identifiable, Hashable, Codable {
    let id: UUID
    var content: String
    let createdAt: Date

    init(id: UUID = UUID(), content: String, createdAt: Date = Date()) {
        self.id = id
        self.content = content
        self.createdAt = createdAt
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d, yyyy 'at' h:mm a"
        return formatter.string(from: createdAt)
    }
}

// MARK: - FAQ Item

struct KBFAQItem: Identifiable, Hashable {
    let id: UUID
    let question: String
    let answer: String

    init(id: UUID = UUID(), question: String, answer: String) {
        self.id = id
        self.question = question
        self.answer = answer
    }
}

// MARK: - Mock Data

enum KnowledgeBaseMockData {

    // Date helpers
    private static func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: y, month: m, day: d)) ?? Date()
    }

    // MARK: Articles

    static let articles: [KBArticle] = [
        KBArticle(
            id: UUID(),
            title: "HVAC Compressor Failure: Common Causes & Remediation",
            summary: "Essential steps for diagnosing and fixing compressor failures in commercial HVAC systems.",
            content: """
            ## Overview
            Compressor failure is one of the most common and costly issues in commercial HVAC systems. This guide covers the primary causes, diagnostic steps, and proven remediation techniques.

            ## Common Causes
            1. **Electrical Issues** - Faulty capacitors, contactors, or wiring can prevent the compressor from starting or cause it to short-cycle.
            2. **Refrigerant Problems** - Low refrigerant from leaks causes the compressor to overheat. Overcharging can cause liquid slugging.
            3. **Mechanical Wear** - Bearing failures, valve damage, or scroll wear lead to reduced efficiency and eventual failure.
            4. **Contamination** - Moisture or debris in the refrigerant system causes acid buildup and internal corrosion.

            ## Step-by-Step Diagnosis
            **Step 1: Identify Symptoms**
            Listen for buzzing sounds and check if the outdoor unit fan is running while the compressor is not. Check for tripped breakers or blown fuses.

            **Step 2: Test Capacitor**
            Discharge and test the start/run capacitor with a multimeter. Capacitance should be within 5% of the rated value.

            **Step 3: Check Contactor**
            Inspect contactor points for pitting or burns. Replace if significant wear is visible. Test coil resistance.

            **Step 4: Measure Electrical Values**
            Check voltage at the compressor terminals. Measure amp draw and compare to nameplate RLA. Use a megohmmeter to test winding insulation.

            ## Pro Tips
            - Always verify terminal connections for tightness before assuming a compressor is dead. 20% of "failures" are just loose wires.
            - If the thermal overload is tripped, let it cool for 30 minutes before condemning. Use a wet rag to speed up cooling.
            - Document all readings for warranty claims and future reference.
            """,
            category: .troubleshooting,
            authorName: "James Davidson",
            authorInitials: "JD",
            readTimeMinutes: 8,
            viewCount: 342,
            createdAt: date(2025, 6, 10),
            updatedAt: date(2025, 10, 24),
            status: .published,
            tags: ["HVAC", "Compressor", "Troubleshooting", "Electrical"],
            isBookmarked: true,
            privateNotes: [
                KBNote(content: "Used this guide on the Industrial Unit #102 job. Step 2 was the key fix - bad capacitor.", createdAt: date(2025, 11, 5))
            ],
            attachments: [
                KBAttachment(fileName: "compressor_wiring_diagram.pdf", fileSize: "1.2 MB")
            ]
        ),
        KBArticle(
            id: UUID(),
            title: "Gen-X Industrial Compressor Maintenance Guide",
            summary: "Essential steps for quarterly valve checks on Gen-X industrial compressors.",
            content: """
            ## Quarterly Maintenance Protocol

            ### Pre-Inspection Safety
            1. Lock out / tag out the compressor unit
            2. Verify zero energy state
            3. Allow system to depressurize fully (minimum 15 minutes)

            ### Valve Inspection Procedure
            1. Remove valve cover plates using 10mm socket
            2. Inspect reed valves for cracks, warping, or carbon buildup
            3. Check valve seats for pitting or erosion
            4. Measure valve lift using feeler gauges (spec: 0.8-1.2mm)
            5. Replace valves showing any signs of fatigue cracking

            ### Oil Analysis
            - Draw 100ml sample from crankcase drain
            - Check for metal particulates visually
            - Send to lab for acid number and viscosity testing
            - Replace oil if acid number exceeds 0.5 mg KOH/g

            ### Filter Service
            - Replace intake air filters every quarter
            - Clean oil separator element with approved solvent
            - Inspect safety valve operation (should release at 125% of MAWP)

            ### Documentation
            Record all readings in the digital maintenance log. Flag any out-of-spec values for supervisor review.
            """,
            category: .machineManuals,
            authorName: "Raj Mehta",
            authorInitials: "RM",
            readTimeMinutes: 12,
            viewCount: 218,
            createdAt: date(2025, 3, 15),
            updatedAt: date(2025, 9, 8),
            status: .published,
            tags: ["Compressor", "Maintenance", "Gen-X", "Valves"],
            isBookmarked: false,
            privateNotes: [],
            attachments: [
                KBAttachment(fileName: "gen_x_valve_specs.pdf", fileSize: "3.1 MB"),
                KBAttachment(fileName: "oil_analysis_form.xlsx", fileSize: "84 KB")
            ]
        ),
        KBArticle(
            id: UUID(),
            title: "OSHA Safety Protocol 2024 - High Voltage Sites",
            summary: "Updated guidance on safety procedures for high-voltage electrical work sites.",
            content: """
            ## Updated OSHA Requirements for 2024

            ### Scope
            This protocol applies to all field service technicians working on equipment rated above 600V. Compliance is mandatory per OSHA 29 CFR 1910.269.

            ### Key Changes from 2023
            - Arc flash PPE requirements updated to NFPA 70E-2024
            - Minimum approach distances revised for voltages above 72.5kV
            - New requirements for drone inspections near energized equipment
            - Enhanced lockout/tagout documentation requirements

            ### Required PPE by Hazard Level
            **Category 1 (1.2 cal/cm2):** Arc-rated long sleeve shirt, safety glasses, hard hat
            **Category 2 (8 cal/cm2):** Arc-rated clothing, face shield, hard hat, leather gloves
            **Category 3 (25 cal/cm2):** Arc flash suit, arc-rated hood, insulated gloves
            **Category 4 (40 cal/cm2):** Full arc flash suit with hood and multilayer protection

            ### Emergency Procedures
            1. Maintain minimum 2-person teams for all high-voltage work
            2. Verify AED availability within 3-minute response distance
            3. Establish clear communication protocol with control room
            4. Document all near-miss incidents within 24 hours
            """,
            category: .commonRepairs,
            authorName: "Sarah Lopez",
            authorInitials: "SL",
            readTimeMinutes: 6,
            viewCount: 589,
            createdAt: date(2025, 1, 5),
            updatedAt: date(2025, 12, 1),
            status: .published,
            tags: ["OSHA", "Safety", "High Voltage", "PPE", "Compliance"],
            isBookmarked: true,
            privateNotes: [],
            attachments: []
        ),
        KBArticle(
            id: UUID(),
            title: "Hydraulic Pump Quick-Fix: Bleeding Lines in Under 10 Minutes",
            summary: "How to efficiently bleed hydraulic lines without specialized equipment.",
            content: """
            ## Quick Bleed Procedure

            ### When to Bleed
            - After replacing any hydraulic component
            - When system response becomes spongy or delayed
            - After extended period of non-use (>30 days)
            - Following any line disconnection

            ### Tools Required
            - 14mm wrench (bleed valve)
            - Clean catch container (2L minimum)
            - Shop towels
            - Fresh hydraulic fluid (same spec as system)

            ### Procedure
            1. Start the hydraulic power unit and let it warm to operating temperature (120-140F)
            2. Locate the highest bleed point in the circuit
            3. Place catch container below the bleed valve
            4. Slowly crack open the bleed valve (1/4 turn)
            5. Allow fluid to flow until no air bubbles are visible
            6. Close valve and check fluid level in reservoir
            7. Repeat for each bleed point, working from highest to lowest
            8. Cycle all actuators 5 times through full range of motion
            9. Re-check all bleed points for residual air

            ### Time-Saving Tips
            - Pre-fill replacement components with clean fluid before installation
            - Use clear tubing on bleed valves to easily spot air bubbles
            - Keep the reservoir topped off throughout the bleeding process
            """,
            category: .commonRepairs,
            authorName: "Mike Chen",
            authorInitials: "MC",
            readTimeMinutes: 5,
            viewCount: 427,
            createdAt: date(2025, 5, 20),
            updatedAt: date(2025, 11, 15),
            status: .published,
            tags: ["Hydraulic", "Quick Fix", "Bleeding", "Maintenance"],
            isBookmarked: false,
            privateNotes: [
                KBNote(content: "This works great on the H-12 pump systems. Saved 30 minutes on the last job.", createdAt: date(2025, 12, 3))
            ],
            attachments: []
        ),
        KBArticle(
            id: UUID(),
            title: "Advanced HVAC Leak Detection Techniques",
            summary: "New techniques for detecting refrigerant leaks in residential split-systems.",
            content: """
            ## Modern Leak Detection Methods

            ### Electronic Leak Detectors
            Modern heated diode and infrared detectors can sense refrigerant concentrations as low as 0.1 oz/year. Best practices:
            - Calibrate before each use
            - Move probe at 1-2 inches per second
            - Check all brazed joints, service valves, and Schrader cores
            - Pay special attention to the evaporator coil U-bends

            ### Ultrasonic Detection
            For larger leaks in noisy environments:
            - Use directional microphone attachment
            - Scan at pressurized system operating pressure
            - Effective for detecting leaks in insulated lines

            ### UV Dye Method
            Best for elusive slow leaks:
            1. Inject UV dye into the liquid line service port
            2. Run system for minimum 2 hours
            3. Scan all accessible components with UV light
            4. Mark and photograph all fluorescent spots

            ### Nitrogen Pressure Test
            For major leak confirmation:
            1. Recover all refrigerant
            2. Pressurize with dry nitrogen to 150 PSI (low side) or 400 PSI (high side)
            3. Add trace refrigerant (5-10 PSI R-22 or R-410A)
            4. Use electronic detector to pinpoint leak location
            5. Monitor pressure gauge for 24 hours to confirm repair

            ### Documentation
            Record leak location, size estimate, and repair method. EPA Section 608 requires documentation of all refrigerant handling.
            """,
            category: .troubleshooting,
            authorName: "Anita Martinez",
            authorInitials: "AM",
            readTimeMinutes: 10,
            viewCount: 156,
            createdAt: date(2025, 8, 12),
            updatedAt: date(2025, 10, 30),
            status: .published,
            tags: ["HVAC", "Leak Detection", "Refrigerant", "Split-System"],
            isBookmarked: false,
            privateNotes: [],
            attachments: []
        ),
        KBArticle(
            id: UUID(),
            title: "Toolbox Checklist: Heavy Lift Crane Operations",
            summary: "Essential gear and safety equipment checklist for crane operations.",
            content: """
            ## Pre-Operation Checklist

            ### Mandatory Documentation
            - [ ] Valid crane operator certification
            - [ ] Current annual inspection certificate
            - [ ] Lift plan signed by competent person
            - [ ] Site-specific safety assessment completed
            - [ ] Weather conditions verified (wind < 20 mph)

            ### Required Equipment
            - [ ] Appropriate slings and rigging rated for load
            - [ ] Tag lines (minimum 2)
            - [ ] Load-indicating device calibrated and functional
            - [ ] Fire extinguisher (20 lb ABC minimum)
            - [ ] First aid kit
            - [ ] Spill containment materials

            ### PPE Requirements
            - [ ] Hard hat (ANSI Type II)
            - [ ] High-visibility vest (Class 2 minimum)
            - [ ] Steel-toe boots
            - [ ] Safety glasses
            - [ ] Leather work gloves
            - [ ] Fall protection (for personnel working at height)

            ### Communication Equipment
            - [ ] Two-way radios (minimum 2 units)
            - [ ] Hand signal chart posted
            - [ ] Air horn for emergency stop
            - [ ] Designated signal person identified

            ### Post-Operation
            - [ ] Crane secured in travel position
            - [ ] Outriggers retracted and pinned
            - [ ] Incident report filed (if any near-misses)
            - [ ] Fuel level checked and logged
            """,
            category: .historicalSolutions,
            authorName: "Tom Brewer",
            authorInitials: "TB",
            readTimeMinutes: 7,
            viewCount: 298,
            createdAt: date(2025, 4, 1),
            updatedAt: date(2025, 8, 22),
            status: .published,
            tags: ["Crane", "Heavy Lift", "Safety", "Checklist", "Operations"],
            isBookmarked: false,
            privateNotes: [],
            attachments: []
        ),
    ]

    // MARK: FAQ Items

    static let faqItems: [KBFAQItem] = [
        KBFAQItem(
            question: "How do I save an article for offline access?",
            answer: "Tap the bookmark icon on any article to save it. Bookmarked articles are available offline under your saved items."
        ),
        KBFAQItem(
            question: "Can I add private notes to an article?",
            answer: "Yes, open any article and scroll to the Private Notes section. Your notes are only visible to you and are synced across your devices."
        ),
        KBFAQItem(
            question: "How do I submit a new knowledge base article?",
            answer: "Tap the + button to create a new article. Fill in the title, select a category, write your content, and tap Publish when ready."
        ),
        KBFAQItem(
            question: "Who can see the articles I create?",
            answer: "Published articles are visible to all members of your organization. Draft articles are only visible to you until published."
        ),
        KBFAQItem(
            question: "How is the recommended content selected?",
            answer: "Recommendations are based on your role, active assignments, equipment skills, and recently viewed articles."
        ),
    ]
}
