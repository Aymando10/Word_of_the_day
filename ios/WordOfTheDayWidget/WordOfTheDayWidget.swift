//
//  WordOfTheDayWidget.swift
//  WordOfTheDayWidget
//
//  Intellectual property of Strauch Development. All rights reserved.
//

import SwiftUI
import WidgetKit

/// Constants shared with the Flutter app.
///
/// @invariant: Keys match `lib/services/widget_sync_service.dart`, and the
/// rotation epoch matches `rotationEpoch` in `lib/services/word_selector.dart`.
private enum WidgetConfig {
    static let kind = "WordOfTheDayWidget"
    static let appGroupId = "group.com.aymanstrauch.wordapp"
    static let poolKey = "word_pool"
    static let wordKey = "daily_word"
    static let definitionKey = "daily_def"
    static let epoch = DateComponents(year: 2020, month: 1, day: 1)
    static let lookaheadDays = 14

    static let fallbackWord = "Word of the Day"
    static let fallbackDefinition = "Open the app to choose what you'd like to learn."
}

/// Forest-green palette mirroring `lib/theme.dart`.
private enum Palette {
    static let top = Color(hex: 0x173126)
    static let bottom = Color(hex: 0x0A1913)
    static let cream = Color(hex: 0xF1EADB)
    static let gold = Color(hex: 0xD8BE85)
    static let sage = Color(hex: 0x8DBF9E)
}

private extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}

/// One word in the rotation, as written by `Word.toWidgetJson()` in Dart.
private struct PooledWord: Decodable {
    let word: String
    let definition: String
    let pronunciation: String?
    let partOfSpeech: String?
}

/// A single widget render state.
///
/// @invariant: [word] and [definition] are non-empty, trimmed display strings.
struct WordEntry: TimelineEntry {
    let date: Date
    let word: String
    let definition: String
    let pronunciation: String
    let partOfSpeech: String

    init(date: Date, word: String?, definition: String?, pronunciation: String? = nil, partOfSpeech: String? = nil) {
        func clean(_ s: String?) -> String { s?.trimmingCharacters(in: .whitespacesAndNewlines) ?? "" }
        self.date = date
        let w = clean(word)
        let d = clean(definition)
        self.word = w.isEmpty ? WidgetConfig.fallbackWord : w
        self.definition = d.isEmpty ? WidgetConfig.fallbackDefinition : d
        self.pronunciation = clean(pronunciation)
        self.partOfSpeech = clean(partOfSpeech)
    }

    static func preview(at date: Date = .now) -> WordEntry {
        WordEntry(
            date: date,
            word: "Petrichor",
            definition: "The earthy scent produced when rain falls on dry soil.",
            pronunciation: "PET-rih-kor",
            partOfSpeech: "noun"
        )
    }
}

