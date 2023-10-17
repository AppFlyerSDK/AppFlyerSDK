//
//  Models.swift
//  
//
//  Created by AppsFlyer
//

import Foundation

public enum Install {
    case organic
    case nonOrganic([String: String]?)
}

public enum AfStatus: String {
    case organic = "Organic"
    case nonOrganic = "Non-organic"
    case none
}

public enum Key: String {
    case pid
    case af_channel
    case c
    case af_adset
    case af_ad
    case click_id
    case qtag
    case source
    
    case app_type
    case mb_uuid
    case a_ssid
}

public enum Analog: String {
    case utmSource = "utm_source"
    case utmMedium = "utm_medium"
    case utmCampaign = "utm_campaign"
    case utmContent = "utm_content"
    case utmTerm = "utm_term"
    
    case appType = "1"
    case mbUuid = "mb_uuid"
    case aSsid = "a_ssid"
}
