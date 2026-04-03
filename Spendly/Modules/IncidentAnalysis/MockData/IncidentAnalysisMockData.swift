import Foundation
import SpendlyCore

// MARK: - Incident Analysis Display Model

struct AnalysisIncident: Identifiable, Hashable {
    let id: UUID
    let code: String                    // e.g. "#INC-4291"
    let title: String
    let category: IncidentAnalysisCategory
    let severity: IncidentSeverity
    let status: IncidentAnalysisStatus
    let assignedTo: String
    let assignedInitials: String
    let machineID: String
    let machineModel: String
    let companyName: String
    let assemblyArea: String
    let observation: String
    let detailedDescription: String
    let resolution: String?
    let resolvedBy: String?
    let reportedDate: Date
    let resolvedDate: Date?
    let failureProbability: Double      // 0.0 ... 1.0, for failure prediction
    let rootCauses: [RootCause]
    let timelineEvents: [IncidentTimelineEvent]
    let aiInsights: [String]
}

// MARK: - Supporting Types

enum IncidentAnalysisCategory: String, CaseIterable, Hashable {
    case electrical    = "Electrical"
    case mechanical    = "Mechanical"
    case pneumatic     = "Pneumatic"
    case software      = "Software"
    case hardware      = "Hardware"

    var icon: String {
        switch self {
        case .electrical: return "bolt.fill"
        case .mechanical: return "gearshape.2.fill"
        case .pneumatic:  return "wind"
        case .software:   return "cpu"
        case .hardware:   return "wrench.and.screwdriver.fill"
        }
    }
}

enum IncidentAnalysisStatus: String, CaseIterable, Hashable {
    case open        = "Open"
    case inProgress  = "In Progress"
    case resolved    = "Resolved"
    case closed      = "Closed"

    var badgeStyle: SPBadgeStyle {
        switch self {
        case .open:       return .error
        case .inProgress: return .warning
        case .resolved:   return .success
        case .closed:     return .neutral
        }
    }
}

struct RootCause: Identifiable, Hashable {
    let id = UUID()
    let branch: String       // e.g. "Branch 01"
    let branchTitle: String  // e.g. "Electrical & Programming"
    let icon: String
    let items: [RootCauseItem]
}

struct RootCauseItem: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let severityLevel: RootCauseSeverityLevel
}

enum RootCauseSeverityLevel: Hashable {
    case critical   // red
    case warning    // orange
    case normal     // green

    var dotColor: String {
        switch self {
        case .critical: return "red"
        case .warning:  return "orange"
        case .normal:   return "green"
        }
    }
}

struct IncidentTimelineEvent: Identifiable, Hashable {
    let id = UUID()
    let title: String
    let subtitle: String?
    let time: String
    let status: SPTimelineStatus
}

// MARK: - Mock Data

enum IncidentAnalysisMockData {

    // MARK: Date Helpers

    private static func date(_ y: Int, _ m: Int, _ d: Int) -> Date {
        Calendar.current.date(from: DateComponents(year: y, month: m, day: d))!
    }

    // MARK: Incidents

