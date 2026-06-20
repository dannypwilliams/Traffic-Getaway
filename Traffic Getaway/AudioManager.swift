import AVFoundation
import CoreGraphics
import QuartzCore

/// Centralized procedural audio system for music, ambience, sound effects, and dynamic danger feedback.
/// All sounds are generated in code so the project does not require bundled audio assets.
final class AudioManager {
    static let shared = AudioManager()

    enum CityAudioTheme: String {
        case newYork
        case losAngeles
        case miami
    }

    enum SoundEffect: String, CaseIterable {
        case laneChange
        case laneSplit
        case nearMiss
        case comboIncrease
        case dodgeBoost
        case clutchSave
        case wantedIncrease
        case roadblockWarning
        case helicopter
        case powerUp
        case crash
        case gameOver
        case cityTransition
        case menuClick
        case thunder
        case debris
    }

    private enum DefaultsKey {
        static let musicVolume = "TrafficGetaway.musicVolume"
        static let sfxVolume = "TrafficGetaway.sfxVolume"
        static let musicEnabled = "TrafficGetaway.musicEnabled"
        static let sfxEnabled = "TrafficGetaway.sfxEnabled"
        static let hapticsEnabled = "TrafficGetaway.hapticsEnabled"
    }

    private let engine = AVAudioEngine()
    private let musicMixer = AVAudioMixerNode()
    private let ambienceMixer = AVAudioMixerNode()
    private let sfxMixer = AVAudioMixerNode()
    private let format = AVAudioFormat(standardFormatWithSampleRate: 44_100, channels: 2)!

    private var musicPlayers = [AVAudioPlayerNode(), AVAudioPlayerNode()]
    private var ambiencePlayers = [AVAudioPlayerNode(), AVAudioPlayerNode()]
    private let tensionPlayer = AVAudioPlayerNode()
    private let sirenPlayer = AVAudioPlayerNode()
    private var sfxPlayers: [AVAudioPlayerNode] = (0..<10).map { _ in AVAudioPlayerNode() }

    private var activeMusicIndex = 0
    private var activeAmbienceIndex = 0
    private var sfxPlayerIndex = 0
    private var currentTheme: CityAudioTheme?
    private var configured = false
    private var sirenLoopStarted = false
    private var tensionLoopStarted = false

    private var musicBuffers: [CityAudioTheme: AVAudioPCMBuffer] = [:]
    private var ambienceBuffers: [CityAudioTheme: AVAudioPCMBuffer] = [:]
    private var tensionBuffers: [CityAudioTheme: AVAudioPCMBuffer] = [:]
    private var sfxBuffers: [SoundEffect: AVAudioPCMBuffer] = [:]
    private var lastEffectTimes: [SoundEffect: TimeInterval] = [:]
    private var fadeTimers: [ObjectIdentifier: Timer] = [:]

    private(set) var musicVolume: Float
    private(set) var sfxVolume: Float
    private(set) var isMusicEnabled: Bool
    private(set) var isSFXEnabled: Bool
    private(set) var isHapticsEnabled: Bool

    private init() {
        let defaults = UserDefaults.standard
        if defaults.object(forKey: DefaultsKey.musicVolume) == nil {
            defaults.set(0.72, forKey: DefaultsKey.musicVolume)
            defaults.set(0.82, forKey: DefaultsKey.sfxVolume)
            defaults.set(true, forKey: DefaultsKey.musicEnabled)
            defaults.set(true, forKey: DefaultsKey.sfxEnabled)
            defaults.set(true, forKey: DefaultsKey.hapticsEnabled)
        }

        musicVolume = Float(defaults.double(forKey: DefaultsKey.musicVolume))
        sfxVolume = Float(defaults.double(forKey: DefaultsKey.sfxVolume))
        isMusicEnabled = defaults.bool(forKey: DefaultsKey.musicEnabled)
        isSFXEnabled = defaults.bool(forKey: DefaultsKey.sfxEnabled)
        isHapticsEnabled = defaults.bool(forKey: DefaultsKey.hapticsEnabled)
    }

    // MARK: - Setup

