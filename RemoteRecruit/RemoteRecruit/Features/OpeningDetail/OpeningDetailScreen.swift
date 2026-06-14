//
//  OpeningDetailScreen.swift
//  RemoteRecruit
//
//  Created by Amit Sharma on 14/06/26.
//

import SwiftUI
import RRNetworking

struct OpeningDetailScreen: View {
    let opening: JobOpening
    @StateObject private var viewModel: OpeningDetailViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var headerVisible = false
    @State private var contentVisible = false

    init(opening: JobOpening) {
        self.opening = opening
        _viewModel = StateObject(wrappedValue: OpeningDetailViewModel(opening: opening))
    }

    var body: some View {
        ZStack(alignment: .top) {
            Color("GradientStart").ignoresSafeArea()
            ScrollView {
                VStack(spacing: 0) {
                    heroHeader
                    detailCard
                }
            }
            .scrollIndicators(.hidden)
            navigationBar
        }
        .navigationBarHidden(true)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                headerVisible = true
            }
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.2)) {
                contentVisible = true
            }
        }
    }

    private var navigationBar: some View {
        HStack {
            Button { dismiss() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundStyle(.white)
                    .padding(10)
                    .background(.white.opacity(0.2), in: Circle())
            }
            Spacer()
            Text("Opening Details")
                .font(AppTheme.Font.subheadline())
                .foregroundStyle(.white)
            Spacer()
            Color.clear.frame(width: 40, height: 40)
        }
        .padding(.horizontal, AppTheme.Spacing.md)
        .padding(.top, 8)
    }

    private var heroHeader: some View {
        VStack(spacing: AppTheme.Spacing.sm) {
            Spacer().frame(height: 60)
            companyAvatar
            Text(opening.title)
                .font(AppTheme.Font.title())
                .foregroundStyle(.white)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
            Text(opening.company)
                .font(AppTheme.Font.subheadline())
                .foregroundStyle(.white.opacity(0.8))
            quickChips
        }
        .padding(.bottom, AppTheme.Spacing.lg)
        .opacity(headerVisible ? 1 : 0)
        .offset(y: headerVisible ? 0 : -20)
    }

    private var companyAvatar: some View {
        ZStack {
            Circle()
                .fill(.white.opacity(0.2))
                .frame(width: 72, height: 72)
            Text(String(opening.company.prefix(1)).uppercased())
                .font(.system(size: 30, weight: .bold, design: .rounded))
                .foregroundStyle(.white)
        }
    }

    private var quickChips: some View {
        HStack(spacing: AppTheme.Spacing.sm) {
            chipView(icon: "mappin.fill", text: opening.isRemote ? "Remote" : "On-site")
            chipView(icon: "person.2.fill", text: viewModel.openingsText)
            chipView(icon: "tag.fill", text: opening.category)
        }
        .padding(.horizontal)
    }

    private func chipView(icon: String, text: String) -> some View {
        HStack(spacing: 4) {
            Image(systemName: icon).font(.system(size: 10))
            Text(text).font(AppTheme.Font.caption())
        }
        .foregroundStyle(.white)
        .padding(.horizontal, AppTheme.Spacing.sm)
        .padding(.vertical, 5)
        .background(.white.opacity(0.15), in: Capsule())
        .lineLimit(1)
    }

    private var detailCard: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.lg) {
            salarySection
            Divider()
            overviewSection
            Divider()
            descriptionSection
            Divider()
            qualificationsSection
            Divider()
            contactSection
            applyButton
        }
        .padding(AppTheme.Spacing.lg)
        .background(.white, in: RoundedRectangle(cornerRadius: 28).corners([.topLeft, .topRight]))
        .offset(y: contentVisible ? 0 : 30)
        .opacity(contentVisible ? 1 : 0)
    }

    private var salarySection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.xs) {
            sectionLabel("Salary Range")
            Text(opening.formattedSalary)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundStyle(Color("AccentColor"))
        }
    }

    private var overviewSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            sectionLabel("Overview")
            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: AppTheme.Spacing.sm) {
                infoTile(icon: "clock.fill", title: "Type", value: opening.employmentType)
                infoTile(icon: "calendar", title: "Deadline", value: opening.applicationDeadline)
                infoTile(icon: "mappin.and.ellipse", title: "Location", value: opening.location)
                infoTile(icon: "briefcase.fill", title: "Category", value: opening.category)
            }
        }
    }

    private func infoTile(icon: String, title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 11))
                    .foregroundStyle(Color("AccentColor"))
                Text(title)
                    .font(AppTheme.Font.caption())
                    .foregroundStyle(Color("SecondaryText"))
            }
            Text(value)
                .font(AppTheme.Font.caption())
                .fontWeight(.medium)
                .foregroundStyle(Color("PrimaryText"))
                .lineLimit(2)
        }
        .padding(AppTheme.Spacing.sm)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color("TagBackground"), in: RoundedRectangle(cornerRadius: AppTheme.Radius.tag))
    }

    private var descriptionSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            sectionLabel("Role Description")
            Text(opening.description)
                .font(AppTheme.Font.body())
                .foregroundStyle(Color("PrimaryText"))
                .lineSpacing(5)
        }
    }

    private var qualificationsSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            sectionLabel("Qualifications")
            ForEach(viewModel.displayQualifications, id: \.self) { qual in
                HStack(spacing: AppTheme.Spacing.sm) {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color("AccentColor"))
                        .font(.system(size: 14))
                    Text(qual)
                        .font(AppTheme.Font.body())
                        .foregroundStyle(Color("PrimaryText"))
                }
            }
        }
    }

    private var contactSection: some View {
        VStack(alignment: .leading, spacing: AppTheme.Spacing.sm) {
            sectionLabel("Contact")
            Label(opening.contact, systemImage: "phone.fill")
                .font(AppTheme.Font.body())
                .foregroundStyle(Color("PrimaryText"))
        }
    }

    private var applyButton: some View {
        Button {
        } label: {
            HStack {
                Spacer()
                Text("Apply Now")
                    .font(AppTheme.Font.headline())
                    .foregroundStyle(.white)
                Image(systemName: "arrow.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white)
                Spacer()
            }
            .padding(.vertical, AppTheme.Spacing.md)
            .background(
                LinearGradient(
                    colors: [Color("AccentColor"), Color("GradientStart")],
                    startPoint: .leading,
                    endPoint: .trailing
                ),
                in: RoundedRectangle(cornerRadius: AppTheme.Radius.button)
            )
        }
        .padding(.top, AppTheme.Spacing.sm)
    }

    private func sectionLabel(_ text: String) -> some View {
        Text(text)
            .font(AppTheme.Font.headline())
            .foregroundStyle(Color("PrimaryText"))
    }
}

extension RoundedRectangle {
    func corners(_ corners: UIRectCorner) -> some Shape {
        UnevenRoundedRectangle(
            topLeadingRadius: corners.contains(.topLeft) ? 28 : 0,
            bottomLeadingRadius: corners.contains(.bottomLeft) ? 28 : 0,
            bottomTrailingRadius: corners.contains(.bottomRight) ? 28 : 0,
            topTrailingRadius: corners.contains(.topRight) ? 28 : 0
        )
    }
}
