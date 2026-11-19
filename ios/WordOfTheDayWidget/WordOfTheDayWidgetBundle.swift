//
//  WordOfTheDayWidgetBundle.swift
//  WordOfTheDayWidget
//
//  Intellectual property of Strauch Development. All rights reserved.
//

import SwiftUI
import WidgetKit

/// Entry point for the widget extension process.
///
/// @invariant: Exposes only [WordOfTheDayWidget] to the host operating system.
@main
struct WordOfTheDayWidgetBundle: WidgetBundle {
    /// @postcondition: Registers the daily word widget configuration.
    var body: some Widget {
        WordOfTheDayWidget()
    }
}