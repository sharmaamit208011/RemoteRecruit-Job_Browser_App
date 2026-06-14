//
//  OpeningsListScreen.swift
//  RemoteRecruit
//
//  Created by Amit Sharma on 14/06/26.
//

import SwiftUI
import RRNetworking

struct OpeningsListScreen: View {
    @StateObject private var viewModel = OpeningsListViewModel()
    @State private var selectedOpening: JobOpening?
    @State private var animateHeader = false

    var body: some View {
        NavigationStack {
            ZStack {
                backgroundGradient
                content
            }
            .navigationBarHidden(true)
            .navigationDestination(item: $selectedOpening) { opening in
                OpeningDetailScreen(opening: opening)
            }
        }
        .task {
            await viewModel.loadOpenings()
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                animateHeader = true
            }
        }
    }

    private var backgroundGradient: some View {
        LinearGradient(
            colors: [Color("GradientStart"), Color("GradientEnd")],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    private var content: some View {
        VStack(spacing: 0) {
            headerSection
            searchBar
            openingsSection
        }
    }

    private var headerSection: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 2) {
                Text("Find Your")
                    .font(AppTheme.Font.subheadline())
                    .foregroundStyle(.white.opacity(0.75))
                Text("Next Role")
                    .font(AppTheme.Font.title())
                    .foregroundStyle(.white)
            }
            Spacer()
            openingCountBadge
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, AppTheme.Spacing.lg)
        .padding(.bottom, AppTheme.Spacing.sm)
        .offset(y: animateHeader ? 0 : -30)
        .opacity(animateHeader ? 1 : 0)
    }

    private var openingCountBadge: some View {
        Group {
            if case .loaded(let openings) = viewModel.state {
                VStack(spacing: 0) {
                    Text("\(openings.count)")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundStyle(.white)
                    Text("Openings")
                        .font(AppTheme.Font.caption())
                        .foregroundStyle(.white.opacity(0.7))
                }
                .padding(.horizontal, AppTheme.Spacing.md)
                .padding(.vertical, AppTheme.Spacing.sm)
                .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: AppTheme.Radius.button))
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            Image(systemName: "magnifyingglass")
                .foregroundStyle(.gray)
            TextField("Search openings, companies...", text: $viewModel.searchText)
                .font(AppTheme.Font.body())
                .onChange(of: viewModel.searchText) { _, newValue in
                    viewModel.search(query: newValue)
                }
            if !viewModel.searchText.isEmpty {
                Button {
                    viewModel.searchText = ""
                    viewModel.search(query: "")
                } label: {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundStyle(.gray)
                }
            }
        }
        .padding(AppTheme.Spacing.sm + 4)
        .background(.white, in: RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .shadow(color: .black.opacity(0.08), radius: 8, y: 4)
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.vertical, AppTheme.Spacing.sm)
        .offset(y: animateHeader ? 0 : -20)
        .opacity(animateHeader ? 1 : 0)
        .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1), value: animateHeader)
    }

    @ViewBuilder
    private var openingsSection: some View {
        switch viewModel.state {
        case .idle:
            Spacer()
        case .loading:
            loadingView
        case .loaded(let openings):
            openingsList(openings: openings)
        case .empty:
            emptyView
        case .error(let message):
            errorView(message: message)
        }
    }

    private var loadingView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Spacer()
            ProgressView()
                .tint(.white)
                .scaleEffect(1.4)
            Text("Loading openings...")
                .font(AppTheme.Font.subheadline())
                .foregroundStyle(.white.opacity(0.8))
            Spacer()
        }
    }

    private func openingsList(openings: [JobOpening]) -> some View {
        ScrollView {
            LazyVStack(spacing: AppTheme.Spacing.sm) {
                ForEach(Array(openings.enumerated()), id: \.element.id) { index, opening in
                    OpeningCardView(opening: opening, index: index)
                        .onTapGesture {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                                selectedOpening = opening
                            }
                        }
                }
            }
            .padding(.horizontal, AppTheme.Spacing.md)
            .padding(.top, AppTheme.Spacing.xs)
            .padding(.bottom, AppTheme.Spacing.xl)
        }
        .scrollIndicators(.hidden)
    }

    private var emptyView: some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Spacer()
            Image(systemName: "briefcase.slash")
                .font(.system(size: 56))
                .foregroundStyle(.white.opacity(0.6))
            Text(viewModel.searchText.isEmpty ? "No openings available" : "No results found")
                .font(AppTheme.Font.headline())
                .foregroundStyle(.white)
            Text(viewModel.searchText.isEmpty ? "Check back later for new listings." : "Try a different search term.")
                .font(AppTheme.Font.body())
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Spacer()
        }
        .padding(AppTheme.Spacing.xl)
    }

    private func errorView(message: String) -> some View {
        VStack(spacing: AppTheme.Spacing.md) {
            Spacer()
            Image(systemName: "wifi.exclamationmark")
                .font(.system(size: 56))
                .foregroundStyle(.white.opacity(0.6))
            Text("Something went wrong")
                .font(AppTheme.Font.headline())
                .foregroundStyle(.white)
            Text(message)
                .font(AppTheme.Font.body())
                .foregroundStyle(.white.opacity(0.7))
                .multilineTextAlignment(.center)
            Button {
                Task { await viewModel.loadOpenings() }
            } label: {
                Label("Try Again", systemImage: "arrow.clockwise")
                    .font(AppTheme.Font.subheadline())
                    .foregroundStyle(.white)
                    .padding(.horizontal, AppTheme.Spacing.lg)
                    .padding(.vertical, AppTheme.Spacing.sm)
                    .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: AppTheme.Radius.button))
            }
            Spacer()
        }
        .padding(AppTheme.Spacing.xl)
    }
}
