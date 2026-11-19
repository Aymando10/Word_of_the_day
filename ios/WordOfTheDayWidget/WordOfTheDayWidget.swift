//
//  WordOfTheDayWidget.swift
//  WordOfTheDayWidget
//
//  Intellectual property of Strauch Development. All rights reserved.
//

import SwiftUI
import WidgetKit

/// Centralized configuration constants shared with the Flutter bridge.
///
/// @invariant: Identifiers match the Dart [WidgetSyncService] constants character-for-character.
private enum WidgetConfig {
    static let kind = "WordOfTheDayWidget"
    static let appGroupId = "group.com.aymanstrauch.wordapp"
    static let wordKey = "daily_word"
    static let definitionKey = "daily_def"
    static let scheduleKey = "word_schedule"
    static let lookaheadDays = 14

    static let fallbackWord = "Open Word of the Day"
    static let fallbackDefinition = "Sync today's word from the app to get started."
    static let previewWord = "Petrichor"
    static let previewDefinition = "The earthy scent that follows the first rain after a dry spell."
}

/// Decodable DTO matching the JSON structure written by Dart's [WordOfTheDay.toJson].
///
/// @invariant: Mirrors the exact keys serialized by the Flutter bridge.
private struct ScheduledWordDTO: Decodable {
    let word: String
    let definition: String
}

/// Immutable timeline payload representing a single widget render state.
///
/// @invariant: [word] and [definition] are guaranteed to be non-empty, trimmed display strings.
struct WordEntry: TimelineEntry {
    let date: Date
    let word: String
    let definition: String

    /// Sanitizes inputs so the struct invariant holds regardless of caller.
    ///
    /// @precondition: [date] is a valid [Date] instance.
    /// @postcondition: Initializes non-empty [word] and [definition], falling back to defaults if blank.
    init(date: Date, word: String?, definition: String?) {
        self.date = date
        let trimmedWord = word?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
        let trimmedDef = definition?.trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

        self.word = trimmedWord.isEmpty ? WidgetConfig.fallbackWord : trimmedWord
        self.definition = trimmedDef.isEmpty ? WidgetConfig.fallbackDefinition : trimmedDef
    }

    /// Representative sample entry for the iOS Widget Gallery and Xcode previews.
    ///
    /// @postcondition: Returns a populated [WordEntry] stamped with [date].
    static func preview(at date: Date = .now) -> WordEntry {
        WordEntry(
            date: date,
            word: WidgetConfig.previewWord,
            definition: WidgetConfig.previewDefinition
        )
    }
}

/// Supplies multi-day timeline entries to WidgetKit from the shared App Group container.
///
/// @invariant: Reads exclusively from the configured App Group suite and always returns at least one entry.
struct Provider: TimelineProvider {
    /// Gregorian calendar in the device's *current* time zone, rebuilt on each access so
    /// date keys stay in sync with Dart's local `DateTime` if the user changes time zones.
    private static var gregorian: Calendar {
        var calendar = Calendar(identifier: .gregorian)
        calendar.timeZone = .current
        return calendar
    }

    /// @postcondition: Returns a non-empty placeholder entry for skeleton loading.
    func placeholder(in context: Context) -> WordEntry {
        .preview()
    }

    /// @precondition: [context] describes the current WidgetKit rendering environment.
    /// @postcondition: Returns the preview entry for the Widget Gallery, or today's entry otherwise.
    func getSnapshot(in context: Context, completion: @escaping (WordEntry) -> Void) {
        if context.isPreview {
            completion(.preview())
        } else {
            let entries = buildScheduledEntries(startingFrom: .now)
            completion(entries.first ?? readFallbackEntry(at: .now))
        }
    }

    /// @precondition: WidgetKit requests a timeline update.
    /// @postcondition: Delivers a multi-day midnight-aligned timeline and requests a reload when exhausted.
    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        let now = Date.now
        let entries = buildScheduledEntries(startingFrom: now)

        // Request a new timeline once the pre-scheduled entries finish, or after tomorrow's midnight if using fallback.
        let reloadPolicy: TimelineReloadPolicy
        if entries.count > 1 {
            reloadPolicy = .atEnd
        } else {
            let nextMidnight = Self.gregorian.nextDate(
                after: now,
                matching: DateComponents(hour: 0, minute: 0, second: 0),
                matchingPolicy: .nextTime
            ) ?? now.addingTimeInterval(86_400)
            reloadPolicy = .after(nextMidnight)
        }

