import Foundation//引入url,data,JSONEncoder

final class EventStore {//事件倉庫
    private let maxCount: Int//最多保存幾筆
    private let fileURL: URL//事件存在哪個檔
    private(set) var events: [SecurityEvent] = []//目前 EventStore 裡保存的所有 SecurityEvent

    init(maxCount: Int = 50, fileName: String = "events.json") {
        self.maxCount = maxCount
        self.fileURL = TestFileService.directory.appendingPathComponent(fileName)//把 events.json 放到我們之前 TestFileService 使用的 Application Support 資料夾
        print("Event store path:", fileURL.path)//印出事件倉庫的路徑，方便開發者知道在哪裡
        load()//App 啟動的時候，先看看以前有沒有存過事件
    }

    /// 目前已用到的最大編號（E012 -> 12），讓重啟後編號可以接續
    var lastSequence: Int {
        events.compactMap { Int($0.eventID.dropFirst()) }.max() ?? 0
    }

    func append(_ event: SecurityEvent) {//把一筆 SecurityEvent 加進事件庫
        events.append(event)
        if events.count > maxCount {//超過 50 筆怎麼辦
            events.removeFirst(events.count - maxCount)
        }
        save()//把目前記憶體裡的 events 寫進 events.json
    }

    func clear() {//把目前保存的所有事件清掉，之後可能刪掉
        events.removeAll()
        save()
    }

    /// 給 C 使用的輸出：整批事件轉成 JSON 陣列
    func jsonString() -> String {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        guard let data = try? encoder.encode(events),
              let text = String(data: data, encoding: .utf8) else { return "[]" }
        return text
    }

    private func save() {
        do {
            try FileManager.default.createDirectory(
                at: fileURL.deletingLastPathComponent(),
                withIntermediateDirectories: true)
            let data = try JSONEncoder().encode(events)
            try data.write(to: fileURL, options: .atomic)
        } catch {//如果寫檔失敗
            print("EventStore save failed:", error.localizedDescription)
        }
    }

    private func load() {
        guard let data = try? Data(contentsOf: fileURL),
              let decoded = try? JSONDecoder().decode([SecurityEvent].self, from: data)
        else { return }
        events = decoded
    }
}