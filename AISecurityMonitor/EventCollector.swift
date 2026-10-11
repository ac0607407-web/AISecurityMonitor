import Foundation
import Combine
import os

final class EventCollector: ObservableObject {
    @Published private(set) var storedCount = 0//你連續按三次成功讀檔
    var events: [SecurityEvent] {
        store.events
    }
    private let store = EventStore()//把事件存進 EventStore
    private var counter: Int
    private let logger = Logger(
        subsystem: Bundle.main.bundleIdentifier ?? "TestApp",
        category: "event"
    )

    init() {
        counter = store.lastSequence
        storedCount = store.events.count
    }

    func readFile(named fileName: String, target: String) {
        let result: String
        do {
            _ = try TestFileService.read(named: fileName)
            result = "allowed"
        } catch {
            result = "failed"
            logger.error("read failed: \(error.localizedDescription, privacy: .public)")
        }

        counter += 1
        let event = SecurityEvent(
            eventID: String(format: "E%03d", counter),
            timestamp: SecurityEvent.nowTimestamp(),
            source: "TestApp",
            action: "read",
            target: target,
            result: result,
            isSimulated: true
        )

        store.append(event)
        storedCount = store.events.count

        let json = event.jsonString()
        print(json)
        logger.info("\(json, privacy: .public)")
    }

    func printStoredEvents() {
        func refreshEvents() {
            storedCount = store.events.count
        }
        print("=== Stored events (\(store.events.count)) ===")
        print(store.jsonString())
    }

    func clearEvents() {
        store.clear()
        storedCount = 0
        print("=== Stored events cleared ===")
    }
}
//叫系統做一個操作 → 看結果成功還是失敗 → 把這次操作整理成 SecurityEvent → 轉成 JSON → 留下 Log
//目前 EventStore 最多保存 50 筆，但 EventCollector 的 counter 會繼續累加，這是合理的
