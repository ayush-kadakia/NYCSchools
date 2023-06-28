//
//  APICaller.swift
//  NYCSchools
//
//  Created by Ayush Kadakia on 6/28/23.
//

import Foundation
import Alamofire

struct Constants {
    static let highSchoolURL = "https://data.cityofnewyork.us/resource/s3k6-pzi2.json"
    static let satURL = "https://data.cityofnewyork.us/resource/f9bf-2cp4.json"
    
}

enum APIError: Error {
    case failedTogetData
}

class APICaller {
    ///singleton design pattern for APIs
    static let shared = APICaller()
    
    ///fetch the high schools in nyc
    func fetchNYCHighSchoolInformation(completion: @escaping (Result<[NYCHighSchool], Error>) -> Void){
        guard let highSchoolsURL = URL(string: Constants.highSchoolURL) else { return }

        let task = URLSession.shared.dataTask(with: highSchoolsURL) { data, response, error in
            if let error = error {
                print(error)
                completion(.failure(APIError.failedTogetData))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.failedTogetData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let results = try decoder.decode([NYCHighSchool].self, from: data)
                completion(.success(results))
            } catch {
                print(error)
                completion(.failure(APIError.failedTogetData))
            }
        }

        task.resume()
    }
    
    ///fetch the sat info for each school
    func updateNYCHighSchoolWithSATInformation(schools: [NYCHighSchool], completion: @escaping (Result<[NYCHighSchool], Error>) -> Void){
        guard let highSchoolsURL = URL(string: Constants.satURL) else { return }

        let task = URLSession.shared.dataTask(with: highSchoolsURL) { data, response, error in
            if let error = error {
                print(error)
                completion(.failure(APIError.failedTogetData))
                return
            }
            
            guard let data = data else {
                completion(.failure(APIError.failedTogetData))
                return
            }
            
            do {
                let decoder = JSONDecoder()
                let results = try decoder.decode([SATResults].self, from: data)
                
                var schoolsWithSAT: [NYCHighSchool] = []
                for school in schools {
                    if let score = results.first(where: { $0.dbn == school.dbn }) {
                        schoolsWithSAT.append(NYCHighSchool(
                            dbn: school.dbn,
                            school_name: school.school_name,
                            overview_paragraph: school.overview_paragraph,
                            sat: score,
                            location: school.location,
                            phone_number: school.phone_number,
                            school_email: school.school_email,
                            latitude: school.latitude,
                            longitude: school.longitude
                        ))
                    }
                }
                
                completion(.success(schoolsWithSAT))
            } catch {
                print(error)
                completion(.failure(APIError.failedTogetData))
            }
        }

        task.resume()
    }
    
}
