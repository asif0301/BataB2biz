//
//  NetworkManager.swift
//  BataB2Biz
//
//  Created by Skynet Solutionz on 06/10/2026.
//

import Foundation

struct APIError: LocalizedError {
    let message: String

    var errorDescription: String? { message }
}

struct MultipartFile {
    let fieldName: String
    let fileName: String
    let mimeType: String
    let data: Data
}

final class NetworkManager {
    static let shared = NetworkManager()
    private let session: URLSession

    init(session: URLSession = .shared) {
        self.session = session
    }

    func post<Response: Decodable, Body: Encodable>(
        _ body: Body,
        to endpoint: String,
        accessToken: String? = nil
    ) async throws -> Response {
        let url = APIService.baseURL.appendingPathComponent(endpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        let encoder = JSONEncoder()
        request.httpBody = try encoder.encode(body)

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError(message: "The server returned an invalid response.")
            }

            #if DEBUG
            print("📡 API RESPONSE [\(httpResponse.statusCode)] \(request.url?.absoluteString ?? endpoint)")
            if let jsonObject = try? JSONSerialization.jsonObject(with: data),
               let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
               let prettyJSON = String(data: prettyData, encoding: .utf8) {
                print(prettyJSON)
            } else if let rawResponse = String(data: data, encoding: .utf8) {
                print(rawResponse)
            }
            #endif

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError(message: errorMessage(from: data) ?? "Login failed. Please try again.")
            }

            do {
                return try JSONDecoder().decode(Response.self, from: data)
            } catch {
                throw APIError(message: "The server response could not be read.")
            }
        } catch let error as APIError {
            throw error
        } catch is URLError {
            throw APIError(message: "Unable to connect. Please check your internet connection.")
        } catch {
            throw APIError(message: error.localizedDescription)
        }
    }

    func get<Response: Decodable>(
        _ endpoint: String,
        queryItems: [URLQueryItem] = [],
        accessToken: String? = nil
    ) async throws -> Response {
        var components = URLComponents(
            url: APIService.baseURL.appendingPathComponent(endpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/"))),
            resolvingAgainstBaseURL: false
        )!
        components.queryItems = queryItems

        var request = URLRequest(url: components.url!)
        request.httpMethod = "GET"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let accessToken {
            request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization")
        }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError(message: "The server returned an invalid response.")
            }
            printDebugResponse(data: data, response: httpResponse, endpoint: endpoint)

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError(message: errorMessage(from: data) ?? "Home data could not be loaded.")
            }

            do {
                return try JSONDecoder().decode(Response.self, from: data)
            } catch {
                throw APIError(message: "The home response could not be read.")
            }
        } catch let error as APIError {
            throw error
        } catch is URLError {
            throw APIError(message: "Unable to connect. Please check your internet connection.")
        } catch {
            throw APIError(message: error.localizedDescription)
        }
    }

    func delete<Response: Decodable>(
        _ endpoint: String,
        accessToken: String? = nil
    ) async throws -> Response {
        let url = APIService.baseURL.appendingPathComponent(endpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        var request = URLRequest(url: url)
        request.httpMethod = "DELETE"
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        if let accessToken { request.setValue("Bearer \(accessToken)", forHTTPHeaderField: "Authorization") }

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else { throw APIError(message: "The server returned an invalid response.") }
            printDebugResponse(data: data, response: httpResponse, endpoint: endpoint)
            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError(message: errorMessage(from: data) ?? "The request could not be completed.")
            }
            return try JSONDecoder().decode(Response.self, from: data)
        } catch let error as APIError {
            throw error
        } catch is URLError {
            throw APIError(message: "Unable to connect. Please check your internet connection.")
        } catch {
            throw APIError(message: error.localizedDescription)
        }
    }

    func postMultipart<Response: Decodable>(
        fields: [String: String],
        files: [MultipartFile],
        to endpoint: String
    ) async throws -> Response {
        let url = APIService.baseURL.appendingPathComponent(endpoint.trimmingCharacters(in: CharacterSet(charactersIn: "/")))
        let boundary = "Boundary-\(UUID().uuidString)"
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")

        var body = Data()
        for (name, value) in fields {
            body.appendUTF8("--\(boundary)\r\n")
            body.appendUTF8("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n")
            body.appendUTF8("\(value)\r\n")
        }
        for file in files {
            body.appendUTF8("--\(boundary)\r\n")
            body.appendUTF8("Content-Disposition: form-data; name=\"\(file.fieldName)\"; filename=\"\(file.fileName)\"\r\n")
            body.appendUTF8("Content-Type: \(file.mimeType)\r\n\r\n")
            body.append(file.data)
            body.appendUTF8("\r\n")
        }
        body.appendUTF8("--\(boundary)--\r\n")
        request.httpBody = body

        do {
            let (data, response) = try await session.data(for: request)
            guard let httpResponse = response as? HTTPURLResponse else {
                throw APIError(message: "The server returned an invalid response.")
            }
            printDebugResponse(data: data, response: httpResponse, endpoint: endpoint)

            guard (200...299).contains(httpResponse.statusCode) else {
                throw APIError(message: errorMessage(from: data) ?? "Registration failed. Please try again.")
            }

            do {
                return try JSONDecoder().decode(Response.self, from: data)
            } catch {
                throw APIError(message: "The server response could not be read.")
            }
        } catch let error as APIError {
            throw error
        } catch is URLError {
            throw APIError(message: "Unable to connect. Please check your internet connection.")
        } catch {
            throw APIError(message: error.localizedDescription)
        }
    }

    private func printDebugResponse(data: Data, response: HTTPURLResponse, endpoint: String) {
        #if DEBUG
        print("📡 API RESPONSE [\(response.statusCode)] \(response.url?.absoluteString ?? endpoint)")
        if let jsonObject = try? JSONSerialization.jsonObject(with: data),
           let prettyData = try? JSONSerialization.data(withJSONObject: jsonObject, options: [.prettyPrinted, .sortedKeys]),
           let prettyJSON = String(data: prettyData, encoding: .utf8) {
            print(prettyJSON)
        } else if let rawResponse = String(data: data, encoding: .utf8) {
            print(rawResponse)
        }
        #endif
    }

    private func errorMessage(from data: Data) -> String? {
        guard let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else { return nil }
        return json["message"] as? String
    }
}

private extension Data {
    mutating func appendUTF8(_ value: String) {
        append(value.data(using: .utf8)!)
    }
}
