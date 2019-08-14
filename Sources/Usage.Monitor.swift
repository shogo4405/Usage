import Foundation

extension Usage {
    public class Monitor {
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
            while running {
                let startTime = mach_absolute_time()
                exectute()
                let diff = (mach_absolute_time() - startTime)
                Thread.sleep(forTimeInterval: 1 / hz)
            }
        }

        func exectute() {
            guard let cpu = Usage.cpu(), let memory = Usage.memory() else {
                return
            }
            let timestamp = Date().timeIntervalSince1970
            let line = "\(timestamp),\(cpu.user),\(cpu.system),\(cpu.nice),\(cpu.idle),\(memory)\n"
            if let line = line.data(using: .utf8) {
                fileHandler.write(line)
            }
        }
    }
}
