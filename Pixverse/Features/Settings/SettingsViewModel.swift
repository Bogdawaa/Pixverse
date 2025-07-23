//
//  SettingsViewModel.swift
//  Pixverse
//
//  Created by Bogdan Fartdinov on 22.07.2025.
//

import SwiftUI
import MessageUI

final class SettingsViewModel: ObservableObject {
    
    @EnvironmentObject var appState: AppState

    @Published var showNotificationPermission = false
    @Published var isToggleOn = false
    @Published private(set) var appVersion: String = "1.0.0"
    @Published var selectedURL: AppURL?
    
    @Published var showMailComposer = false
    @Published var mailComposeResult: Result<MFMailComposeResult, Error>? = nil
    
    
    private let notificationCenter: UNUserNotificationCenter

    var canSendEmail: Bool {
        MFMailComposeViewController.canSendMail()
    }
    
    
    init(
        notificationCenter: UNUserNotificationCenter = .current()
    ) {
        self.notificationCenter = notificationCenter
    }
    
    func requestNotificationPermission() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(
                options: [.alert, .sound, .badge]
            )
            await MainActor.run {
                self.showNotificationPermission = false
            }
            return granted
        } catch {
            print("Notification permission error: \(error.localizedDescription)")
            return false
        }
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
}
