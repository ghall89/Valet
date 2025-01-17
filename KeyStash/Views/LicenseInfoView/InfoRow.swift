import SwiftUI

struct InfoRow: View {
	@EnvironmentObject var appState: AppState
	
	var label: String
	var value: String
	
	init(_ label: String, value: String) {
		self.label = label
		self.value = value
	}
	
	var body: some View {
		HStack(alignment: .top) {
			if !value.isEmpty {
				InfoButton(
					label: label,
					value: value,
					onClick: {
						copyAction(value)
					}
				)
				.contextMenu {
					Button("Copy \"\(value)\"") {
						copyAction(value)
					}
				}
				Spacer()
			}
		}
	}
	
	private func copyAction(_ value: String) {
		stringToClipboard(value: value)
	}
}
