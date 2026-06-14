//
//  JobOpeningModelTests.swift
//  JobOpeningModelTests
//
//  Created by Amit Sharma on 14/06/26.
//

import Foundation
import Testing
@testable import RRNetworking

@Suite("Job opening model")
struct JobOpeningModelTests {
    @Test("isRemote is true only when remoteWorkFlag is one")
    func isRemote() {
        #expect(JobOpening.mock(remoteWorkFlag: 1).isRemote)
        #expect(JobOpening.mock(remoteWorkFlag: 0).isRemote == false)
        #expect(JobOpening.mock(remoteWorkFlag: 2).isRemote == false)
    }

    @Test("formattedSalary contains both salary bounds")
    func formattedSalaryContainsBothValues() {
        let salary = JobOpening.mock(salaryFrom: 100000, salaryTo: 150000).formattedSalary
        let digits = salary.filter(\.isNumber)

        #expect(digits.contains("100000"))
        #expect(digits.contains("150000"))
        #expect(salary.contains("$") || salary.contains("US$"))
    }

    @Test(
        "parsedQualifications handles common serialized formats",
        arguments: [
            ("[\"Swift\",\"UIKit\",\"MVVM\"]", ["Swift", "UIKit", "MVVM"]),
            ("[ Swift, UIKit ]", ["Swift", "UIKit"]),
            ("   []   ", []),
            ("", [])
        ]
    )
    func parsedQualifications(input: String, expected: [String]) {
        #expect(JobOpening.mock(qualifications: input).parsedQualifications == expected)
    }

    @Test("hashable and equality use id")
    func hashableUsesID() {
        let job1 = JobOpening.mock(id: "same-id", title: "iOS")
        let job2 = JobOpening.mock(id: "same-id", title: "Android")
        let job3 = JobOpening.mock(id: "different-id")

        #expect(job1 == job2)
        #expect(job1 != job3)
        #expect(Set([job1, job2, job3]).count == 2)
    }

    @Test("decodes snake case payload keys")
    func decodesSnakeCasePayloadKeys() throws {
        let json = """
        {
            "id": "xyz",
            "title": "Dev",
            "description": "Desc",
            "company": "Corp",
            "location": "NYC",
            "salary_from": 50000,
            "salary_to": 80000,
            "employment_type": "Full-time Developer",
            "application_deadline": "Mon, 01/01/2024",
            "qualifications": "[\\"Swift\\"]",
            "contact": "000-000-000",
            "job_category": "Mobile App Developer",
            "is_remote_work": 0,
            "number_of_opening": 1,
            "created_at": "Sun, 10/15/2023",
            "updated_at": "Sun, 10/15/2023"
        }
        """.data(using: .utf8)!

        let opening = try JSONDecoder().decode(JobOpening.self, from: json)

        #expect(opening.id == "xyz")
        #expect(opening.salaryFrom == 50000)
        #expect(opening.salaryTo == 80000)
        #expect(opening.employmentType == "Full-time Developer")
        #expect(opening.category == "Mobile App Developer")
        #expect(opening.isRemote == false)
    }

    @Test("encodes model using API payload keys")
    func encodesPayloadKeys() throws {
        let data = try JSONEncoder().encode(JobOpening.mock())
        let object = try #require(JSONSerialization.jsonObject(with: data) as? [String: Any])

        #expect(object["salary_from"] as? Int == 50000)
        #expect(object["salary_to"] as? Int == 80000)
        #expect(object["employment_type"] as? String == "Full-time")
        #expect(object["application_deadline"] as? String == "Mon, 01/01/2024")
        #expect(object["job_category"] as? String == "Mobile")
        #expect(object["is_remote_work"] as? Int == 1)
        #expect(object["number_of_opening"] as? Int == 1)
        #expect(object["created_at"] as? String == "Sun, 10/15/2023")
        #expect(object["updated_at"] as? String == "Sun, 10/15/2023")
    }
}

extension JobOpening {
    static func mock(
        id: String = "id-1",
        title: String = "Dev",
        salaryFrom: Int = 50000,
        salaryTo: Int = 80000,
        qualifications: String = "[\"Swift\"]",
        remoteWorkFlag: Int = 1
    ) -> JobOpening {
        JobOpening(
            id: id,
            title: title,
            description: "Desc",
            company: "Corp",
            location: "NYC",
            salaryFrom: salaryFrom,
            salaryTo: salaryTo,
            employmentType: "Full-time",
            applicationDeadline: "Mon, 01/01/2024",
            qualifications: qualifications,
            contact: "000",
            category: "Mobile",
            remoteWorkFlag: remoteWorkFlag,
            openingsCount: 1,
            createdAt: "Sun, 10/15/2023",
            updatedAt: "Sun, 10/15/2023"
        )
    }
}
