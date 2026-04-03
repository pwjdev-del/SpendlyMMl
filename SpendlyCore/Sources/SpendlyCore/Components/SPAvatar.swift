import SwiftUI

// MARK: - Avatar Size

public enum SPAvatarSize {
    case sm, md, lg

    public var dimension: CGFloat {
        switch self {
        case .sm: return 32
        case .md: return 40
        case .lg: return 56
        }
    }

    var fontSize: Font {
        switch self {
        case .sm: return SpendlyFont.caption()
        case .md: return SpendlyFont.body()
        case .lg: return SpendlyFont.headline()
        }
    }
}

// MARK: - SPAvatar

public struct SPAvatar: View {
    private let imageURL: String?
    private let initials: String
    private let size: SPAvatarSize
    private let statusDot: Color?

    public init(
        imageURL: String? = nil,
        initials: String,
        size: SPAvatarSize = .md,
        statusDot: Color? = nil
    ) {
        self.imageURL = imageURL
        self.initials = initials
        self.size = size
        self.statusDot = statusDot
    }

    public var body: some View {
        ZStack(alignment: .bottomTrailing) {
            if let imageURL, let url = URL(string: imageURL) {
                AsyncImage(url: url) { phase in
                    switch phase {
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFill()
                    default:
                        initialsFallback
                    }
                }
                .frame(width: size.dimension, height: size.dimension)
                .clipShape(Circle())
            } else {
                initialsFallback
            }

            if let statusDot {
                Circle()
                    .fill(statusDot)
                    .frame(width: size.dimension * 0.28, height: size.dimension * 0.28)
                    .overlay(
                        Circle()
                            .strokeBorder(.white, lineWidth: 2)
                    )
                    .offset(x: 2, y: 2)
            }
        }
    }

    private var initialsFallback: some View {
        Circle()
            .fill(SpendlyColors.primary.opacity(0.15))
            .frame(width: size.dimension, height: size.dimension)
            .overlay(
                Text(initials.prefix(2).uppercased())
                    .font(size.fontSize)
                    .fontWeight(.semibold)
                    .foregroundStyle(SpendlyColors.primary)
            )
    }
}

// MARK: - Preview

#Preview {
    HStack(spacing: SpendlySpacing.lg) {
        SPAvatar(initials: "KP", size: .sm)
        SPAvatar(initials: "AB", size: .md, statusDot: SpendlyColors.success)
        SPAvatar(initials: "XY", size: .lg, statusDot: SpendlyColors.error)
    }
    .padding()
}
