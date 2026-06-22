import Foundation

public struct SeededRNG {
    private var state: UInt64

    public init(seed: UInt64) {
        state = seed == 0 ? 0x1234ABCD : seed
    }

    public mutating func next() -> UInt64 {
        state = state &* 6364136223846793005 &+ 1442695040888963407
        return state
    }

    public mutating func double(in range: ClosedRange<Double>) -> Double {
        let unit = Double(next() >> 11) / Double(UInt64.max >> 11)
        return range.lowerBound + unit * (range.upperBound - range.lowerBound)
    }

    public mutating func int(in range: ClosedRange<Int>) -> Int {
        guard range.lowerBound < range.upperBound else { return range.lowerBound }
        let width = UInt64(range.upperBound - range.lowerBound + 1)
        return range.lowerBound + Int(next() % width)
    }

    public mutating func chance(_ probability: Double) -> Bool {
        double(in: 0...1) < max(0, min(1, probability))
    }

    public mutating func element<T>(from values: [T]) -> T? {
        guard !values.isEmpty else { return nil }
        return values[int(in: 0...(values.count - 1))]
    }

    public mutating func shuffled<T>(_ values: [T]) -> [T] {
        guard values.count > 1 else { return values }
        var result = values
        for index in stride(from: result.count - 1, through: 1, by: -1) {
            let swapIndex = int(in: 0...index)
            result.swapAt(index, swapIndex)
        }
        return result
    }

    public static func stableSeed(for key: String, runIndex: Int, baseSeed: UInt64 = 0) -> UInt64 {
        var hash: UInt64 = 1469598103934665603
        for byte in key.utf8 {
            hash ^= UInt64(byte)
            hash = hash &* 1099511628211
        }
        return hash &+ baseSeed &+ UInt64(runIndex * 7919 + 17)
    }
}
