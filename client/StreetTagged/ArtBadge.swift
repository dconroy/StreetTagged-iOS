/*
See LICENSE folder for this sample’s licensing information.

Abstract:
A view that shows a badge.
*/

import SwiftUI

struct ArtBadge: View {
    var name: String
    var body: some View {
        VStack(alignment: .center) {
            Badge()
                .frame(width: 300, height: 300)
                .scaleEffect(1.0 / 3.0)
                .frame(width: 100, height: 100)
            Text(name)
                .font(.caption)
                .accessibility(label: Text("Badge for \(name)."))
        }
    }
}

#if DEBUG
struct ArtBadge_Previews: PreviewProvider {
    static var previews: some View {
        ArtBadge(name: "Preview Testing")
    }
}
#endif
