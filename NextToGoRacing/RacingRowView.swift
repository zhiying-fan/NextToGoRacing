//
//  RacingRowView.swift
//  NextToGoRacing
//
//  Created by Zhiying Fan on 5/12/2024.
//

import DesignKit
import SwiftUI

struct RacingRowView: View {
    let raceSummary: RaceSummary

    var startTime: Date {
        Date(timeIntervalSince1970: TimeInterval(raceSummary.advertisedStart.seconds))
    }

    var body: some View {
        HStack {
            Image(uiImage: raceSummary.category.icon)
                .renderingMode(.template)
                .foregroundStyle(DesignKit.Color.icon)
                .accessibilityLabel(raceSummary.category.label)

            VStack(alignment: .leading) {
                Text(raceSummary.meetingName)
                    .font(DesignKit.Font.title)

                Text("Race \(raceSummary.raceNumber)")
                    .font(DesignKit.Font.subtitle)
            }
            .accessibilityElement(children: .combine)

            Spacer()

            TimelineView(.periodic(from: .now, by: 1)) { _ in
                if startTime < Date.now {
                    Text("Ongoing")
                        .multilineTextAlignment(.trailing)
                        .font(DesignKit.Font.title)
                        .foregroundStyle(DesignKit.Color.orange)
                } else {
                    VStack(alignment: .trailing) {
                        Text("Starts in")
                            .font(DesignKit.Font.subtitle)

                        Text(startTime, style: .timer)
                            .font(DesignKit.Font.title)
                            .foregroundStyle(DesignKit.Color.orange)
                    }
                    .accessibilityElement(children: .combine)
                }
            }
        }
    }
}

#Preview {
    RacingRowView(raceSummary: RaceSummary(
        raceID: "6cb1e96c-acf1-471f-b5bd-0947692b90cc",
        raceNumber: 5,
        meetingName: "Swindon Bags",
        category: .greyhound,
        advertisedStart: AdvertisedStart(seconds: 1_733_477_088)
    ))
}
