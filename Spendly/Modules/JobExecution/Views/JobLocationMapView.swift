import SwiftUI
import MapKit
import SpendlyCore

// MARK: - JobLocationMapView

struct JobLocationMapView: View {

    let jobTitle: String
    let address: String
    let latitude: Double
    let longitude: Double

    @Environment(\.dismiss) private var dismiss
    @Environment(\.colorScheme) private var colorScheme

    private var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Map
                mapContent

                // Bottom info panel
                bottomPanel
            }
            .background(SpendlyColors.background(for: colorScheme))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar { toolbarContent }
        }
    }

    // MARK: - Map Content

    private var mapContent: some View {
        Map(initialPosition: .region(
            MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
        )) {
            Annotation(jobTitle, coordinate: coordinate) {
                ZStack {
                    Circle()
                        .fill(SpendlyColors.primary)
                        .frame(width: 36, height: 36)
                        .shadow(color: SpendlyColors.primary.opacity(0.3), radius: 6, y: 3)

                    Image(systemName: SpendlyIcon.location.systemName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundStyle(.white)
                }
            }
        }
        .mapStyle(.standard(elevation: .realistic, pointsOfInterest: .including([.restaurant, .gasStation, .parking])))
        .mapControls {
            MapCompass()
            MapScaleView()
            MapUserLocationButton()
        }
    }

    // MARK: - Bottom Panel

    private var bottomPanel: some View {
        VStack(spacing: SpendlySpacing.md) {
            // Job title
            HStack {
                VStack(alignment: .leading, spacing: SpendlySpacing.xs) {
                    Text(jobTitle)
                        .font(SpendlyFont.bodySemibold())
                        .foregroundStyle(SpendlyColors.foreground(for: colorScheme))

                    HStack(spacing: SpendlySpacing.sm) {
                        Image(systemName: SpendlyIcon.location.systemName)
                            .font(.system(size: 13))
                            .foregroundStyle(SpendlyColors.secondary)
                        Text(address)
                            .font(SpendlyFont.caption())
                            .foregroundStyle(SpendlyColors.secondaryForeground(for: colorScheme))
                    }
                }

                Spacer()
            }

            // Get Directions button
            Button {
                openInAppleMaps()
            } label: {
                HStack(spacing: SpendlySpacing.sm) {
                    Image(systemName: SpendlyIcon.directions.systemName)
                        .font(.system(size: 15, weight: .semibold))
                    Text("Get Directions")
                        .font(SpendlyFont.bodySemibold())
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, SpendlySpacing.lg)
                .foregroundStyle(.white)
                .background(SpendlyColors.primary)
                .clipShape(RoundedRectangle(cornerRadius: SpendlyRadius.large, style: .continuous))
            }
        }
        .padding(SpendlySpacing.lg)
        .background(SpendlyColors.surface(for: colorScheme))
        .overlay(alignment: .top) {
            Divider().foregroundStyle(SpendlyColors.secondary.opacity(0.2))
        }
    }

    // MARK: - Toolbar

    @ToolbarContentBuilder
    private var toolbarContent: some ToolbarContent {
        ToolbarItem(placement: .principal) {
            Text("Job Location")
                .font(SpendlyFont.headline())
                .foregroundStyle(SpendlyColors.primary)
        }

        ToolbarItem(placement: .topBarLeading) {
            Button {
                dismiss()
            } label: {
                Image(systemName: SpendlyIcon.close.systemName)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(SpendlyColors.secondary)
                    .frame(width: 32, height: 32)
                    .background(SpendlyColors.secondary.opacity(0.1))
                    .clipShape(Circle())
            }
        }
    }

    // MARK: - Apple Maps Navigation

    private func openInAppleMaps() {
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = jobTitle
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}

// MARK: - Preview

#Preview {
    JobLocationMapView(
        jobTitle: "HVAC System Repair - Smith Residence",
        address: "124 Oakwood Circle, River Heights",
        latitude: 40.7282,
        longitude: -73.7949
    )
}
