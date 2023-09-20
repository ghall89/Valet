import SwiftUI
import SwiftData

struct ContentView: View {
	@Environment(\.modelContext) private var modelContext
	@EnvironmentObject var viewModes: ViewModes
	@Query private var items: [License]
	
	var body: some View {
		NavigationSplitView {
			Sidebar()
				.navigationSplitViewColumnWidth(min: 160, ideal: 190)
		} content: {
			LicenseList()
				.navigationSplitViewColumnWidth(min: 340, ideal: 350)
		} detail: {
			VStack(spacing: 10) {
				Image(systemName: "app.dashed")
					.font(.system(size: 80, weight: .thin))
					.foregroundStyle(.secondary)
				Text("Select an item")
					.font(.title)
					.foregroundStyle(.secondary)
			}
			.navigationSplitViewColumnWidth(min: 400, ideal: 700)
			.toolbar {
				ToolbarItem(content: {
					Spacer()
				})
			}
		}
		.sheet(isPresented: $viewModes.showNewAppSheet, content: {
			AddLicense()
		})
	}
}


