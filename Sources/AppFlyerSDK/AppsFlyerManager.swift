//
//  AppыFlyerManager.swift
//
//
//  Created by AppsFlyer
//
import AppsFlyerLib
import Combine
import AppTrackingTransparency

public final class AppsFlyerManager {
    
    private let appsFlyerDelegate: AppsFlyerDelegate
    private let appsFlyerDeepLinkDelegate: AppsFlyerLybDeepLinkDelegate
    private var anyCancel: Set<AnyCancellable>
    private let parseAppsFlyerData: ParseAppsFlyerData
    
    public init() {
        self.appsFlyerDelegate = AppsFlyerDelegate()
        self.appsFlyerDeepLinkDelegate = AppsFlyerLybDeepLinkDelegate()
        self.parseAppsFlyerData = ParseAppsFlyerData()
        self.appsFlyerDelegate.parseAppsFlyerData = self.parseAppsFlyerData
        self.anyCancel = []
    }
    
   

    public var installCompletion = PassthroughSubject<Install, Never>()
    public var completionDeepLinkResult: ((DeepLinkResult) -> Void)?
    
    public func setup(appID: String, devKey: String, interval: Double = 120){
        AppsFlyerLib.shared().waitForATTUserAuthorization(timeoutInterval: interval)
        AppsFlyerLib.shared().appsFlyerDevKey     = devKey
        AppsFlyerLib.shared().appleAppID          = appID
        AppsFlyerLib.shared().delegate            = self.appsFlyerDelegate
        AppsFlyerLib.shared().deepLinkDelegate    = self.appsFlyerDeepLinkDelegate
        self.setDebag()
        AppsFlyerLib.shared().useUninstallSandbox = true
        AppsFlyerLib.shared().minTimeBetweenSessions = 10
    }
    
    public func setDebag(){
        #if DEBUG
        AppsFlyerLib.shared().isDebug = true
        #elseif RELEASE
        AppsFlyerLib.shared().isDebug = false
        #else
        AppsFlyerLib.shared().isDebug = true
        #endif
    }
    
    public func startWithDeeplink(){
        self.setCustomUserId()
        AppsFlyerLib.shared().start(completionHandler: { (dictionary, error) in
            if (error != nil){
                print(error ?? "")
                return
            } else {
                print(dictionary ?? "")
                return
            }
        })
        if let installGet = self.appsFlyerDeepLinkDelegate.installGet {
            self.installCompletion.send(installGet)
        } else {
            self.appsFlyerDeepLinkDelegate.installCompletion.sink { [weak self] install in
                guard let self = self else { return }
                self.installCompletion.send(install)
            }.store(in: &anyCancel)
        }
    }
    
    public func startRequestTrackingAuthorization(isIDFA: Bool){
        self.setCustomUserId()
        AppsFlyerLib.shared().start(completionHandler: { (dictionary, error) in
            if (error != nil){
                print(error ?? "")
                return
            } else {
                print(dictionary ?? "")
                return
            }
        })
        self.requestTrackingAuthorization(isIDFA: isIDFA)
    }
    
    private func setCustomUserId(){
        let customUserId = UserDefaults.standard.string(forKey: "customUserId")
        if(customUserId != nil && customUserId != ""){
            // Set CUID in AppsFlyer SDK for this session
            AppsFlyerLib.shared().customerUserID = customUserId
        } else {
            let customUserId = UUID().uuidString
            UserDefaults.standard.set(customUserId, forKey: "customUserId")
            AppsFlyerLib.shared().customerUserID = customUserId
        }
    }
    
    private func requestTrackingAuthorization(isIDFA: Bool) {
        if #available(iOS 14, *) {
            ATTrackingManager.requestTrackingAuthorization { [weak self] (status) in
                guard let self = self else { return }
                switch status {
                    case .denied:
                        print("AuthorizationSatus is denied")
                        self.setupIDFA(isIDFA: isIDFA)
                    case .notDetermined:
                        print("AuthorizationSatus is notDetermined")
                        self.subscribeParseData()
                    case .restricted:
                        print("AuthorizationSatus is restricted")
                        self.setupIDFA(isIDFA: isIDFA)
                    case .authorized:
                        print("AuthorizationSatus is authorized")
                        self.subscribeParseData()
                    @unknown default:
                        fatalError("Invalid authorization status")
                }
            }
        }
    }
    
    private func setupIDFA(isIDFA: Bool){
        if isIDFA {
            if let installGet = appsFlyerDelegate.parseAppsFlyerData?.installGet {
                self.installCompletion.send(installGet)
            } else {
                self.subscribeParseData()
            }
        } else {
            self.installCompletion.send(.nonOrganic([:]))
            self.parseAppsFlyerData.installGet = .nonOrganic([:])
        }
    }
    
    private func subscribeParseData(){
        appsFlyerDeepLinkDelegate.completionDeepLinkResult = completionDeepLinkResult
        self.parseAppsFlyerData.installCompletion.sink { [weak self] install in
            guard let self = self else { return }
            self.installCompletion.send(install)
        }.store(in: &anyCancel)
    }
}
