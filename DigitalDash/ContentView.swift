import SwiftUI

struct CustomViewRepresentable: NSViewRepresentable {
    func makeNSView(context: Context) -> CustomView {
        return CustomView()
    }

    func updateNSView(_ nsView: CustomView, context: Context) {
        // Update the view if needed
    }
}

struct ContentView: View {
    var body: some View {
        CustomViewRepresentable()
            .frame(minWidth: 240, minHeight: 100) // Increased minWidth by 20%
    }
}

#Preview {
    ContentView()
}
