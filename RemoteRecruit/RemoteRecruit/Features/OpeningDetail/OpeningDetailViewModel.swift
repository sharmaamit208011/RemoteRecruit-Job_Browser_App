//
//  OpeningDetailViewModel.swift
//  RemoteRecruit
//
//  Created by Amit Sharma on 14/06/26.
//

import Foundation
import RRNetworking

@MainActor
final class OpeningDetailViewModel: ObservableObject {
    let opening: JobOpening

    init(opening: JobOpening) {
        self.opening = opening
    }

    var displayQualifications: [String] {
        opening.parsedQualifications
    }

    var openingsText: String {
        opening.openingsCount == 1 ? "1 Opening" : "\(opening.openingsCount) Openings"
    }

    var employmentBadgeColor: String {
        switch opening.employmentType.lowercased() {
        case let s where s.contains("full"): return "FullTimeBadge"
        case let s where s.contains("part"): return "PartTimeBadge"
        case let s where s.contains("contract"): return "ContractBadge"
        case let s where s.contains("freelance"): return "FreelanceBadge"
        default: return "DefaultBadge"
        }
    }
}