        completion(Timeline(entries: entries, policy: reloadPolicy))
    }

    /// Builds up to [WidgetConfig.lookaheadDays] timeline entries aligned to local midnight boundaries.
    ///
    /// @precondition: [referenceDate] is the current evaluation timestamp.
    /// @postcondition: Returns a chronologically ordered, non-empty array of [WordEntry] items.
    private func buildScheduledEntries(startingFrom referenceDate: Date) -> [WordEntry] {
        let defaults = UserDefaults(suiteName: WidgetConfig.appGroupId)
        guard
            let jsonString = defaults?.string(forKey: WidgetConfig.scheduleKey),
            let jsonData = jsonString.data(using: .utf8),
            let schedule = try? JSONDecoder().decode([String: ScheduledWordDTO].self, from: jsonData),
            !schedule.isEmpty
        else {
            return [readFallbackEntry(at: referenceDate)]
        }

        let startOfToday = Self.gregorian.startOfDay(for: referenceDate)
        var entries: [WordEntry] = []

        for dayOffset in 0..<WidgetConfig.lookaheadDays {
            guard let targetDay = Self.gregorian.date(byAdding: .day, value: dayOffset, to: startOfToday) else {
                continue
            }
            let key = Self.dateKey(for: targetDay)
            guard let scheduled = schedule[key] else {
                continue
            }

            // Day 0 renders immediately at referenceDate; future days activate at 00:00:00 local midnight.
            let entryTimestamp = (dayOffset == 0) ? referenceDate : targetDay
            entries.append(
                WordEntry(
                    date: entryTimestamp,
                    word: scheduled.word,
                    definition: scheduled.definition
                )
            )
        }

        return entries.isEmpty ? [readFallbackEntry(at: referenceDate)] : entries
    }

    /// Reads the single-day fallback keys if no valid schedule exists for the current date.
    ///
    /// @precondition: [date] is a valid [Date] instance.
    /// @postcondition: Returns a valid [WordEntry] using single-day keys or default instructions.
    private func readFallbackEntry(at date: Date) -> WordEntry {
        let defaults = UserDefaults(suiteName: WidgetConfig.appGroupId)
        return WordEntry(
            date: date,
            word: defaults?.string(forKey: WidgetConfig.wordKey),
            definition: defaults?.string(forKey: WidgetConfig.definitionKey)
        )
    }

    /// Formats [date] as a locale-independent YYYY-MM-DD key using Gregorian components.
    ///
    /// @precondition: [date] is a valid [Date] instance.
    /// @postcondition: Returns a 10-character ASCII string matching Dart's date key format.
    private static func dateKey(for date: Date) -> String {
        let comps = gregorian.dateComponents([.year, .month, .day], from: date)
        return String(
            format: "%04d-%02d-%02d",
            comps.year ?? 1970,
            comps.month ?? 1,
            comps.day ?? 1
        )
    }
}

/// Adaptive SwiftUI view rendering the daily word across Home Screen and Lock Screen families.
///
/// @invariant: Typography and line limits adapt to [widgetFamily] without clipping the primary word.
struct WordOfTheDayWidgetEntryView: View {
    @Environment(\.widgetFamily) private var family
    let entry: Provider.Entry

    /// @postcondition: Renders the word hierarchy scaled to the active widget family bounds.
    var body: some View {
        VStack(alignment: .leading, spacing: family == .accessoryRectangular ? 2 : 6) {
            Text(entry.word)
                .font(.system(titleFont, design: .serif, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.65)

            Text(entry.definition)
                .font(definitionFont)
                .foregroundStyle(.secondary)
                .lineLimit(definitionLineLimit)

            if family != .accessoryRectangular {
                Spacer(minLength: 0)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
    }

    private var titleFont: Font.TextStyle {
        switch family {
        case .accessoryRectangular: return .headline
        case .systemSmall: return .title3
        default: return .title2
        }
    }

    private var definitionFont: Font {
        family == .accessoryRectangular ? .caption2 : .subheadline
    }

    private var definitionLineLimit: Int {
        switch family {
        case .accessoryRectangular: return 2
        case .systemSmall: return 4
        default: return 3
        }
    }
}

/// Widget configuration registering the daily word view and supported display families.
///
/// @invariant: [kind] matches [WidgetConfig.kind] used by the Flutter bridge.
struct WordOfTheDayWidget: Widget {
    let kind: String = WidgetConfig.kind

    /// @postcondition: Configures a static widget supporting small, medium, and lock screen families.
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WordOfTheDayWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WordOfTheDayWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Word of the Day")
        .description("Expand your vocabulary with a daily word on your Home or Lock Screen.")
        .supportedFamilies([.systemSmall, .systemMedium, .accessoryRectangular])
    }
}

#Preview(as: .systemSmall) {
    WordOfTheDayWidget()
} timeline: {
    WordEntry.preview()
}