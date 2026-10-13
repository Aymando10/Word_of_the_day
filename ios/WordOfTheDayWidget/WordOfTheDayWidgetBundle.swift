//
//  WordOfTheDayWidgetBundle.swift
//  WordOfTheDayWidget
//
//  Created by Ayman Strauch on 10/10/2026.
//

import WidgetKit
import SwiftUI

/// @invariant: The extension registers only the daily-word home screen widget.
@main
struct WordOfTheDayWidgetBundle: WidgetBundle {
    /// @postcondition: Returns the Word of the Day widget as the extension's sole widget.
    var body: some Widget {
        WordOfTheDayWidget()
    }
}
