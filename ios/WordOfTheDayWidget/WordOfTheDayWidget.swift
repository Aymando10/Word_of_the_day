//
//  WordOfTheDayWidget.swift
//  WordOfTheDayWidget
//
//  Created by Ayman Strauch on 10/10/2026.
//

import WidgetKit
import SwiftUI

/// @invariant: Timeline entries always contain displayable word and definition text.
struct WordEntry: TimelineEntry {
    let date: Date
    let word: String
    let definition: String
}

/// @invariant: The provider reads only the app's shared Word of the Day values.
struct Provider: TimelineProvider {
    /// @postcondition: Returns a representative non-empty entry for the widget gallery.
    func placeholder(in context: Context) -> WordEntry {
        WordEntry(date: Date(), word: "Petrichor", definition: "The earthy scent after rain.")
    }

    /// @postcondition: Completes with the latest shared word or a helpful empty state.
    func getSnapshot(in context: Context, completion: @escaping (WordEntry) -> Void) {
        completion(readEntry(at: Date()))
    }

    /// @postcondition: Supplies the current word and schedules a reload after midnight.
    func getTimeline(in context: Context, completion: @escaping (Timeline<WordEntry>) -> Void) {
        let now = Date()
        let nextMidnight = Calendar.current.nextDate(
            after: now,
            matching: DateComponents(hour: 0, minute: 0, second: 0),
            matchingPolicy: .nextTime
        ) ?? now.addingTimeInterval(24 * 60 * 60)
        completion(Timeline(entries: [readEntry(at: now)], policy: .after(nextMidnight)))
    }

    /// @precondition: [date] is a valid timeline date.
    /// @postcondition: Returns shared content, with a usable fallback if data is absent.
    private func readEntry(at date: Date) -> WordEntry {
        let defaults = UserDefaults(suiteName: "group.com.example.wordapp")
        let word = defaults?.string(forKey: "daily_word")?.trimmingCharacters(in: .whitespacesAndNewlines)
        let definition = defaults?.string(forKey: "daily_def")?.trimmingCharacters(in: .whitespacesAndNewlines)
        return WordEntry(
            date: date,
            word: word.flatMap { $0.isEmpty ? nil : $0 } ?? "Open Word of the Day",
            definition: definition.flatMap { $0.isEmpty ? nil : $0 }
                ?? "Sync today's word from the app to get started."
        )
    }
}

/// @invariant: The view renders the entry's word before its definition.
struct WordOfTheDayWidgetEntryView: View {
    let entry: Provider.Entry

    /// @postcondition: Renders readable word and definition text in the widget bounds.
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(entry.word)
                .font(.system(.title, design: .serif).weight(.bold))
                .lineLimit(2)
            Text(entry.definition)
                .font(.body)
                .lineLimit(4)
            Spacer(minLength: 0)
        }
        .padding()
    }
}

/// @invariant: The widget kind matches the name requested by the Flutter bridge.
struct WordOfTheDayWidget: Widget {
    let kind: String = "WordOfTheDayWidget"

    /// @postcondition: Registers a static widget backed by the shared daily word.
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            if #available(iOS 17.0, *) {
                WordOfTheDayWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                WordOfTheDayWidgetEntryView(entry: entry)
                    .background()
            }
        }
        .configurationDisplayName("Word of the Day")
        .description("A daily word and its definition.")
    }
}

#Preview(as: .systemSmall) {
    WordOfTheDayWidget()
} timeline: {
    WordEntry(date: .now, word: "Petrichor", definition: "The earthy scent after rain.")
}
