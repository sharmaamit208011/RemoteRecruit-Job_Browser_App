//
//  OpeningCardView.swift
//  RemoteRecruit
//
//  Created by Amit Sharma on 14/06/26.
//

import SwiftUI
import RRNetworking

struct OpeningCardView: View {
    let opening: JobOpening
    let index: Int
    @State private var appeared = false

    var body: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            topRow
            Divider().opacity(0.5)
            bottomRow
        }
        .padding(AppTheme.Spacing.md)
        .background(.white, in: RoundedRectangle(cornerRadius: AppTheme.Radius.card))
        .shadow(color: .black.opacity(0.07), radius: 12, y: 4)
        .opacity(appeared ? 1 : 0)
        .offset(y: appeared ? 0 : 20)
        .onAppear {
            let delay = Double(index % 10) * 0.04
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(delay)) {
                appeared = true
            }
        }
    }

    private var topRow: some View {
        HStack(alignment: .top, spacing: AppTheme.Spacing.sm) {
            companyLogo
            VStack(alignment: .leading, spacing: 2) {
                Text(opening.title)
                    .font(AppTheme.Font.headline())
                    .foregroundStyle(Color("PrimaryText"))
                    .lineLimit(2)
                Text(opening.company)
                    .font(AppTheme.Font.subheadline())
                    .foregroundStyle(Color("SecondaryText"))
            }
            Spacer()
            if opening.isRemote {
                remoteTag
            }
        }
    }

    private var companyLogo: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 10)
                .fill(
                    LinearGradient(
                        colors: [gradientColor(for: opening.company).opacity(0.2), gradientColor(for: opening.company).opacity(0.1)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
            Text(String(opening.company.prefix(1)).uppercased())
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(gradientColor(for: opening.company))
        }
        .frame(width: 44, height: 44)
    }

    private var remoteTag: some View {
        Text("Remote")
            .font(AppTheme.Font.caption())
            .foregroundStyle(.white)
            .padding(.horizontal, AppTheme.Spacing.sm)
            .padding(.vertical, 3)
            .background(Color("AccentColor"), in: Capsule())
    }

    private var bottomRow: some View {
        HStack(spacing: AppTheme.Spacing.md) {
            Label(opening.location, systemImage: "mappin.circle.fill")
                .font(AppTheme.Font.caption())
                .foregroundStyle(Color("SecondaryText"))
                .lineLimit(1)
            Spacer()
            Text(opening.formattedSalary)
                .font(AppTheme.Font.caption())
                .fontWeight(.semibold)
                .foregroundStyle(Color("AccentColor"))
        }
    }

    private func gradientColor(for name: String) -> Color {
        let colors: [Color] = [.blue, .purple, .pink, .orange, .teal, .indigo, .mint, .cyan]
        let index = abs(name.hashValue) % colors.count
        return colors[index]
    }
}
