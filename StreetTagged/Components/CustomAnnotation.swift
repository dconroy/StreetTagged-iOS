import Foundation
import UIKit
import Mapbox

class CustomAnnotation: NSObject, MGLAnnotation {

    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: String?

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, image: String) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
}
