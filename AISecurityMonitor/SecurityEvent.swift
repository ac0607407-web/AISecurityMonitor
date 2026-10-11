
import Foundation

struct SecurityEvent: Codable {
    let eventID: String
    let timestamp: String
    let source: String
    let action: String
    let target: String
    let result: String
    let isSimulated: Bool

    enum CodingKeys: String, CodingKey {
        case eventID = "event_id"
        case timestamp, source, action, target, result
        case isSimulated = "is_simulated"
    }

    static func nowTimestamp() -> String {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.formatOptions = [.withInternetDateTime]
        return formatter.string(from: Date())
    }

    func jsonString() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [
            .prettyPrinted,
            .sortedKeys,
            .withoutEscapingSlashes
        ]

        guard let data = try? encoder.encode(self),
              let text = String(data: data, encoding: .utf8) else {
            return "{}"
        }

        return text
    }
}

