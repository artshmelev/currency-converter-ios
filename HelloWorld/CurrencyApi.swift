//
//  CurrencyApi.swift
//  HelloWorld
//
//  Created by Artem Shmelev on 04.04.2024.
//

import Foundation
import os

enum Currency: String, CaseIterable, Identifiable {
    case CNY, EUR, GBP, THB, TRY, USD
    var id: Self { self }
}

func GetCurrencyIcon(_ currency: Currency) -> String {
    switch currency {
    case .CNY:
        return "chineseyuanrenminbisign"
    case .EUR:
        return "eurosign"
    case .GBP:
        return "sterlingsign"
    case .THB:
        return "bahtsign"
    case .TRY:
        return "turkishlirasign"
    case .USD:
        return "dollarsign"
    }
}

struct Rates: Codable {
    let CNY: Double?
    let EUR: Double?
    let GBP: Double?
    let THB: Double?
    let TRY: Double?
    let USD: Double?
}

struct CurrencyResponse: Codable {
    let amount: Double
    let base: String
    let date: String
    let rates: Rates
}

class CurrencyApi {
    func convert(
        inputCurrency: Currency,
        inputAmount: String,
        outputCurrency: Currency,
        completion:@escaping (Double) -> ()
    ) {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "api.frankfurter.app"
        components.path = "/latest"
        components.queryItems = [
            URLQueryItem(name: "amount", value: inputAmount),
            URLQueryItem(name: "from", value: inputCurrency.rawValue),
            URLQueryItem(name: "to", value: outputCurrency.rawValue)
        ]
        guard let url = components.url else {
            return
        }
        let request = URLRequest(url: url)
        
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if let error = error {
                Logger().error("\(error.localizedDescription)")
                return
            }
            
            let statusCode = (response as! HTTPURLResponse).statusCode
            if statusCode != 200 {
                Logger().error("statusCode = \(statusCode)")
                return
            }
            
            guard let data = data else {
                Logger().error("empty data")
                return
            }
            let currencyResponse = try? JSONDecoder().decode(CurrencyResponse.self, from: data)
            guard let currencyResponse = currencyResponse else {
                Logger().error("cannot decode json")
                return
            }
            
            var result: Double?
            switch outputCurrency {
            case .CNY:
                result = currencyResponse.rates.CNY
            case .EUR:
                result = currencyResponse.rates.EUR
            case .GBP:
                result = currencyResponse.rates.GBP
            case .THB:
                result = currencyResponse.rates.THB
            case .TRY:
                result = currencyResponse.rates.TRY
            case .USD:
                result = currencyResponse.rates.USD
            }
            
            if let result = result {
                DispatchQueue.main.async {
                    completion(result)
                }
            }
        }
        .resume()
    }
}
