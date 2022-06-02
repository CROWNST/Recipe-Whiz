//
//  SpoonacularClient.swift
//  TinyChef
//
//  Created by David Hsieh on 1/5/22.
//

import Foundation

class SpoonacularClient {
    static let headers = [
        "x-rapidapi-host": "spoonacular-recipe-food-nutrition-v1.p.rapidapi.com",
        "x-rapidapi-key": "17e63f929fmshe1a35e8a5e7de1ep1b9c56jsn6535997c003a"
    ]
    
    enum Endpoints {
        static let searchHost = "https://\(headers["x-rapidapi-host"]!)/"
        static var imageHost = "https://spoonacular.com/recipeImages/"
        
        case autocompleteRecipe(query: String, number: Int)
        case autocompleteIngredient(query: String, number: Int)
        case searchRecipeComplex(query: String?, includeIngredients: String?, ranking: Int)
        case searchRecipe(query: String, instructionsRequired: Bool, number: Int)
        case getSteps(id: Int, stepBreakdown: Bool)
        case image(String)
        
        var stringValue: String {
            switch self {
            case .autocompleteRecipe(let query, let number):
                return Endpoints.searchHost + "recipes/autocomplete?query=\(query)&number=\(number)"
            case .autocompleteIngredient(let query, let number):
                return Endpoints.searchHost + "food/ingredients/autocomplete?query=\(query)&number=\(number)"
            case .searchRecipeComplex(let query, let includeIngredients, let ranking):
                var result = Endpoints.searchHost + "recipes/searchComplex?limitLicense=true&offset=0&number=100&instructionsRequired=true"
                if ranking == 0 {
                    result += "&addRecipeInformation=true&fillIngredients=true"
                } else {
                    result += "&ranking=\(ranking)&addRecipeInformation=true&fillIngredients=true"
                }
                if query != nil {
                    result += "&query=\(query!)"
                }
                if includeIngredients != nil {
                    result += "&includeIngredients=\(includeIngredients!)"
                }
                return result
            case .searchRecipe(let query, let instructionsRequired, let number):
                return Endpoints.searchHost + "recipes/search?query=\(query)&instructionsRequired=\(instructionsRequired)&number=\(number)"
            case .getSteps(let id, let stepBreakdown):
                return Endpoints.searchHost + "recipes/\(id)/analyzedInstructions?stepBreakdown=\(stepBreakdown)"
            case .image(let imagePath):
                return imagePath
            }
        }
        
        var url: URL {
            let urlString = stringValue.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
            return URL(string: urlString!)!
        }
    }
    
    class func autocompleteRecipe(query: String, number: Int, completion: @escaping ([AutocompleteRecipe], Error?) -> Void) -> URLSessionDataTask {
        let task = taskForGETRequest(url: Endpoints.autocompleteRecipe(query: query, number: number).url, responseType: [AutocompleteRecipe].self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion([], error)
            }
        }
        return task
    }
    
    class func autocompleteIngredient(query: String, number: Int, completion: @escaping ([AutocompleteIngredient], Error?) -> Void) -> URLSessionDataTask {
        let task = taskForGETRequest(url: Endpoints.autocompleteIngredient(query: query, number: number).url, responseType: [AutocompleteIngredient].self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion([], error)
            }
        }
        return task
    }
    
    class func searchRecipeComplex(query: String?, includeIngredients: String?, ranking: Int, completion: @escaping (([SearchRecipeComplex], Error?) -> Void)) -> URLSessionDataTask {
        let task = taskForGETRequest(url: Endpoints.searchRecipeComplex(query: query, includeIngredients: includeIngredients, ranking: ranking).url, responseType: SearchRecipeComplexResponse.self) { response, error in
            if let response = response {
                completion(response.results, nil)
            } else {
                completion([], error)
            }
        }
        return task
    }
    
    class func searchRecipe(query: String, instructionsRequired: Bool, number: Int, completion: @escaping ((SearchRecipeResponse?, Error?) -> Void)) -> URLSessionDataTask {
        let task = taskForGETRequest(url: Endpoints.searchRecipe(query: query, instructionsRequired: instructionsRequired, number: number).url, responseType: SearchRecipeResponse.self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion(nil, error)
            }
        }
        return task
    }
    
    class func getSteps(id: Int, stepBreakdown: Bool, completion: @escaping (([StepsSection], Error?) -> Void)) -> URLSessionDataTask {
        let task = taskForGETRequest(url: Endpoints.getSteps(id: id, stepBreakdown: stepBreakdown).url, responseType: [StepsSection].self) { response, error in
            if let response = response {
                completion(response, nil)
            } else {
                completion([], error)
            }
        }
        return task
    }
    
    class func downloadImage(path: String, position: Int, completion: @escaping (Data?, Error?, Int) -> Void) -> URLSessionDataTask {
        let request = NSMutableURLRequest(url: Endpoints.image(path).url)
        request.timeoutInterval = 15
        let task = URLSession.shared.dataTask(with: request as URLRequest) { data, response, error in
            DispatchQueue.main.async {
                completion(data, error, position)
            }
        }
        task.resume()
        return task
    }
    
    class func taskForGETRequest<ResponseType: Decodable>(url: URL, responseType: ResponseType.Type, completion: @escaping (ResponseType?, Error?) -> Void) -> URLSessionDataTask {
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        request.allHTTPHeaderFields = headers
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            guard let data = data else {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
                return
            }
            print("JSON data: \(String(data: data, encoding: String.Encoding.utf8)!)")
            let decoder = JSONDecoder()
            do {
                let responseObject = try decoder.decode(ResponseType.self, from: data)
                DispatchQueue.main.async {
                    completion(responseObject, nil)
                }
            } catch {
                DispatchQueue.main.async {
                    completion(nil, error)
                }
            }
        }
        task.resume()
        
        return task
    }
}
