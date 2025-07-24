//
//  TemplatesEndpoint.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 11.07.2025.
//

import Foundation

enum GetTemplatesEndpoint {
    case getTemplates(appID: String)
}

extension GetTemplatesEndpoint: NetworkRequest {
    
    typealias Response = TemplateResponseDTO
    
    var endpoint: String {
        switch self {
        case .getTemplates(let addID):
            return "/pixverse/api/v1/get_templates/\(addID)"
        }
    }
    
    var method: HTTPMethod { .GET }
    
    var headers: [String: String]? {
        ["accept": "application/json"]
    }
    
    var parameters: [String: Any]? { nil }
}
