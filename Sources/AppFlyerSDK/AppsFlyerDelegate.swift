//
//  AppsFlyerDelegate.swift
//  
//
//  Created by AppsFlyer
//
import AppsFlyerLib
import Foundation

final public class AppsFlyerDelegate: NSObject, AppsFlyerLibDelegate {
    
    var parseAppsFlyerData: ParseAppsFlyerData?
    
    public var urlParameters: (([String: String]?) -> Void)?
    
    public func onConversionDataSuccess(_ conversionInfo: [AnyHashable : Any]) {
        self.parseAppsFlyerData?.parseCampaign(conversionInfo)
    }
    
    public func onConversionDataFail(_ error: Error) {
        self.parseAppsFlyerData?.parseCampaign([:])
        print("Error server data: class: AppsFlyerGetData ->, function: onConversionDataFail -> data: onConversionDataSuccess ->, description: ", error.localizedDescription)
    }
    
    public func onAppOpenAttribution(_ attributionData: [AnyHashable : Any]) {
        self.parseAppsFlyerData?.parseCampaign(attributionData)
    }
    
    public func onAppOpenAttributionFailure(_ error: Error) {
        print(error)
        self.parseAppsFlyerData?.parseCampaign([:])
    }
    
    override init(){}
}
