//
//  AppsFlyerLybDeepLinkDelegate.swift
//
//
//  Created by AppsFlyer
//
import Combine
import AppsFlyerLib
import Foundation

final public class AppsFlyerLybDeepLinkDelegate: NSObject, DeepLinkDelegate {
    
    public var installCompletion = PassthroughSubject<Install, Never>()
    public var installGet: Install?
    public var completionDeepLinkResult: ((DeepLinkResult) -> Void)?
    
    public func didResolveDeepLink(_ result: DeepLinkResult) {
        completionDeepLinkResult?(result)
        switch result.status {
            case .notFound:
                self.installGet = .organic
                self.installCompletion.send(.organic)
                print("[AFSDK] Deep link not found")
                return
            case .failure:
                self.installGet = .organic
                self.installCompletion.send(.organic)
                print("Error %@", result.error!)
                return
            case .found:
                guard let deepLink: DeepLink = result.deepLink else {
                    self.installGet = .organic
                    self.installCompletion.send(.organic)
                    print("[AFSDK] Could not extract deep link object")
                    return
                }
                let conversionInfo = self.parse(with: deepLink)
                let parameters = self.createParameters(conversionInfo: conversionInfo)
                self.installCompletion.send(.nonOrganic(parameters))
                self.installGet = .nonOrganic(parameters)
            default:
                self.installGet = .organic
                self.installCompletion.send(.organic)
                return
        }
    }
    
    private func parse(with deepLink: DeepLink) -> [AnyHashable : Any] {
        guard let deeplinkValue = deepLink.deeplinkValue as? NSString else {
            return [:]
        }
        let urlParameters = deeplinkValue.components(separatedBy: "?")
        let parameters = urlParameters.last?.components(separatedBy: "&")
        var dictionaryParameters: [AnyHashable: Any] = [:]
        
        parameters?.forEach({ element in
            if let value = element.components(separatedBy: "=").last,
               let key = element.components(separatedBy: "=").first {
                dictionaryParameters.updateValue(value, forKey: key)
            }
        })
        return dictionaryParameters
    }
    
    private func createParameters(conversionInfo: [AnyHashable : Any]) -> [String: String] {
        var parameters: [String: String] = [:]
        conversionInfo.forEach({ key, value in
//            if let key = key as? String, let value = value as? String, let keyCreate = Key(rawValue: key) {
//                let keyParameter = getAnalog(key: keyCreate)
//                let valueParameter = value
//                parameters.updateValue(valueParameter, forKey: keyParameter)
//            }
            if let valueParameter = value as? String, let keyParameter = key as? String {
                parameters.updateValue(valueParameter, forKey: keyParameter)
            }
        })
        
        return parameters
    }
    
    private func getAnalog(key: Key) -> String {
        switch key {
            case .pid:
                return Analog.utmSource.rawValue
            case .source:
                return Analog.utmMedium.rawValue
            case .qtag:
                return Analog.utmContent.rawValue
            case .click_id:
                return Analog.utmTerm.rawValue
            case .af_channel:
                return Analog.utmMedium.rawValue
            case .c:
                return Analog.utmCampaign.rawValue
            case .af_adset:
                return Analog.utmContent.rawValue
            case .af_ad:
                return Analog.utmTerm.rawValue
                
            case .app_type:
                return Analog.appType.rawValue
            case .mb_uuid:
                return ""
            case .a_ssid:
                return ""
        }
    }
}
