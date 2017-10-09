//
//  JsonParser.swift
//  CalHacksBigManTing
//
//  Created by Yevgeniy Vasylenko on 10/8/17.
//  Copyright © 2017 Jack Vasylenko. All rights reserved.
//

import UIKit

struct Stock: Codable {
    var Close: Double
    var LastSale: Double
    var Symbol: String
    var Open: Double
    var Volume: Int
    var High: Double
    var Low: Double
    var DateStamp: String
}

struct Article: Codable {
    var title: String
    var bodyPolarity: String
    var date: String
    var bodyPolarityScore: Double
    var titlePolarity: String
    var titlePolarityScore: Double
    var URL: String
}

func getTestJsonData() -> Data? {
    if let path = Bundle.main.path(forResource: "test2", ofType: "json") {
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .alwaysMapped)
            return data
        } catch let error {
            print(error.localizedDescription)
            return nil
        }
    } else {
        print("Invalid filename/path.")
        return nil
    }
}

func parseStockJson(data: Data, completionHandler: @escaping ([Stock]?, Error?) -> Void) {
    do {
        let stockDates = try JSONDecoder().decode([Stock].self, from: data)
        completionHandler(stockDates, nil)
    }
    catch {
        print(error)
        completionHandler(nil, error)
    }
}

func parseArticlesJson(data: Data, completionHandler: @escaping ([Article]?, Error?) -> Void) {
    do {
        let stockDates = try JSONDecoder().decode([Article].self, from: data)
        completionHandler(stockDates, nil)
    }
    catch {
        print(error)
        completionHandler(nil, error)
    }
}



