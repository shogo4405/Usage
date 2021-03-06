import XCTest
import Usage

final class UsageMonitorTest: XCTestCase {
    func testCPU() {
        let stats = NSTemporaryDirectory() + UUID().uuidString + ".stats"
        FileManager.default.createFile(atPath: stats, contents: nil, attributes: nil)
        guard let path = URL(string: stats) else {
            return
        }
        print(stats)
        let monitor: Usage.Monitor? = try? .init(path)
        monitor?.startRunning(1)
        sleep(10)
        monitor?.stopRunning()
    }
}