    static let incidents: [AnalysisIncident] = [
        // 1. Servo Drive Overload - Critical, In Progress
        AnalysisIncident(
            id: UUID(),
            code: "#INC-4291",
            title: "Servo Drive Overload",
            category: .electrical,
            severity: .critical,
            status: .inProgress,
            assignedTo: "John Doe",
            assignedInitials: "JD",
            machineID: "#MAC-4492",
            machineModel: "Titan XL-200",
            companyName: "Global Logistics Corp.",
            assemblyArea: "Packaging Line B",
            observation: "Servo motor drawing 40% above rated current during high-speed cycles. Thermal protection tripping after 22 minutes of continuous operation.",
            detailedDescription: "Operator reported intermittent servo faults causing unplanned stops on Packaging Line B. Drive diagnostics show overcurrent condition on axis 3. Suspected mechanical binding or encoder feedback issue. Production throughput reduced by 35%.",
            resolution: nil,
            resolvedBy: nil,
            reportedDate: date(2026, 3, 28),
            resolvedDate: nil,
            failureProbability: 0.82,
            rootCauses: [
                RootCause(branch: "Branch 01", branchTitle: "Electrical & Programming", icon: "bolt.fill", items: [
                    RootCauseItem(name: "Servo & Drive Faults", severityLevel: .critical),
                    RootCauseItem(name: "PLC Communication Lag", severityLevel: .warning),
                    RootCauseItem(name: "Sensor Miscalibration", severityLevel: .normal),
                ]),
                RootCause(branch: "Branch 02", branchTitle: "Mechanical & Hardware", icon: "gearshape.2.fill", items: [
                    RootCauseItem(name: "Motor Bearing Wear", severityLevel: .critical),
                    RootCauseItem(name: "Coupling Misalignment", severityLevel: .warning),
                ]),
            ],
            timelineEvents: [
                IncidentTimelineEvent(title: "Incident Reported", subtitle: "Operator flagged servo fault on Line B", time: "Mar 28, 9:15 AM", status: .completed),
                IncidentTimelineEvent(title: "Diagnostics Started", subtitle: "Tech #882 began drive analysis", time: "Mar 28, 10:30 AM", status: .completed),
                IncidentTimelineEvent(title: "Root Cause Identified", subtitle: "Encoder drift + bearing wear confirmed", time: "Mar 28, 2:00 PM", status: .completed),
                IncidentTimelineEvent(title: "Parts Ordered", subtitle: "Replacement servo motor and encoder", time: "Mar 29, 8:00 AM", status: .active),
                IncidentTimelineEvent(title: "Repair Scheduled", subtitle: "Awaiting parts delivery", time: "Apr 2", status: .upcoming),
            ],
            aiInsights: [
                "Recurring pattern: Servo overcurrent in Titan XL-200 series correlates with bearing wear after 8,000 operating hours.",
                "Suggested preventative: Replace motor bearings at 7,500-hour intervals to avoid unplanned downtime.",
                "Similar incidents resolved 40% faster when encoder replacement was done simultaneously.",
            ]
        ),

        // 2. Seal Array Misalignment - High, Open
        AnalysisIncident(
            id: UUID(),
            code: "#INC-4288",
            title: "Seal Array Misalignment",
            category: .mechanical,
            severity: .high,
            status: .open,
            assignedTo: "Sarah Miller",
            assignedInitials: "SM",
            machineID: "#MAC-3371",
            machineModel: "Vega 285 PM",
            companyName: "Pacific Foods Inc.",
            assemblyArea: "Pouch Filling Station",
            observation: "Side seal bars producing inconsistent seal strength. Reject rate increased from 2% to 18% on pouch line.",
            detailedDescription: "Quality control flagged high reject rates on the Vega 285 pouch maker. Seal integrity tests show variable peel strength across the seal array. Visual inspection reveals uneven contact pressure on seal bars 3 and 4. Possible thermal expansion issue or mechanical wear on guide rails.",
            resolution: nil,
            resolvedBy: nil,
            reportedDate: date(2026, 3, 30),
            resolvedDate: nil,
            failureProbability: 0.65,
            rootCauses: [
                RootCause(branch: "Branch 01", branchTitle: "Mechanical & Hardware", icon: "gearshape.2.fill", items: [
                    RootCauseItem(name: "Seal Bar Wear", severityLevel: .critical),
                    RootCauseItem(name: "Guide Rail Degradation", severityLevel: .warning),
                    RootCauseItem(name: "Spring Tension Loss", severityLevel: .normal),
                ]),
                RootCause(branch: "Branch 02", branchTitle: "Thermal Control", icon: "thermometer.medium", items: [
                    RootCauseItem(name: "Heater Cartridge Drift", severityLevel: .warning),
                    RootCauseItem(name: "RTD Sensor Aging", severityLevel: .normal),
                ]),
            ],
            timelineEvents: [
                IncidentTimelineEvent(title: "QC Alert Raised", subtitle: "Reject rate exceeded 15% threshold", time: "Mar 30, 7:00 AM", status: .completed),
                IncidentTimelineEvent(title: "Incident Created", subtitle: "Assigned to Sarah Miller", time: "Mar 30, 8:30 AM", status: .completed),
                IncidentTimelineEvent(title: "Initial Assessment", subtitle: "Pending on-site inspection", time: "Pending", status: .upcoming),
            ],
            aiInsights: [
                "Seal bar misalignment on Vega 285 models typically caused by guide rail wear after 5,000 cycles.",
                "Recommended action: Full seal array inspection and guide rail replacement.",
            ]
        ),

        // 3. Main Conveyor Lubrication - Low, Resolved
        AnalysisIncident(
            id: UUID(),
            code: "#INC-4285",
            title: "Main Conveyor Lubrication",
            category: .hardware,
            severity: .low,
            status: .resolved,
            assignedTo: "Bob Knight",
            assignedInitials: "BK",
            machineID: "#MAC-4492",
            machineModel: "Titan XL-200",
            companyName: "Global Logistics Corp.",
            assemblyArea: "Packaging Line B",
            observation: "Conveyor chain producing audible clicking noise. Lubrication schedule overdue by 2 weeks.",
            detailedDescription: "Routine inspection identified dry chain links on the main product conveyor. Noise levels measured at 78 dB, above the 65 dB baseline. Chain tension within spec but lubrication film depleted. No product damage observed but preventive action required.",
            resolution: "Applied food-grade lubricant to all chain links. Adjusted auto-lubrication timer from 8-hour to 6-hour intervals. Replaced 3 worn chain guides. Noise level returned to 62 dB baseline.",
            resolvedBy: "Tech #445 (Bob Knight)",
            reportedDate: date(2026, 3, 20),
            resolvedDate: date(2026, 3, 21),
            failureProbability: 0.12,
            rootCauses: [
                RootCause(branch: "Branch 01", branchTitle: "Maintenance Schedule", icon: "calendar.badge.clock", items: [
                    RootCauseItem(name: "Overdue Lubrication", severityLevel: .warning),
                    RootCauseItem(name: "Timer Misconfiguration", severityLevel: .normal),
                ]),
            ],
            timelineEvents: [
                IncidentTimelineEvent(title: "Noise Detected", subtitle: "Routine inspection by maintenance team", time: "Mar 20, 2:00 PM", status: .completed),
                IncidentTimelineEvent(title: "Incident Logged", subtitle: "Low priority, assigned to Bob Knight", time: "Mar 20, 3:00 PM", status: .completed),
                IncidentTimelineEvent(title: "Lubrication Applied", subtitle: "Chain guides replaced", time: "Mar 21, 9:00 AM", status: .completed),
                IncidentTimelineEvent(title: "Verification Complete", subtitle: "Noise level at 62 dB baseline", time: "Mar 21, 11:00 AM", status: .completed),
            ],
            aiInsights: [
                "Auto-lubrication timer drift is a known issue on Titan XL-200 firmware < v3.8. Firmware update recommended.",
                "Quarterly chain guide inspection can reduce unplanned conveyor stops by 30%.",
            ]
        ),

        // 4. PLC Communication Timeout - High, Resolved
        AnalysisIncident(
            id: UUID(),
            code: "#INC-4279",
            title: "PLC Communication Timeout",
            category: .software,
            severity: .high,
            status: .resolved,
            assignedTo: "Mike Chen",
            assignedInitials: "MC",
            machineID: "#MAC-5510",
            machineModel: "ConvertPro 750P",
            companyName: "Industrial Logistics Corp.",
            assemblyArea: "Converting Line 1",
            observation: "PLC losing Ethernet/IP communication with HMI panel every 15-20 minutes. Auto-recovery taking 45 seconds, causing production gaps.",
            detailedDescription: "Network diagnostics revealed intermittent packet loss between PLC rack and HMI switch. CRC error rate elevated on port 7. Suspected cable degradation or switch port failure. Production line experiencing 3-4 unplanned micro-stops per shift.",
            resolution: "Replaced Ethernet cable run from PLC rack to network switch (cable showed jacket damage near cable tray bend). Replaced switch port module. Updated PLC firmware to v4.2.1 with improved timeout handling. Monitored for 48 hours with zero communication faults.",
            resolvedBy: "Tech #221 (Mike Chen)",
            reportedDate: date(2026, 3, 15),
            resolvedDate: date(2026, 3, 18),
            failureProbability: 0.08,
            rootCauses: [
                RootCause(branch: "Branch 01", branchTitle: "Network Infrastructure", icon: "network", items: [
                    RootCauseItem(name: "Cable Degradation", severityLevel: .critical),
                    RootCauseItem(name: "Switch Port Failure", severityLevel: .warning),
                ]),
                RootCause(branch: "Branch 02", branchTitle: "Software & Firmware", icon: "cpu", items: [
                    RootCauseItem(name: "PLC Timeout Config", severityLevel: .warning),
                    RootCauseItem(name: "Firmware Bug", severityLevel: .normal),
                ]),
            ],
            timelineEvents: [
                IncidentTimelineEvent(title: "Communication Faults Logged", subtitle: "HMI reported 12 timeouts in 4 hours", time: "Mar 15, 6:00 AM", status: .completed),
                IncidentTimelineEvent(title: "Network Diagnostics", subtitle: "CRC errors isolated to port 7", time: "Mar 15, 10:00 AM", status: .completed),
                IncidentTimelineEvent(title: "Cable & Port Replaced", subtitle: "New Cat6A run installed", time: "Mar 16, 8:00 AM", status: .completed),
                IncidentTimelineEvent(title: "Firmware Updated", subtitle: "PLC firmware v4.2.1 deployed", time: "Mar 17, 9:00 AM", status: .completed),
                IncidentTimelineEvent(title: "48-Hour Verification", subtitle: "Zero faults recorded", time: "Mar 18, 9:00 AM", status: .completed),
            ],
            aiInsights: [
                "Ethernet cable failures near cable tray bends account for 28% of PLC communication incidents.",
                "Recommended: Install strain relief at all cable tray transitions during next maintenance window.",
                "PLC firmware v4.2.1 includes improved watchdog recovery, reducing timeout impact from 45s to 8s.",
            ]
        ),

        // 5. Air Leak on Cylinder Bank - Medium, Closed
        AnalysisIncident(
            id: UUID(),
            code: "#INC-4270",
            title: "Air Leak on Cylinder Bank",
            category: .pneumatic,
            severity: .medium,
            status: .closed,
            assignedTo: "Raj Mehta",
            assignedInitials: "RM",
            machineID: "#MAC-6620",
            machineModel: "SP-60 Sachet",
            companyName: "Pacific Foods Inc.",
            assemblyArea: "Sachet Line 5",
            observation: "Compressed air consumption increased 25% over baseline. Audible hissing detected near cylinder bank A3.",
            detailedDescription: "Energy monitoring system flagged abnormal compressor duty cycle. On-site ultrasonic leak detection confirmed two leak points: one at cylinder A3 port fitting and one at a quick-connect on the manifold block. Cylinder cycling speed slightly degraded but within tolerance.",
            resolution: "Replaced worn O-ring on cylinder A3 port fitting. Replaced quick-connect coupling on manifold block with brass fitting. Applied thread sealant to all connections on bank A3. Air consumption returned to baseline within 2 hours. Total downtime: 45 minutes.",
            resolvedBy: "Tech #660 (Raj Mehta)",
            reportedDate: date(2026, 3, 10),
            resolvedDate: date(2026, 3, 10),
            failureProbability: 0.05,
            rootCauses: [
                RootCause(branch: "Branch 01", branchTitle: "Pneumatic System", icon: "wind", items: [
                    RootCauseItem(name: "O-Ring Wear", severityLevel: .warning),
                    RootCauseItem(name: "Quick-Connect Fatigue", severityLevel: .warning),
                    RootCauseItem(name: "Thread Sealant Degradation", severityLevel: .normal),
                ]),
            ],
            timelineEvents: [
                IncidentTimelineEvent(title: "Energy Alert Triggered", subtitle: "Compressor duty cycle 25% above baseline", time: "Mar 10, 6:30 AM", status: .completed),
                IncidentTimelineEvent(title: "Leak Detection Scan", subtitle: "Ultrasonic scan identified 2 leak points", time: "Mar 10, 8:00 AM", status: .completed),
                IncidentTimelineEvent(title: "Repairs Completed", subtitle: "O-ring and coupling replaced", time: "Mar 10, 10:00 AM", status: .completed),
                IncidentTimelineEvent(title: "Verification & Closed", subtitle: "Air consumption at baseline", time: "Mar 10, 12:00 PM", status: .completed),
            ],
            aiInsights: [
                "Quick-connect fittings on SP-60 manifolds have a 12-month service life under continuous duty.",
                "Quarterly ultrasonic leak audits can reduce compressed air waste by up to 20%.",
            ]
        ),
    ]

    // MARK: - Chart Data

    static let incidentsByCategory: [SPChartDataPoint] = [
        SPChartDataPoint(label: "Electrical", value: 42),
        SPChartDataPoint(label: "Mechanical", value: 35),
        SPChartDataPoint(label: "Pneumatic", value: 22),
        SPChartDataPoint(label: "Software", value: 18),
        SPChartDataPoint(label: "Hardware", value: 11),
    ]

    static let incidentTrend: [SPChartDataPoint] = [
        SPChartDataPoint(label: "Jan", value: 18),
        SPChartDataPoint(label: "Feb", value: 24),
        SPChartDataPoint(label: "Mar", value: 15),
        SPChartDataPoint(label: "Apr", value: 31),
        SPChartDataPoint(label: "May", value: 22),
        SPChartDataPoint(label: "Jun", value: 19),
    ]

    static let severityDistribution: [SPChartDataPoint] = [
        SPChartDataPoint(label: "Critical", value: 14),
        SPChartDataPoint(label: "High", value: 35),
        SPChartDataPoint(label: "Medium", value: 52),
        SPChartDataPoint(label: "Low", value: 27),
    ]
}
