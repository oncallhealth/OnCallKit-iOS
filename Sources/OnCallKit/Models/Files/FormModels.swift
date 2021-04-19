//
//  FormModels.swift
//  OnCall Health iOS
//
//  Created by Domenic Bianchi on 2020-07-07.
//  Copyright © 2020 OnCall Health. All rights reserved.
//

import Foundation

// MARK: - FormPage

struct FormPage: Codable {
    
    // MARK: Internal
    
    let count: Int
    let next: String?
    let results: [Form]
}

// MARK: - Form

struct Form: Codable {
    
    // MARK: CodingKeys
    
    private enum CodingKeys: String, CodingKey {
        case id, url, form, title, createdAt, participantName, response
    }
    
    // MARK: Lifecycle
    
    private init(
        id: Int,
        url: String?,
        form: String,
        title: String,
        createdAt: Date?,
        participantName: String?,
        response: [String?]?)
    {
        self.id = id
        self.url = url
        self.form = form
        self.title = title
        self.createdAt = createdAt
        self.participantName = participantName
        self.response = response
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let dateString = try container.decodeIfPresent(String.self, forKey: .createdAt)
        
        let url = try container.decodeIfPresent(String.self, forKey: .url)
        
        var form: String = ""
        
        if url == nil {
            form = try container.decode(String.self, forKey: .form)
        }
        
        let id = try container.decode(Int.self, forKey: .id)
        let title = try container.decode(String.self, forKey: .title)
        let participantName = try container.decodeIfPresent(String.self, forKey: .participantName)
        let response = try? container.decode([String?].self, forKey: .response)
        
        guard let unwrappedDateString = dateString else {
            self.init(
                id: id,
                url: url,
                form: form,
                title: title,
                createdAt: nil,
                participantName: participantName,
                response: response)
            return
        }
        
        guard let date = Date(fromString: unwrappedDateString) else {
            throw DecodingError.typeMismatch(
                Date.self,
                DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Date string not valid"))
        }
        
        self.init(
            id: id,
            url: url,
            form: form,
            title: title,
            createdAt: date,
            participantName: participantName,
            response: response)
    }
    
    // MARK: Internal
    
    let id: Int
    let title: String
    let createdAt: Date?
    let participantName: String?
    let response: [String?]?
    
    var formUrl: String {
        return url ?? form
    }
    
    // MARK: Private
    
    private let url: String?
    private let form: String
    
}
