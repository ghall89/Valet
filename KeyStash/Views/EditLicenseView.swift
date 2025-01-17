import SwiftUI

struct EditLicenseView: View {
	@EnvironmentObject var databaseManager: DatabaseManager
	@EnvironmentObject var formState: EditFormState
	@EnvironmentObject var appState: AppState

	@Binding var isPresented: Bool

	var license: License

	@State var selectedPurchaseDate: Date = .init()
	@State var selectedExpDate: Date = .init()
	@State private var showDeleteAlert: Bool = false

	let formatter: NumberFormatter = {
		let formatter = NumberFormatter()
		formatter.numberStyle = .decimal
		return formatter
	}()

	var body: some View {
		Form {
			Section {
				HStack {
					Image(nsImage: ((formState.icon != nil) ? NSImage(data: formState.icon!) : license.iconNSImage)!)
						.resizable()
						.frame(width: 45, height: 45)
					Spacer()
					Button("Change Icon") {
						if let newIcon = getCustomIcon() {
							formState.icon = newIcon
						}
					}
				}
				TextField("Name", text: $formState.softwareName)
				TextField("URL", text: $formState.urlString)
				TextField("Version", text: $formState.version)
			}
			Section {
				TextField("Registered To", text: $formState.registeredToName)
				TextField("Email", text: $formState.registeredToEmail)
				TextField("License Key", text: $formState.licenseKey)
				DatePicker(
					"Purchase Date",
					selection: $selectedPurchaseDate,
					displayedComponents: [.date]
				)
			}
			Section {
				Toggle(isOn: $formState.addExpiration, label: {
					Text("License Expires")
				})
				if formState.addExpiration {
					DatePicker(
						"Expiration Date",
						selection: $selectedExpDate,
						displayedComponents: [.date]
					)
				}
			}
//			Section {
//				if let attachment = license.attachmentPath {
//					HStack {
//						Button("Remove Attachment", systemImage: "xmark.circle.fill") {
//							showDeleteAlert.toggle()
//						}
//						.buttonStyle(.plain)
//						.labelStyle(.iconOnly)
//
//						VStack(alignment: .leading) {
//							Text(attachment.lastPathComponent)
//								.fontDesign(.monospaced)
//						}
//					}
//					.confirmationDialog(
//						"Are you sure you want to remove this attachment? The file will be moved to your computer's Trash.",
//						isPresented: $showDeleteAlert,
//						actions: {
//							Button(action: {
//								showDeleteAlert.toggle()
//							}, label: {
//								Text("Cancel")
//							})
//							.keyboardShortcut(.defaultAction)
//							Button("Delete") {
//								removeAttachment()
//								showDeleteAlert.toggle()
//							}
//						}
//					)
//				} else {
//					Button("Add Attachment", systemImage: "paperclip") {
//						handleAttachment()
//					}
//				}
//			}
			Section("Notes") {
				TextEditor(text: $formState.notes)
			}
		}
		.formStyle(.grouped)
		.frame(width: 400)
		.padding()
		.toolbar {
			ToolbarItem(placement: .cancellationAction) {
				Button("Cancel") {
					isPresented.toggle()
				}
			}
			ToolbarItem(placement: .primaryAction) {
				Button("Save") {
					saveFormState()
					isPresented.toggle()
				}
			}
		}
		.onChange(of: selectedPurchaseDate) {
			formState.purchaseDt = selectedPurchaseDate
		}
		.onChange(of: selectedExpDate) {
			formState.expirationDt = selectedExpDate
		}
		.onAppear {
			if license.expirationDt != nil {
				selectedExpDate = license.expirationDt!
			}
		}
	}

	private func saveFormState() {
		do {
			var updatedLicense = license
			updatedLicense.icon = formState.icon != nil ? formState.icon : license.icon
			updatedLicense.softwareName = formState.softwareName
			updatedLicense.version = formState.version
			updatedLicense.downloadUrlString = formState.urlString
			updatedLicense.registeredToName = formState.registeredToName
			updatedLicense.registeredToEmail = formState.registeredToEmail
			updatedLicense.licenseKey = formState.licenseKey
			updatedLicense.purchaseDt = formState.purchaseDt
			if formState.addExpiration {
				updatedLicense.expirationDt = formState.expirationDt
			} else {
				updatedLicense.expirationDt = nil
			}
			updatedLicense.notes = formState.notes
			try updateLicense(databaseManager.dbQueue, data: updatedLicense)
			databaseManager.fetchData()
		} catch {
			logger.error("ERROR: \(error)")
		}
	}

	private func handleAttachment() {
		if let fileFromDisk = getAttachment() {
			do {
				var updatedLicense = license
				updatedLicense.attachmentPath = fileFromDisk
				try addAttachmentToLicense(databaseManager.dbQueue, data: updatedLicense, attachment: fileFromDisk)
				databaseManager.fetchData()
			} catch {
				logger.error("ERROR: \(error)")
			}
		}
	}

	private func removeAttachment() {
		do {
			try deleteAttachment(databaseManager.dbQueue, license: license)
			databaseManager.fetchData()
		} catch {
			logger.error("ERROR: \(error)")
		}
	}
}
