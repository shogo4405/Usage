import Foundation

public struct MachThreadBasicInfo {
    public let userTime:time_value_t
    public let systemTIme:time_value_t
    public let cpuUsage:Int32
    public let policy:Int32
    public let runState:Int32
    public let flags:Int32
    public let suspendCount:Int32
    public let sleepCount:Int32
}

