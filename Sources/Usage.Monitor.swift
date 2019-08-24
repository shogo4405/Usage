import Foundation

extension Usage {
    public class Monitor {
        private static let header = "Timestamp,User,System,Idle,Nice,Memory"

        public let url: URL
        public private(set) var running: Bool = false
        private let queue: DispatchQueue = .init(label: "Usage.Monitor.queue")
        private var timeBase: mach_timebase_info = mach_timebase_info()
        private let fileHandler: FileHandle

        public init(_ forWritingTo: URL) throws {
            mach_timebase_info(&timeBase)
            url = forWritingTo
            fileHandler = try .init(forWritingTo: forWritingTo)
        }

        public func startRunning(_ hz: Double) {
            guard !self.running else {
                return
            }
            running = true
            queue.async {
                self.run(hz)
            }
        }

        public func stopRunning() {
            guard running else {
                return
            }
            running = false
            fileHandler.closeFile()
        }

        func run(_ hz: Double) {
            if let line = Monitor.header.data(using: .utf8) {
                fileHandler.write(line)
            }
            while running {
                let startTime = mach_absolute_time()
                exectute()
                let elapsed = (mach_absolute_time() - startTime) * UInt64(timeBase.numer) / UInt64(timeBase.denom)
                Thread.sleep(forTimeInterval: 1 / hz - Double(elapsed) / 1000000000)
            }
        }

        func exectute() {
            guard let memory = Usage.memory() else {
                return
            }
            let usage = Usage.cpu()
            let timestamp = Date().timeIntervalSince1970
            let line = "\(timestamp),\(usage.user),\(usage.system),\(usage.idle),\(usage.nice),\(memory)\n"
            if let line = line.data(using: .utf8) {
                fileHandler.write(line)
            }
        }
    }
}
