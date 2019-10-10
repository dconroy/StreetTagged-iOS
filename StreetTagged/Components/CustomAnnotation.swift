import Foundation
import UIKit
import Mapbox

class CustomAnnotation: NSObject, MGLAnnotation {

    var coordinate: CLLocationCoordinate2D
    var title: String?
    var subtitle: String?
    var image: UIImage

    init(coordinate: CLLocationCoordinate2D, title: String, subtitle: String, image: UIImage) {
        self.coordinate = coordinate
        self.title = title
        self.subtitle = subtitle
        self.image = image
    }
}
