//
//  NYCHighSchool.swift
//  NYCSchools
//
//  Created by Ayush Kadakia on 6/28/23.
//

import Foundation

struct NYCHighSchool: Codable {
    let dbn: String?
    let school_name: String?
    let overview_paragraph: String?
    var sat: SATResults?
    let location: String?
    let phone_number: String?
    let school_email: String?
    let latitude: String?
    let longitude: String?
}
