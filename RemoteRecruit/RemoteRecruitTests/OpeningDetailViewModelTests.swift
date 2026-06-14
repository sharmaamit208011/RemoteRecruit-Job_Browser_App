//
//  OpeningDetailViewModelTests.swift
//  OpeningDetailViewModelTests
//
//  Created by Amit Sharma on 14/06/26.
//

import Testing
@testable import RemoteRecruit
import RRNetworking

@MainActor
@Suite("Opening detail view model")
struct OpeningDetailViewModelTests {
    @Test("passes the opening through")
    func openingIsPassedThrough() {
        let opening = JobOpening.testMocks[0]
        let sut = OpeningDetailViewModel(opening: opening)

        #expect(sut.opening == opening)
        #expect(sut.opening.formattedSalary.isEmpty == false)
    }

    @Test("displayQualifications returns parsed qualification values")
    func displayQualificationsReturnsArray() {
        let sut = OpeningDetailViewModel(opening: JobOpening.testMocks[0])

        #expect(sut.displayQualifications == ["Swift"])
    }

    @Test(
        "openingsText handles singular and plural copy",
        arguments: [
            (1, "1 Opening"),
            (0, "0 Openings"),
            (5, "5 Openings")
        ]
    )
    func openingsText(openings: Int, expectedText: String) {
        let sut = OpeningDetailViewModel(opening: makeOpening(openings: openings))

        #expect(sut.openingsText == expectedText)
    }

    @Test(
        "employmentBadgeColor maps employment type",
        arguments: [
            ("Full-time Developer", "FullTimeBadge"),
            ("Part-time Designer", "PartTimeBadge"),
            ("Contract Developer", "ContractBadge"),
            ("Freelance Developer", "FreelanceBadge"),
            ("Internship", "DefaultBadge")
        ]
    )
    func employmentBadgeColor(employmentType: String, expectedColor: String) {
        let sut = OpeningDetailViewModel(opening: makeOpening(employmentType: employmentType))

        #expect(sut.employmentBadgeColor == expectedColor)
    }

    private func makeOpening(
        openings: Int = 1,
        employmentType: String = "Full-time Developer"
    ) -> JobOpening {
        JobOpening(id: "x", title: "Dev", description: "Desc", company: "Co",
            location: "NY", salaryFrom: 50000, salaryTo: 80000,
            employmentType: employmentType, applicationDeadline: "Mon, 01/01/2025",
            qualifications: "[\"Swift\"]", contact: "000", category: "Mobile",
            remoteWorkFlag: 0, openingsCount: openings,
            createdAt: "Sun, 10/15/2023", updatedAt: "Sun, 10/15/2023")
    }
}
