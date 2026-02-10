//
//  StatisticsView.swift
//  FoodWise
//
//  Created by Illia Melnyk on 16.12.2025.
//

import SwiftUI

struct StatisticsView: View {
    @StateObject private var viewModel = StatisticsViewModel()
    
    var body: some View {
        NavigationView {
            ScrollView {
                if viewModel.state.isLoading {
                    ProgressView("Loading statistics...")
                        .padding(.top, 50)
                } else {
                    VStack(spacing: 30) {
                        
                        ScoreCardView(state: viewModel.state)
                            .accessibilityIdentifier("score_card_view")
                        
                        VStack(alignment: .leading, spacing: 20) {
                            Text("Most frequent waste:")
                                .font(.title3)
                                .fontDesign(.serif)
                                .bold()
                                .padding(.horizontal)
                                .accessibilityIdentifier("waste_chart_title")
                            
                            if viewModel.state.topWastedItems.isEmpty {
                                Text("The is no waste yet. Good work!")
                                    .foregroundColor(.gray)
                                    .padding()
                                    .frame(maxWidth: .infinity, alignment: .center)
                            } else {
                                VStack(spacing: 25) {
                                    ForEach(viewModel.state.topWastedItems) { item in
                                        WasteRowView(item: item)
                                    }
                                }
                                .padding(.horizontal)
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            .navigationTitle("Statistic")
            .onAppear {
                viewModel.startListening()
                        }
            .onDisappear {
                viewModel.stopListening()
            }
        }
    }
}


