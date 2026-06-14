//
//  JobOpening.swift
//  RRNetworking
//
//  Created by Amit Sharma on 14/06/26.
//

import Foundation

public struct JobOpening: Codable, Identifiable, Hashable {
    public let id: String
    public let title: String
    public let description: String
    public let company: String
    public let location: String
    public let salaryFrom: Int
    public let salaryTo: Int
    public let employmentType: String
    public let applicationDeadline: String
    public let qualifications: String
    public let contact: String
    public let category: String
    public let remoteWorkFlag: Int
    public let openingsCount: Int
    public let createdAt: String
    public let updatedAt: String

    public init(
        id: String,
        title: String,
        description: String,
        company: String,
        location: String,
        salaryFrom: Int,
        salaryTo: Int,
        employmentType: String,
        applicationDeadline: String,
        qualifications: String,
        contact: String,
        category: String,
        remoteWorkFlag: Int,
        openingsCount: Int,
        createdAt: String,
        updatedAt: String
    ) {
        self.id = id
        self.title = title
        self.description = description
        self.company = company
        self.location = location
        self.salaryFrom = salaryFrom
        self.salaryTo = salaryTo
        self.employmentType = employmentType
        self.applicationDeadline = applicationDeadline
        self.qualifications = qualifications
        self.contact = contact
        self.category = category
        self.remoteWorkFlag = remoteWorkFlag
        self.openingsCount = openingsCount
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }

    enum CodingKeys: String, CodingKey {
        case id, title, description, company, location, contact, qualifications
        case salaryFrom = "salary_from"
        case salaryTo = "salary_to"
        case employmentType = "employment_type"
        case applicationDeadline = "application_deadline"
        case category = "job_category"
        case remoteWorkFlag = "is_remote_work"
        case openingsCount = "number_of_opening"
        case createdAt = "created_at"
        case updatedAt = "updated_at"
    }

    public var isRemote: Bool { remoteWorkFlag == 1 }

    public var formattedSalary: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        let from = formatter.string(from: NSNumber(value: salaryFrom)) ?? "$\(salaryFrom)"
        let to = formatter.string(from: NSNumber(value: salaryTo)) ?? "$\(salaryTo)"
        return "\(from) – \(to)"
    }

    public var parsedQualifications: [String] {
        let cleaned = qualifications
            .trimmingCharacters(in: .whitespaces)
            .replacingOccurrences(of: "[", with: "")
            .replacingOccurrences(of: "]", with: "")

        return cleaned
            .components(separatedBy: ",")
            .map { $0.trimmingCharacters(in: CharacterSet(charactersIn: "\" ")) }
            .filter { !$0.isEmpty }
    }

    public static func == (lhs: JobOpening, rhs: JobOpening) -> Bool {
        lhs.id == rhs.id
    }

    public func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
}
