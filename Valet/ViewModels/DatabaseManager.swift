import Foundation
import GRDB
import SwiftCloudDrive

class DatabaseManager: ObservableObject {
	@Published var dbQueue: DatabaseQueue
	@Published var licenses: [License] = []

	// initialize db connection
	init() {
		do {
			self.dbQueue = try connectToDb()!
		} catch {
			fatalError("Failed to connect to the database: \(error)")
		}
	}

	// fetch current license data
	func fetchData() {
		do {
			try dbQueue.read { db in
				self.licenses = try License.fetchAll(db)
			}
		} catch {
			logger.error("ERROR: \(error)")
		}
	}
}