import Foundation
import CoreLocation

@Observable
public class LocationManager: NSObject, CLLocationManagerDelegate {
    public var currentLocation: CLLocation?
    public var lastKnownLatitude: Double?
    public var lastKnownLongitude: Double?
    public var authorizationStatus: CLAuthorizationStatus = .notDetermined
    public var locationError: String?
    public var isUpdatingLocation: Bool = false

    private let manager = CLLocationManager()

    public override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 10 // Update every 10 meters
    }

    /// Requests location permission from the user.
    public func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    /// Starts continuous location updates.
    public func startUpdating() {
        isUpdatingLocation = true
        locationError = nil
        manager.startUpdatingLocation()
    }

    /// Stops location updates.
    public func stopUpdating() {
        isUpdatingLocation = false
        manager.stopUpdatingLocation()
    }

    /// Requests a single location update.
    public func requestCurrentLocation() {
        locationError = nil
        manager.requestLocation()
    }

    // MARK: - CLLocationManagerDelegate

    public func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        lastKnownLatitude = location.coordinate.latitude
        lastKnownLongitude = location.coordinate.longitude
        locationError = nil
    }

    public func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        locationError = error.localizedDescription
    }

    public func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }
}
