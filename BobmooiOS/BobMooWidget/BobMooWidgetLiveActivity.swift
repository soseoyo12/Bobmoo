//
//  BobMooWidgetLiveActivity.swift
//  BobMooWidget
//
//  Created by SeongYongSong on 8/31/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct BobMooWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

@available(iOSApplicationExtension 16.1, *)
struct BobMooWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: BobMooWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension BobMooWidgetAttributes {
    fileprivate static var preview: BobMooWidgetAttributes {
        BobMooWidgetAttributes(name: "World")
    }
}

extension BobMooWidgetAttributes.ContentState {
    fileprivate static var smiley: BobMooWidgetAttributes.ContentState {
        BobMooWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: BobMooWidgetAttributes.ContentState {
         BobMooWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: BobMooWidgetAttributes.preview) {
   BobMooWidgetLiveActivity()
} contentStates: {
    BobMooWidgetAttributes.ContentState.smiley
    BobMooWidgetAttributes.ContentState.starEyes
}