    func configure() {
        guard !configured else {
            startEngineIfNeeded()
            return
        }

        configured = true
        configureAudioSession()

        engine.attach(musicMixer)
        engine.attach(ambienceMixer)
        engine.attach(sfxMixer)
        engine.connect(musicMixer, to: engine.mainMixerNode, format: format)
        engine.connect(ambienceMixer, to: engine.mainMixerNode, format: format)
        engine.connect(sfxMixer, to: engine.mainMixerNode, format: format)

        for player in musicPlayers {
            engine.attach(player)
            engine.connect(player, to: musicMixer, format: format)
        }

        for player in ambiencePlayers {
            engine.attach(player)
            engine.connect(player, to: ambienceMixer, format: format)
        }

        engine.attach(tensionPlayer)
        engine.attach(sirenPlayer)
        engine.connect(tensionPlayer, to: musicMixer, format: format)
        engine.connect(sirenPlayer, to: sfxMixer, format: format)

        for player in sfxPlayers {
            engine.attach(player)
            engine.connect(player, to: sfxMixer, format: format)
        }

        buildReusableBuffers()
        applyCurrentVolumes()
        startEngineIfNeeded()
        startSirenLoopIfNeeded()
    }

    private func configureAudioSession() {
        #if os(iOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.ambient, mode: .default, options: [.mixWithOthers])
        try? session.setActive(true)
        #endif
    }

    private func startEngineIfNeeded() {
        guard !engine.isRunning else { return }
        try? engine.start()
    }

    private func buildReusableBuffers() {
        CityAudioTheme.allCasesForAudio.forEach { theme in
            musicBuffers[theme] = makeMusicBuffer(for: theme)
            ambienceBuffers[theme] = makeAmbienceBuffer(for: theme)
            tensionBuffers[theme] = makeTensionBuffer(for: theme)
        }

        SoundEffect.allCases.forEach { effect in
            sfxBuffers[effect] = makeEffectBuffer(effect)
        }
    }

    // MARK: - Settings

    func setMusicVolume(_ value: Float) {
        musicVolume = clamp(value, min: 0, max: 1)
        UserDefaults.standard.set(Double(musicVolume), forKey: DefaultsKey.musicVolume)
        applyCurrentVolumes()
    }

    func setSFXVolume(_ value: Float) {
        sfxVolume = clamp(value, min: 0, max: 1)
        UserDefaults.standard.set(Double(sfxVolume), forKey: DefaultsKey.sfxVolume)
        applyCurrentVolumes()
    }

