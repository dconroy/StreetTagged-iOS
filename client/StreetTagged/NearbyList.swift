//
//  NearbyList.swift
//  Landmarks
//
//  Created by David Conroy on 6/13/19.
//  Copyright © 2019 Apple. All rights reserved.
//

import SwiftUI

struct NearbyList : View {
    @EnvironmentObject private var userData: UserData
    
    var body: some View {
        NavigationView {
            List {
                Toggle(isOn: $userData.showFavoritesOnly) {
                    Text("Show Favorites Only")
                }
                
                ForEach(userData.landmarks) { landmark in
                    if !self.userData.showFavoritesOnly || landmark.isFavorite {
                        NavigationButton(
                        destination: LandmarkDetail(landmark: landmark)) {
                            LandmarkRow(landmark: landmark)
                        }
                    }
                }
                }
                .navigationBarTitle(Text("Landmarks"), displayMode: .large)
        }
        .edgesIgnoringSafeArea(.top)
    }
}
#if DEBUG
struct NearbyList_Previews : PreviewProvider {
    static var previews: some View {
        ForEach(["iPhone SE", "iPhone XS Max"].identified(by: \.self)) { deviceName in
            LandmarkList()
                .previewDevice(PreviewDevice(rawValue: deviceName))
                .previewDisplayName(deviceName)
            }
            .environmentObject(UserData())
    }
}
#endif
