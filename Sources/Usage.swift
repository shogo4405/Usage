import Foundation

public struct Usage {
    public enum Unit: UInt64 {
        case none = 1
        case KiB = 1024
        case MiB = 1048576
    }

    private static var loadPrevious: HostCPULoadInfo?

    public static func cpu() -> HostCPULoadInfo? {
        let _load: HostCPULoadInfo? = HostCPULoadInfo.current()
        defer {
            loadPrevious = _load
        }
        guard let load: HostCPULoadInfo = _load, let loadPrevious: HostCPULoadInfo = loadPrevious else {
            return nil
        }
        let user: Double = load.user - loadPrevious.user
        let system: Double = load.system - loadPrevious.system
        let idle: Double = load.idle - loadPrevious.idle
        let nice: Double = load.nice - loadPrevious.nice
        let total: Double = user + system + idle + nice
        return HostCPULoadInfo(
            user: user / total * 100.0,
            system: system / total * 100.0,
            idle: idle / total * 100.0,
            nice: nice / total * 100.0
        )
    }

    public static func memory(unit: Unit = .none) -> UInt64? {
        guard let info: MachTaskBasicInfo = MachTaskBasicInfo.current() else {
            return nil
        }
        return info.residentSize / unit.rawValue
    }
}
