
import SwiftUI

struct ContentView: View {
    @StateObject private var collector = EventCollector()
    @State private var events: [SecurityEvent] = []
    
    var body: some View {
        NavigationStack {
            VStack(spacing: 15) {
                Image(systemName: "shield.checkered")
                    .font(.system(size: 50))
                    .foregroundStyle(.blue)
                
                Text("AI 資安事件監控系統")
                    .font(.title2)
                    .bold()
                
                Text("A、B 模組整合測試")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                
                Button {
                    collector.clearEvents()
                    events.removeAll()
                } label: {
                    Label("清除所有事件", systemImage: "trash")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .tint(.red)
                .padding(.horizontal)
                
                Button {
                    collector.readFile(
                        named: TestFileService.defaultFileName,
                        target: TestFileService.defaultFileName
                    )
                    events = Array(collector.events.reversed())
                } label: {
                    Label("產生測試事件", systemImage: "plus.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .padding(.horizontal)
                Button {
                    collector.readFile(
                        named: "missing_file",
                        target: "missing_file"
                    )
                    events = Array(collector.events.reversed())
                } label: {
                    Label("讀取不存在的檔案", systemImage: "xmark.circle")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)
                Button {
                    collector.printStoredEvents()
                } label: {
                    Label("輸出所有事件 JSON", systemImage: "doc.text")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.bordered)
                .padding(.horizontal)
                Text("事件紀錄：\(events.count) 筆")
                    .font(.headline)
                
                List {
                    ForEach(events, id: \.eventID) { event in
                        NavigationLink {
                            EventDetailView(event: event)
                        } label: {
                            VStack(alignment: .leading, spacing: 6) {
                                Text(event.action.uppercased())
                                    .font(.headline)
                                
                                Text("來源：\(event.source)")
                                
                                Text("目標：\(event.target)")
                                
                                Text("時間：\(event.timestamp)")
                                    .font(.caption)
                                    .foregroundStyle(.secondary)
                                
                                Text(event.isSimulated ? "模擬事件" : "非模擬事件")
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                            }
                            .padding(.vertical, 5)
                        }
                    }
                }
            }
            .navigationTitle("Security Monitor")
        }
        .onAppear {
            TestFileService.prepare()
            events = Array(collector.events.reversed())
        }
    }
   
}

struct EventDetailView: View {
    let event: SecurityEvent

    var body: some View {
        Form {
            Section("事件基本資訊") {
                LabeledContent("事件 ID", value: event.eventID)
                LabeledContent("時間", value: event.timestamp)
                LabeledContent("來源", value: event.source)
            }

            Section("事件內容") {
                LabeledContent("動作", value: event.action)
                LabeledContent("目標", value: event.target)
                LabeledContent("結果", value: event.result)
            }

            Section("測試資訊") {
                Text(event.isSimulated ? "模擬事件" : "非模擬事件")
            }

            Section("AI 分析") {
                Text("尚未連接 C 組員的 AI 分析模組")
                    .foregroundStyle(.secondary)
            }
        }
        .navigationTitle("事件詳細資訊")
    }
}

#Preview {
    ContentView()
}

