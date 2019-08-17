import XCTest
import Usage

final class UsageTest: XCTestCase {
    func testCPU() {
        _ = Usage.hostCPULoadInfo()
        sleep(1)
        let info = Usage.hostCPULoadInfo()
        print(info.cpu_ticks.0)
        print(info.cpu_ticks.1)
        print(info.cpu_ticks.2)
        print(info.cpu_ticks.3)
    }

    func testMemory() {
        print(Usage.memory(unit: .MiB))
    }
}
