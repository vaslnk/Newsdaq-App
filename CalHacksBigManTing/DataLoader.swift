//
//  DataLoader.swift
//  CalHacksBigManTing
//
//  Created by Yevgeniy Vasylenko on 10/8/17.
//  Copyright © 2017 Jack Vasylenko. All rights reserved.
//

import UIKit
import Alamofire

func getArticlesData(stock: String, completionHandler: @escaping (Data?, Error?) -> Void) {
    let urlTo = URL.init(string: "http://52.175.246.51:5000/articles")!
    var parameters = [String:String]()
    parameters["tickers"] = stock
    parameters["start"] = "NOW-1YEAR"
    parameters["end"] = "NOW"
    Alamofire.request(urlTo, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseData(completionHandler: {response in
        if let data = response.data {
            completionHandler(data, nil)
        }
        else {
            completionHandler(nil, response.error)
            print(response)
        }
    })
}

func getStocksData(stock: String, completionHandler: @escaping (Data?, Error?) -> Void) {
    let urlTo = "http://52.175.234.174:5000/stock"
    var parameters = [String:String]()
    parameters["tickers"] = stock
    parameters["start"] = "20161101"
    parameters["end"] = "20171008"
    Alamofire.request(urlTo, method: .get, parameters: nil, encoding: URLEncoding.default, headers: nil).responseData(completionHandler: {response in
        if let data = response.data {
            completionHandler(data, nil)
        }
        else {
            completionHandler(nil, response.error)
            print(response)
        }
    })
}

func getappleData(stock: String, completionHandler: @escaping (Data?, Error?) -> Void) {
    Alamofire.request("http://52.175.234.174:5000/stock?tickers=\(stock)&start=20161008&end=20171007").responseData(completionHandler: {response in
        if let data = response.data {
            completionHandler(data, nil)
        }
        else {
            completionHandler(nil, response.error)
            print(response)
        }
    })
}

func getAppleArticles(stock: String, completionHandler: @escaping (Data?, Error?) -> Void) {
    Alamofire.request("http://52.175.246.51:5000/articles?tickers=\(stock)&start=NOW-1YEAR&end=NOW").responseData(completionHandler: {response in
        if let data = response.data {
            completionHandler(data, nil)
        }
        else {
            completionHandler(nil, response.error)
            print(response)
        }
    })
}

