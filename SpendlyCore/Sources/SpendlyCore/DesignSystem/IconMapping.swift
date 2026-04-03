import SwiftUI

public enum SpendlyIcon: String, CaseIterable {
    case arrowBack
    case moreVert
    case search
    case tune
    case notifications
    case notificationsFill
    case person
    case personFill
    case call
    case chatBubble
    case requestQuote
    case location
    case schedule
    case checkCircle
    case add
    case addCircle
    case delete
    case edit
    case share
    case download
    case send
    case camera
    case image
    case pause
    case stop
    case play
    case timer
    case receipt
    case settings
    case settingsFill
    case dashboard
    case dashboardFill
    case calendar
    case history
    case inventory
    case lock
    case visibility
    case visibilityOff
    case face
    case fingerprint
    case chevronRight
    case info
    case warning
    case close
    case menu
    case bookmark
    case star
    case verified
    case attach
    case mic
    case micOff
    case map
    case directions

    public var systemName: String {
        switch self {
        case .arrowBack:        return "chevron.left"
        case .moreVert:         return "ellipsis"
        case .search:           return "magnifyingglass"
        case .tune:             return "slider.horizontal.3"
        case .notifications:    return "bell"
        case .notificationsFill:return "bell.fill"
        case .person:           return "person"
        case .personFill:       return "person.fill"
        case .call:             return "phone"
        case .chatBubble:       return "message"
        case .requestQuote:     return "doc.text"
        case .location:         return "mappin.and.ellipse"
        case .schedule:         return "clock"
        case .checkCircle:      return "checkmark.circle.fill"
        case .add:              return "plus"
        case .addCircle:        return "plus.circle.fill"
        case .delete:           return "trash"
        case .edit:             return "pencil"
        case .share:            return "square.and.arrow.up"
        case .download:         return "arrow.down.circle"
        case .send:             return "paperplane.fill"
        case .camera:           return "camera"
        case .image:            return "photo"
        case .pause:            return "pause.fill"
        case .stop:             return "stop.fill"
        case .play:             return "play.fill"
        case .timer:            return "timer"
        case .receipt:          return "doc.plaintext"
        case .settings:         return "gearshape"
        case .settingsFill:     return "gearshape.fill"
        case .dashboard:        return "square.grid.2x2"
        case .dashboardFill:    return "square.grid.2x2.fill"
        case .calendar:         return "calendar"
        case .history:          return "clock.arrow.counterclockwise"
        case .inventory:        return "shippingbox"
        case .lock:             return "lock"
        case .visibility:       return "eye"
        case .visibilityOff:    return "eye.slash"
        case .face:             return "faceid"
        case .fingerprint:      return "touchid"
        case .chevronRight:     return "chevron.right"
        case .info:             return "info.circle"
        case .warning:          return "exclamationmark.triangle"
        case .close:            return "xmark"
        case .menu:             return "line.3.horizontal"
        case .bookmark:         return "bookmark"
        case .star:             return "star.fill"
        case .verified:         return "checkmark.seal.fill"
        case .attach:           return "paperclip"
        case .mic:              return "mic.fill"
        case .micOff:           return "mic.slash"
        case .map:              return "map"
        case .directions:       return "arrow.triangle.turn.up.right.diamond"
        }
    }
}

// MARK: - Convenience View

public extension SpendlyIcon {
    /// Returns an `Image` configured with the mapped SF Symbol.
    func image() -> Image {
        Image(systemName: systemName)
    }
}