/// Builds the timeline from the rotation stored in the App Group.
///
/// The widget picks each day's word itself, using the same rule as the app,
/// so it keeps updating every midnight even if the app is never reopened.
struct Provider: TimelineProvider {
    /// Gregorian calendar in the device's current time zone, rebuilt on each
    /// access so day boundaries follow time zone changes.
    private static var calendar: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }

    func placeholder(in context: Context) -> WordEntry {
        .preview()
    }

    func getSnapshot(in context: Context, completion: @escaping (WordEntry) -> Void) {
        if context.isPreview {
            completion(.preview())
        } else {
            completion(buildEntries(from: .now).first ?? readFallbackEntry(at: .now))
        }
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        let now = Date.now
        let entries = buildEntries(from: now)
        let calendar = Self.calendar

        // Rebuild the day after the last entry, so the timeline never runs dry.
        let lastDay = calendar.startOfDay(for: entries.last?.date ?? now)
        let reloadDate = calendar.date(byAdding: .day, value: 1, to: lastDay)
            ?? now.addingTimeInterval(86_400)

        completion(Timeline(entries: entries, policy: .after(reloadDate)))
    }

    /// One entry per day, starting now and switching at each local midnight.
    ///
    /// @postcondition: Returns a non-empty, chronologically ordered array.
    private func buildEntries(from now: Date) -> [WordEntry] {
        let pool = loadPool()
        let calendar = Self.calendar
        guard !pool.isEmpty, let epoch = calendar.date(from: WidgetConfig.epoch) else {
            return [readFallbackEntry(at: now)]
        }

        let startOfToday = calendar.startOfDay(for: now)
        var entries: [WordEntry] = []

        for offset in 0..<WidgetConfig.lookaheadDays {
            guard let day = calendar.date(byAdding: .day, value: offset, to: startOfToday) else { continue }
            let days = calendar.dateComponents([.day], from: epoch, to: day).day ?? 0
            let count = pool.count
            let item = pool[((days % count) + count) % count]

            entries.append(
                WordEntry(
                    date: offset == 0 ? now : day,
                    word: item.word,
                    definition: item.definition,
                    pronunciation: item.pronunciation,
                    partOfSpeech: item.partOfSpeech
                )
            )
        }

        return entries.isEmpty ? [readFallbackEntry(at: now)] : entries
    }

    private func loadPool() -> [PooledWord] {
        guard
            let json = UserDefaults(suiteName: WidgetConfig.appGroupId)?.string(forKey: WidgetConfig.poolKey),
            let data = json.data(using: .utf8),
            let pool = try? JSONDecoder().decode([PooledWord].self, from: data)
        else {
            return []
        }
        return pool
    }

    private func readFallbackEntry(at date: Date) -> WordEntry {
        let defaults = UserDefaults(suiteName: WidgetConfig.appGroupId)
        return WordEntry(
            date: date,
            word: defaults?.string(forKey: WidgetConfig.wordKey),
            definition: defaults?.string(forKey: WidgetConfig.definitionKey)
        )
    }
}

/// Renders the word on the Home Screen and Lock Screen.
struct WordOfTheDayWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: WordEntry

    var body: some View {
        content
            .containerBackground(for: .widget) {
                if family == .accessoryRectangular {
                    Color.clear
                } else {
                    LinearGradient(
                        colors: [Palette.top, Palette.bottom],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                }
            }
    }

    @ViewBuilder
    private var content: some View {
        if family == .accessoryRectangular {
            lockScreen
        } else {
            homeScreen
        }
    }

    private var lockScreen: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(entry.word)
                .font(.system(.headline, design: .serif, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
                .widgetAccentable()
            Text(entry.definition)
                .font(.caption2)
                .lineLimit(2)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private var isSmall: Bool { family == .systemSmall }

    private var detailLine: String {
        isSmall
            ? entry.partOfSpeech
            : [entry.pronunciation, entry.partOfSpeech].filter { !$0.isEmpty }.joined(separator: "  ·  ")
    }

    private var homeScreen: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("WORD OF THE DAY")
                .font(.system(size: 9, weight: .semibold))
                .tracking(1.6)
                .foregroundStyle(Palette.gold)

            Spacer(minLength: 6)

            Text(entry.word)
                .font(.system(size: isSmall ? 24 : 28, weight: .semibold, design: .serif))
                .foregroundStyle(Palette.cream)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            if !detailLine.isEmpty {
                Text(detailLine)
                    .font(.system(size: 11, design: .serif).italic())
                    .foregroundStyle(Palette.sage)
                    .lineLimit(1)
                    .padding(.top, 2)
            }

            Rectangle()
                .fill(Palette.gold)
                .frame(width: 22, height: 1.5)
                .padding(.vertical, isSmall ? 6 : 8)

            Text(entry.definition)
                .font(.system(size: isSmall ? 12 : 13))
                .foregroundStyle(Palette.cream.opacity(0.85))
                .lineLimit(3)
                .fixedSize(horizontal: false, vertical: true)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }
}

/// Widget configuration.
///
/// @invariant: [kind] matches the widget name the Flutter app reloads.
struct WordOfTheDayWidget: Widget {
    let kind: String = WidgetConfig.kind

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WordOfTheDayWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Word of the Day")
        .description("A new word every day, on your Home Screen or Lock Screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

#Preview(as: .systemSmall) {
    WordOfTheDayWidget()
} timeline: {
    WordEntry.preview()
}

#Preview(as: .systemMedium) {
    WordOfTheDayWidget()
} timeline: {
    WordEntry.preview()
}
