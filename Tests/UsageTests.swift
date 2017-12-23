import XCTest

final class UsageTest: XCTestCase {
    func testCPU() {
        let _ = Usage.cpu()
        sleep(1)
        let info = Usage.cpu()
        print(info?.nice)
        print(info?.system)
        print(info?.idle)
        print(info?.user)
    }

    func testMemory() {
        print(Usage.memory(unit: .MiB))
    }
}
