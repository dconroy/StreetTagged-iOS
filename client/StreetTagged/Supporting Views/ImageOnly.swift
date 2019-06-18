/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view that clips an image to a circle and adds a stroke and shadow.
*/

import SwiftUI

struct ImageOnly: View {
    var image: Image

    var body: some View {
        
      
        image
            .clipShape(Rectangle())
            .overlay(Rectangle().stroke(Color.white, lineWidth: 4))
            .shadow(radius: 10)
        
    }
}

#if DEBUG
struct ImageOnly_Previews: PreviewProvider {
    static var previews: some View {
        ImageOnly(image: Image("turtlerock"))
    }
}
#endif
