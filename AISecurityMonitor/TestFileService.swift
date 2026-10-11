import Foundation

enum TestFileService {//專門處理測試檔案工具箱
    static let defaultFileName = "test_private_file.txt"

    
    static var directory: URL {//找到這個 App 自己的 Application Support 資料夾
        FileManager.default.urls(for: .applicationSupportDirectory,
                                 in: .userDomainMask)[0]
    }

    static func fileURL(named name: String) -> URL {
        directory.appendingPathComponent(name)
    }

    // 準備測試檔案
    static func prepare() {
        try? FileManager.default.createDirectory(at: directory,
                                                 withIntermediateDirectories: true)//如果 Application Support 資料夾不存在，就建立它
        let url = fileURL(named: defaultFileName)
        if !FileManager.default.fileExists(atPath: url.path) {
            try? "secret test content".write(to: url, atomically: true, encoding: .utf8)
        }
    }

    // 讀檔：成功回傳內容，失敗丟出錯誤
    static func read(named name: String) throws -> String {
        try String(contentsOf: fileURL(named: name), encoding: .utf8)
    }
}
//按鈕->TestFileService.read()->真的讀SandBox檔案->成功或失敗