//
//  SettingsViewModel.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import SwiftUI
import MessageUI
import NotificationCenter

final class SettingsViewModel: ObservableObject {
    
    @EnvironmentObject var appState: AppState

    @Published private(set) var appVersion: String = "1.0.0"
    @Published var showNotificationPermission = false
    @Published var selectedURL: AppURL?
    @Published var showMailComposer = false
    @Published var mailComposeResult: Result<MFMailComposeResult, Error>? = nil
    @Published var isNotificationToggleOn = false
    
    private let notificationCenter: UNUserNotificationCenter
    private var initialLoad = true

    var canSendEmail: Bool {
        MFMailComposeViewController.canSendMail()
    }
    
    
    init(
        notificationCenter: UNUserNotificationCenter = .current()
    ) {
        self.notificationCenter = notificationCenter
        loadAppVersion()
        checkNotificationStatus()
    }
    
    func requestNotificationPermission() {
        Task {
            do {
                let granted = try await notificationCenter.requestAuthorization(
                    options: [.alert, .sound, .badge]
                )
                await MainActor.run {
                    isNotificationToggleOn = granted
                }
                return
            } catch {
                print("Notification permission error: \(error.localizedDescription)")
                isNotificationToggleOn = false
                return
            }
        }
    }
    
    func checkNotificationStatus() {
        Task {
            let settings = await notificationCenter.notificationSettings()
            await MainActor.run {
                isNotificationToggleOn = settings.authorizationStatus == .authorized
                initialLoad = false
            }
        }
    }
    
    func toggleNotifications(newValue: Bool) {
        if initialLoad { return }
        
        if newValue {
            showNotificationPermission = true
        } else {
            disableNotifications()
        }
    }
        
    func disableNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        isNotificationToggleOn = false
        print("Notifications disabled")
    }
    
    func getEmailURL() -> URL? {
        let subject = "Pixverse Support"
        let body = """
            User ID: \(appState.userId)
            
            Please describe your issue below:
            """
        
        let encodedSubject = subject.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let encodedBody = body.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        
        return URL(string: "mailto:test@email.com?subject=\(encodedSubject)&body=\(encodedBody)")
    }
    
    private func loadAppVersion() {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            appVersion = version
        }
    }
}