    func setMusicEnabled(_ enabled: Bool) {
        isMusicEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: DefaultsKey.musicEnabled)
        applyCurrentVolumes()
    }

    func setSFXEnabled(_ enabled: Bool) {
        isSFXEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: DefaultsKey.sfxEnabled)
        applyCurrentVolumes()
    }

    func setHapticsEnabled(_ enabled: Bool) {
        isHapticsEnabled = enabled
        UserDefaults.standard.set(enabled, forKey: DefaultsKey.hapticsEnabled)
    }

    func toggleMusic() {
        setMusicEnabled(!isMusicEnabled)
    }

    func toggleSFX() {
        setSFXEnabled(!isSFXEnabled)
    }

    func toggleHaptics() {
        setHapticsEnabled(!isHapticsEnabled)
    }

    private func applyCurrentVolumes() {
        musicMixer.outputVolume = isMusicEnabled ? 1 : 0
        ambienceMixer.outputVolume = isMusicEnabled ? 0.26 : 0
        sfxMixer.outputVolume = isSFXEnabled ? 1 : 0

        let targetMusic = isMusicEnabled ? musicVolume : 0
        musicPlayers[activeMusicIndex].volume = targetMusic
        ambiencePlayers[activeAmbienceIndex].volume = isMusicEnabled ? musicVolume * 0.34 : 0
        tensionPlayer.volume = min(tensionPlayer.volume, targetMusic * 0.5)
        sirenPlayer.volume = isSFXEnabled ? sirenPlayer.volume : 0
    }

    // MARK: - Music and Ambience

    func updateTheme(_ theme: CityAudioTheme, crossfadeDuration: TimeInterval = 2.0) {
        configure()
        startEngineIfNeeded()

        let duration = currentTheme == nil ? 0.0 : crossfadeDuration
        transitionMusic(to: theme, duration: duration)
        transitionAmbience(to: theme, duration: duration)
        transitionTensionLoop(to: theme)
        currentTheme = theme
    }

    private func transitionMusic(to theme: CityAudioTheme, duration: TimeInterval) {
        guard currentTheme != theme || !musicPlayers[activeMusicIndex].isPlaying else { return }
        guard let buffer = musicBuffers[theme] else { return }

        let oldPlayer = musicPlayers[activeMusicIndex]
        let newIndex = 1 - activeMusicIndex
        let newPlayer = musicPlayers[newIndex]

        newPlayer.stop()
        newPlayer.volume = 0
        newPlayer.scheduleBuffer(buffer, at: nil, options: .loops)
        newPlayer.play()

        let target = isMusicEnabled ? musicVolume : 0
        if duration <= 0 {
            oldPlayer.stop()
            newPlayer.volume = target
        } else {
            fade(newPlayer, to: target, duration: duration)
            fade(oldPlayer, to: 0, duration: duration, stopWhenFinished: true)
        }

        activeMusicIndex = newIndex
    }

    private func transitionAmbience(to theme: CityAudioTheme, duration: TimeInterval) {
        guard let buffer = ambienceBuffers[theme] else { return }

        let oldPlayer = ambiencePlayers[activeAmbienceIndex]
        let newIndex = 1 - activeAmbienceIndex
        let newPlayer = ambiencePlayers[newIndex]

        newPlayer.stop()
        newPlayer.volume = 0
        newPlayer.scheduleBuffer(buffer, at: nil, options: .loops)
        newPlayer.play()

        let target = isMusicEnabled ? musicVolume * 0.34 : 0
        if duration <= 0 {
            oldPlayer.stop()
            newPlayer.volume = target
        } else {
            fade(newPlayer, to: target, duration: duration)
            fade(oldPlayer, to: 0, duration: duration, stopWhenFinished: true)
        }

        activeAmbienceIndex = newIndex
    }

    private func transitionTensionLoop(to theme: CityAudioTheme) {
        guard let buffer = tensionBuffers[theme] else { return }
        tensionPlayer.stop()
        tensionPlayer.volume = 0
        tensionPlayer.scheduleBuffer(buffer, at: nil, options: .loops)
        tensionPlayer.play()
        tensionLoopStarted = true
    }

    // MARK: - Dynamic Pressure

    func setPoliceIntensity(_ intensity: CGFloat) {
        configure()
        let clamped = Float(clamp(Double(intensity), min: 0, max: 1))
        let target = isSFXEnabled ? sfxVolume * (clamped * 0.28) : 0
        sirenPlayer.volume += (target - sirenPlayer.volume) * 0.12
    }

    func setDangerIntensity(_ intensity: CGFloat) {
        configure()
        let clamped = Float(clamp(Double(intensity), min: 0, max: 1))
        let target = isMusicEnabled ? musicVolume * clamped * 0.42 : 0
        tensionPlayer.volume += (target - tensionPlayer.volume) * 0.10

        let mainTarget = isMusicEnabled ? musicVolume * (0.92 + clamped * 0.12) : 0
        musicPlayers[activeMusicIndex].volume += (mainTarget - musicPlayers[activeMusicIndex].volume) * 0.04
    }

    func quietDangerLayers() {
        setPoliceIntensity(0)
        setDangerIntensity(0)
    }

    private func startSirenLoopIfNeeded() {
        guard !sirenLoopStarted else { return }
        sirenLoopStarted = true
        sirenPlayer.volume = 0
        sirenPlayer.scheduleBuffer(makeSirenBuffer(), at: nil, options: .loops)
        sirenPlayer.play()
    }

    // MARK: - Sound Effects

    func play(_ effect: SoundEffect, volume: Float = 1.0, cooldown: TimeInterval = 0.0) {
        configure()
        guard isSFXEnabled, let buffer = sfxBuffers[effect] else { return }

        let now = CACurrentMediaTime()
        if let lastTime = lastEffectTimes[effect], now - lastTime < cooldown {
            return
        }

        lastEffectTimes[effect] = now
        let player = sfxPlayers[sfxPlayerIndex]
        sfxPlayerIndex = (sfxPlayerIndex + 1) % sfxPlayers.count

        player.stop()
        player.volume = clamp(volume, min: 0, max: 1) * sfxVolume
        player.scheduleBuffer(buffer, at: nil)
        player.play()
    }

    // MARK: - Fade Helpers

    private func fade(_ player: AVAudioPlayerNode, to target: Float, duration: TimeInterval, stopWhenFinished: Bool = false) {
        let identifier = ObjectIdentifier(player)
        fadeTimers[identifier]?.invalidate()

        guard duration > 0 else {
            player.volume = target
            if stopWhenFinished {
                player.stop()
            }
            return
        }

        let startVolume = player.volume
        let steps = max(1, Int(duration / 0.05))
        var step = 0

        let timer = Timer.scheduledTimer(withTimeInterval: duration / Double(steps), repeats: true) { [weak self, weak player] timer in
            guard let self, let player else {
                timer.invalidate()
                return
            }

            step += 1
            let progress = Float(step) / Float(steps)
            player.volume = startVolume + (target - startVolume) * progress

            if step >= steps {
                player.volume = target
                if stopWhenFinished {
                    player.stop()
                }
                timer.invalidate()
                self.fadeTimers[identifier] = nil
            }
        }

        fadeTimers[identifier] = timer
    }

    // MARK: - Procedural Buffer Generation

    private func makeMusicBuffer(for theme: CityAudioTheme) -> AVAudioPCMBuffer {
        switch theme {
        case .newYork:
            return makeBuffer(duration: 8) { t in
                let beat = 60.0 / 92.0
                let kick = pulse(t, every: beat, width: 0.055) * sin(2 * .pi * 54 * t)
                let snare = pulse(t + beat, every: beat * 2, width: 0.07) * noise(t * 7.0) * 0.42
                let hat = pulse(t, every: beat / 2, width: 0.018) * noise(t * 16.0) * 0.16
                let bass = sin(2 * .pi * (46 + 8 * stepValue(t, beat: beat, values: [0, 3, 5, 2])) * t) * 0.14
                let grit = sin(2 * .pi * 184 * t) * 0.035
                return kick * 0.45 + snare + hat + bass + grit
            }
        case .losAngeles:
            return makeBuffer(duration: 8) { t in
                let beat = 60.0 / 104.0
                let kick = pulse(t, every: beat, width: 0.045) * sin(2 * .pi * 50 * t) * 0.38
                let clap = pulse(t + beat, every: beat * 2, width: 0.055) * noise(t * 4.0) * 0.28
                let bassNote = 52 + 5 * stepValue(t + 0.1, beat: beat, values: [0, 0, 7, 5, 3, 5, 7, 5])
                let bass = sin(2 * .pi * bassNote * t) * 0.18
                let keys = sin(2 * .pi * 220 * t) * sin(2 * .pi * 0.55 * t) * 0.055
                let shimmer = sin(2 * .pi * 440 * t) * pulse(t + beat / 4, every: beat, width: 0.04) * 0.08
                return kick + clap + bass + keys + shimmer
            }
        case .miami:
            return makeBuffer(duration: 8) { t in
                let beat = 60.0 / 124.0
                let kick = pulse(t, every: beat, width: 0.04) * sin(2 * .pi * 58 * t) * 0.42
                let snare = pulse(t + beat, every: beat * 2, width: 0.045) * noise(t * 5.0) * 0.22
                let arpValue = stepValue(t, beat: beat / 2, values: [0, 7, 12, 19, 12, 7, 5, 12])
                let arp = saw(220 * pow(2, arpValue / 12), t) * pulse(t, every: beat / 2, width: 0.09) * 0.12
                let bass = saw(48 + 5 * stepValue(t, beat: beat, values: [0, 0, 5, 7]), t) * 0.12
                return kick + snare + arp + bass
            }
        }
    }

    private func makeAmbienceBuffer(for theme: CityAudioTheme) -> AVAudioPCMBuffer {
        switch theme {
        case .newYork:
            return makeBuffer(duration: 10) { t in
                let cityBed = noise(t * 0.8) * 0.045 + sin(2 * .pi * 63 * t) * 0.02
                let distantSiren = sin(2 * .pi * (550 + sin(t * 1.8) * 90) * t) * 0.025
                let horn = pulse(t + 2.4, every: 9.5, width: 0.22) * sin(2 * .pi * 310 * t) * 0.12
                return cityBed + distantSiren + horn
            }
        case .losAngeles:
            return makeBuffer(duration: 10) { t in
                let freeway = noise(t * 0.55) * 0.05 + sin(2 * .pi * 74 * t) * 0.018
                let helicopter = sin(2 * .pi * 19 * t) * pulse(t + 1.0, every: 3.0, width: 1.6) * 0.035
                let warmHum = sin(2 * .pi * 118 * t) * 0.018
                return freeway + helicopter + warmHum
            }
        case .miami:
            return makeBuffer(duration: 10) { t in
                let ocean = sin(2 * .pi * 0.23 * t) * 0.035 + noise(t * 0.35) * 0.035
                let clubPulse = pulse(t, every: 0.72, width: 0.08) * sin(2 * .pi * 86 * t) * 0.055
                let neonBuzz = sin(2 * .pi * 240 * t) * 0.015
                return ocean + clubPulse + neonBuzz
            }
        }
    }

    private func makeTensionBuffer(for theme: CityAudioTheme) -> AVAudioPCMBuffer {
        switch theme {
        case .newYork:
            return makeBuffer(duration: 4) { t in
                pulse(t, every: 0.18, width: 0.018) * noise(t * 18) * 0.18 +
                sin(2 * .pi * 92 * t) * 0.04
            }
        case .losAngeles:
            return makeBuffer(duration: 4) { t in
                pulse(t, every: 0.22, width: 0.02) * noise(t * 16) * 0.12 +
                sin(2 * .pi * (120 + sin(t * 2) * 18) * t) * 0.035
            }
        case .miami:
            return makeBuffer(duration: 4) { t in
                pulse(t, every: 0.12, width: 0.015) * saw(410, t) * 0.12 +
                sin(2 * .pi * 132 * t) * 0.04
            }
        }
    }

    private func makeEffectBuffer(_ effect: SoundEffect) -> AVAudioPCMBuffer {
        switch effect {
        case .laneChange:
            return makeBuffer(duration: 0.16) { t in
                let envelope = 1 - t / 0.16
                return sin(2 * .pi * (420 + 280 * t) * t) * envelope * 0.36
            }
        case .laneSplit:
            return makeBuffer(duration: 0.22) { t in
                let envelope = min(1, t / 0.025) * exp(-t * 6.8)
                let bright = sin(2 * .pi * (1_100 - 360 * t) * t) * 0.24
                let air = noise(t * 42) * 0.2
                return (bright + air) * envelope
            }
        case .nearMiss:
            return makeBuffer(duration: 0.34) { t in
                let envelope = 1 - t / 0.34
                let sweep = sin(2 * .pi * (820 - 520 * t) * t)
                return (sweep * 0.22 + noise(t * 25) * 0.18) * envelope
            }
        case .comboIncrease:
            return makeBuffer(duration: 0.22) { t in
                let envelope = 1 - t / 0.22
                return (sin(2 * .pi * 540 * t) + sin(2 * .pi * 810 * t) * 0.6) * envelope * 0.24
            }
        case .dodgeBoost:
            return makeBuffer(duration: 0.28) { t in
                let envelope = min(1, t / 0.04) * exp(-t * 5.2)
                let sweep = sin(2 * .pi * (360 + 1_100 * t) * t)
                let air = noise(t * 34) * 0.16
                return (sweep * 0.3 + air) * envelope
            }
        case .clutchSave:
            return makeBuffer(duration: 0.5) { t in
                let envelope = min(1, t / 0.05) * exp(-t * 3.2)
                let first = sin(2 * .pi * 520 * t)
                let second = sin(2 * .pi * (760 + 220 * t) * t) * 0.7
                let snap = pulse(t, every: 0.09, width: 0.018) * noise(t * 28) * 0.25
                return (first * 0.22 + second * 0.18 + snap) * envelope
            }
        case .wantedIncrease:
            return makeBuffer(duration: 0.76) { t in
                let envelope = min(1, t / 0.06) * exp(-t * 1.7)
                let radio = noise(t * 18) * pulse(t, every: 0.08, width: 0.045) * 0.18
                let alert = sin(2 * .pi * (420 + sin(t * 20) * 52) * t) * 0.26
                let low = sin(2 * .pi * 96 * t) * 0.18
                return (radio + alert + low) * envelope
            }
        case .roadblockWarning:
            return makeBuffer(duration: 0.48) { t in
                let beep = pulse(t, every: 0.16, width: 0.055)
                let tone = sin(2 * .pi * 920 * t) + sin(2 * .pi * 460 * t) * 0.35
                return tone * beep * exp(-t * 1.1) * 0.32
            }
        case .helicopter:
            return makeBuffer(duration: 0.5) { t in
                let chop = pulse(t, every: 0.065, width: 0.024)
                let rotor = sin(2 * .pi * 34 * t) * 0.24 + noise(t * 11) * 0.18
                return rotor * (0.28 + chop * 0.72) * exp(-t * 0.35)
            }
        case .powerUp:
            return makeBuffer(duration: 0.42) { t in
                let envelope = min(1, t / 0.08) * (1 - t / 0.42)
                return sin(2 * .pi * (420 + 820 * t) * t) * envelope * 0.32
            }
        case .crash:
            return makeBuffer(duration: 0.62) { t in
                let envelope = exp(-t * 5.4)
                let low = sin(2 * .pi * (82 - 36 * t) * t) * 0.55
                return (noise(t * 40) * 0.75 + low) * envelope * 0.55
            }
        case .gameOver:
            return makeBuffer(duration: 1.2) { t in
                let envelope = exp(-t * 1.6)
                let tone = sin(2 * .pi * (260 - 115 * t) * t)
                let lower = sin(2 * .pi * (130 - 55 * t) * t) * 0.6
                return (tone + lower) * envelope * 0.26
            }
        case .cityTransition:
            return makeBuffer(duration: 0.72) { t in
                let envelope = min(1, t / 0.1) * exp(-t * 1.25)
                let rise = sin(2 * .pi * (260 + 640 * t) * t)
                let sparkle = pulse(t, every: 0.09, width: 0.02) * sin(2 * .pi * 980 * t)
                return (rise * 0.28 + sparkle * 0.16) * envelope
            }
        case .menuClick:
            return makeBuffer(duration: 0.08) { t in
                (sin(2 * .pi * 620 * t) + sin(2 * .pi * 1_050 * t) * 0.35) * exp(-t * 34) * 0.28
            }
        case .thunder:
            return makeBuffer(duration: 1.4) { t in
                let roll = noise(t * 7) * exp(-t * 1.25)
                let low = sin(2 * .pi * 42 * t) * exp(-t * 1.8)
                return (roll * 0.48 + low * 0.7) * 0.5
            }
        case .debris:
            return makeBuffer(duration: 0.32) { t in
                pulse(t, every: 0.035, width: 0.012) * noise(t * 35) * exp(-t * 5.5) * 0.45
            }
        }
    }

    private func makeSirenBuffer() -> AVAudioPCMBuffer {
        makeBuffer(duration: 2.6) { t in
            let wave = sin(t * .pi)
            let frequency = wave > 0 ? 650.0 : 470.0
            let wobble = sin(2 * .pi * 4.0 * t) * 22
            return sin(2 * .pi * (frequency + wobble) * t) * 0.28
        }
    }

    private func makeBuffer(duration: Double, generator: (Double) -> Double) -> AVAudioPCMBuffer {
        let frameCount = AVAudioFrameCount(format.sampleRate * duration)
        let buffer = AVAudioPCMBuffer(pcmFormat: format, frameCapacity: frameCount)!
        buffer.frameLength = frameCount

        guard let channels = buffer.floatChannelData else { return buffer }
        let sampleCount = Int(frameCount)

        for frame in 0..<sampleCount {
            let t = Double(frame) / format.sampleRate
            let value = Float(clamp(generator(t), min: -1, max: 1))
            channels[0][frame] = value
            channels[1][frame] = value
        }

        return buffer
    }

    // MARK: - DSP Helpers

    private func pulse(_ t: Double, every: Double, width: Double) -> Double {
        let phase = t.truncatingRemainder(dividingBy: every)
        guard phase < width else { return 0 }
        return 1 - phase / width
    }

    private func stepValue(_ t: Double, beat: Double, values: [Double]) -> Double {
        let index = Int((t / beat).rounded(.down)) % values.count
        return values[index]
    }

    private func noise(_ t: Double) -> Double {
        let value = sin(t * 12_989.8 + sin(t * 78.233) * 43_758.5453) * 43_758.5453
        return (value - floor(value)) * 2 - 1
    }

    private func saw(_ frequency: Double, _ t: Double) -> Double {
        let phase = (frequency * t).truncatingRemainder(dividingBy: 1)
        return phase * 2 - 1
    }

    private func clamp<T: Comparable>(_ value: T, min lower: T, max upper: T) -> T {
        Swift.max(lower, Swift.min(value, upper))
    }
}

private extension AudioManager.CityAudioTheme {
    static var allCasesForAudio: [AudioManager.CityAudioTheme] {
        [.newYork, .losAngeles, .miami]
    }
}
