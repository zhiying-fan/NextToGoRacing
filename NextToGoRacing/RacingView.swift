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

    private var shouldShowFilterButton: Bool {
        viewModel.viewState == .empty || viewModel.viewState == .display
    }

    var body: some View {
        NavigationStack {
            Group {
                switch viewModel.viewState {
                case .empty:
                    emptyView()
                case .loading:
                    ProgressView()
                        .accessibilityLabel("Loading")
                case let .error(noInternet):
                    errorView(noInternet: noInternet)
                case .display:
                    raceListView()
                }
            }
            .navigationTitle("Next To Go Racing")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    FilterView(categorySelections: $viewModel.categories)
                        .opacity(shouldShowFilterButton ? 1 : 0)
                }
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
