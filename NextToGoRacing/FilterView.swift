//
//  FilterView.swift
//  NextToGoRacing
//
//  Created by Zhiying Fan on 6/12/2024.
//

import DesignKit
import SwiftUI

struct FilterView: View {
    @Binding var categorySelections: [CategorySelection]

    var body: some View {
        Menu("Filter") {
            ForEach(categorySelections, id: \.category) { categorySelection in
                Button(action: {
                    if let index = categorySelections.firstIndex(where: { $0.category == categorySelection.category }) {
                        categorySelections[index].selected.toggle()
                    }
                }, label: {
                    HStack {
                        Text(categorySelection.category.label)

                        if categorySelection.selected {
                            Image(systemName: "checkmark")
                        }
                    }
                })
                .menuActionDismissBehavior(.disabled)
            }
        }
        .foregroundStyle(DesignKit.Color.orange)
    }
}

#Preview {
    FilterView(categorySelections: .constant([
        CategorySelection(category: .greyhound, selected: true),
        CategorySelection(category: .horse, selected: false),
    ]))
}
