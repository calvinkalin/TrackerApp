//
//  AnalyticsService.swift
//  TrackerApp
//
//  Created by Ilya Kalin on 27.11.2024.
//

import Foundation
import YandexMobileMetrica

enum AnaliticEvent: String {
    case open = "Open"
    case close = "Close"
    case click = "Click"
}

final class AnalyticsService {
    static func activate() {
        guard let configuration = YMMYandexMetricaConfiguration(apiKey: "ccd5b7b1-4fee-4e01-8835-a3d360939050") else { return }
        
        YMMYandexMetrica.activate(with: configuration)
    }
    
    func report(event: AnaliticEvent, params : [AnyHashable : Any]) {
        YMMYandexMetrica.reportEvent(event.rawValue, parameters: params, onFailure: { error in
            print("REPORT ERROR: %@", error.localizedDescription)
        })
    }
}
