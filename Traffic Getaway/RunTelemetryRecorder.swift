import CoreGraphics
import Foundation

struct RunTelemetryEvent: Codable {
    struct TrafficSpawn: Codable {
        let lane: Int
        let type: String
        let yOffset: Double
        let speedMultiplier: Double
    }

    struct RectValue: Codable {
        let x: Double
        let y: Double
        let width: Double
        let height: Double

        init(_ rect: CGRect) {
            x = Double(rect.origin.x)
            y = Double(rect.origin.y)
            width = Double(rect.size.width)
            height = Double(rect.size.height)
        }
    }

    let event: String
    let build: String
    let tuningVersion: String
    let seed: UInt64
    let mode: String
    let levelID: String
    let vehicleID: String
    let vehicleClass: String
    let time: Double
    let playerLane: Int
    let playerSlot: Int
    let score: Int
    let cash: Int
    let distance: Int
    let nearMisses: Int
    let laneSplits: Int
    let combo: Int
    let wantedLevel: Int
    let policeGap: Double
    let exitPhase: String
    let exitSide: String?
    let exitCountdown: Double
    let patternID: String?
    let occupiedLanes: [Int]?
    let openLanes: [Int]?
    let safeCarSlots: [Int]?
    let safeMotorcycleSlots: [Int]?
    let rejectionReason: String?
    let spawns: [TrafficSpawn]?
    let collisionPlayerRect: RectValue?
    let collisionTrafficRect: RectValue?
    let collisionVehicleID: Int?
    let collisionVehicleType: String?
    let terminalReason: String?
    let levelCompleted: Bool?
}

final class RunTelemetryRecorder {
    static let shared = RunTelemetryRecorder()

    private var fileHandle: FileHandle?
    private(set) var currentFileURL: URL?
    private let encoder = JSONEncoder()

    private init() {
        encoder.outputFormatting = [.sortedKeys]
    }

    var isEnabled: Bool {
        AppConfig.debugMode && AppConfig.liveRunTelemetryEnabled
    }

    func startRun(seed: UInt64, levelID: String, vehicleID: String) {
        guard isEnabled else { return }
        close()

        do {
            let directory = try telemetryDirectory()
            let timestamp = Self.timestampFormatter.string(from: Date())
            let safeLevel = levelID.replacingOccurrences(of: "/", with: "-")
            let safeVehicle = vehicleID.replacingOccurrences(of: "/", with: "-")
            let fileName = "\(timestamp)-\(safeLevel)-\(safeVehicle)-\(seed).jsonl"
            let url = directory.appendingPathComponent(fileName)
            FileManager.default.createFile(atPath: url.path, contents: nil)
            fileHandle = try FileHandle(forWritingTo: url)
            currentFileURL = url
            print("[RunTelemetry] writing \(url.path)")
        } catch {
            print("[RunTelemetry] failed to start: \(error)")
            close()
        }
    }

    func record(_ event: RunTelemetryEvent) {
        guard isEnabled, let fileHandle else { return }

        do {
            let data = try encoder.encode(event)
            fileHandle.write(data)
            fileHandle.write(Data([0x0A]))
        } catch {
            print("[RunTelemetry] failed to write \(event.event): \(error)")
        }
    }

    func close() {
        try? fileHandle?.close()
        fileHandle = nil
        currentFileURL = nil
    }

    private func telemetryDirectory() throws -> URL {
        let root = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let directory = root.appendingPathComponent("RunTelemetry", isDirectory: true)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
        return directory
    }

    private static let timestampFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd_HH-mm-ss"
        return formatter
    }()
}
