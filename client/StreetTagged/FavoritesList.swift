/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view showing a list of landmarks.
*/

import SwiftUI

struct FavoritesList: View {
    @EnvironmentObject private var userData: UserData
    
    var body: some View {
            List {
                
                ForEach(userData.landmarks) { landmark in
                    if  landmark.isFavorite {
                        NavigationButton(
                        destination: LandmarkDetail(landmark: landmark)) {
                            LandmarkRow(landmark: landmark)
                        }
                    }
                }
            }
            .navigationBarTitle(Text("All Street Art"), displayMode: .large)
            
        
       
    }
}

#if DEBUG
struct FavoritesList_Previews: PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"].identified(by: \.self)) { deviceName in
            FavoritesList()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
        }
        .environmentObject(UserData())
    }
}
#endif
