//
//  RacingView.swift
//  NextToGoRacing
//
//  Created by Zhiying Fan on 4/12/2024.
//

import DesignKit
import SwiftUI

struct RacingView: View {
    @StateObject private var viewModel = RacingViewModel()

    var body: some View {
        Group {
            switch viewModel.loadState {
            case .idle:
                emptyView()
            case .loading:
                ProgressView()
            case let .error(noInternet):
                errorView(noInternet: noInternet)
            case .finish:
                raceListView()
            }
        }
        .onAppear {
            viewModel.fetchRacesPeriodically()
        }
    }

    @ViewBuilder
    func emptyView() -> some View {
        VStack(spacing: DesignKit.Spacing.spacing04) {
            Text("No Upcoming Races")

            Button("Refresh") {
                viewModel.fetchRacesPeriodically()
            }
            .foregroundStyle(DesignKit.Color.orange)
        }
    }

    @ViewBuilder
    func errorView(noInternet: Bool) -> some View {
        VStack(spacing: DesignKit.Spacing.spacing04) {
            if noInternet {
                Text("Please check your network connection")
            } else {
                Text("Something went wrong")
            }

            Button("Retry") {
                viewModel.fetchRacesPeriodically()
            }
            .foregroundStyle(DesignKit.Color.orange)
        }
    }

    @ViewBuilder
    func raceListView() -> some View {
        List(viewModel.filteredRacesInOrder, id: \.raceID) { race in
            RacingRowView(raceSummary: race)
        }
        .listStyle(.plain)
    }
}

#Preview {
    RacingView()
}
