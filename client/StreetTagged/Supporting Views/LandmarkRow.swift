/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A single row to be displayed in a list of landmarks.
*/

import SwiftUI

struct LandmarkRow: View {
    var landmark: Landmark

    var body: some View {
        HStack {
            landmark.image(forSize: 50)
            Text(verbatim: landmark.name)
            Spacer()

            if landmark.isFavorite {
                Image(systemName: "star.circle")
                    .imageScale(.medium)
                    .foregroundColor(.yellow)
            }
        }
    }
}

#if DEBUG
struct LandmarkRow_Previews: PreviewProvider {
    static var previews: some View {
       
            LandmarkRow(landmark: landmarkData[0])
            .previewDevice(PreviewDevice(rawValue: "iPhone X"))
         .environmentObject(UserData())
    }
  
}
#endif


