//
//  AppView.swift
//  AlpineConnect
//
//  Created by Jenya Lebid on 10/14/22.
//

import SwiftUI
import AlpineUI

public struct AppView<App: View>: View {
    
    @ObservedObject var control = AppControl.shared
    
    @Environment(\.horizontalSizeClass) var hSizeClass
    
    var app: App
    
    public init(@ViewBuilder app: () -> App) {
        self.app = app()
    }
    
    public var body: some View {
        app
            .onAppear {
                UIApplication.shared.addTapGestureRecognizer()
            }
            .popup(isPresented: $control.showSecondaryPopup, alignment: control.currentSecondaryPopup.alignment, direction: control.currentSecondaryPopup.direction) {
                control.currentSecondaryPopup.content
            }
            .overlay {
                if control.dimView {
                    dim
                }
            }
            .popup(isPresented: $control.showPopup, alignment: control.currentPopup.alignment, direction: control.currentPopup.direction) {
                control.currentPopup.content
            }
            .appAlert(isPresented: $control.showRegularAlert, alert: control.currentAlert)
            .sheet(isPresented: $control.showSheet) {
                control.currentSheet
                    .overlay {
                        if control.sheetDimView {
                            Color(uiColor: .black)
                                .opacity(0.4)
                                .ignoresSafeArea()
                        }
                    }
                    .appAlert(isPresented: $control.showSheetAlert, alert: control.currentAlert)
            }
            .fullScreenCover(isPresented: $control.showCover, content: {
                control.currentCover
                    .popup(isPresented: $control.showSecondaryPopup, alignment: .bottom, direction: .bottomTrailing) {
                        control.currentSecondaryPopup.content
                    }
            })
            .ignoresSafeArea()
    }
    
    var dim: some View {
        Color(uiColor: .black)
            .opacity(0.4)
            .ignoresSafeArea()
    }
}

extension UIApplication {
    func addTapGestureRecognizer() {
        guard let window = (connectedScenes.first as? UIWindowScene)?.windows.first else { return }
        let tapGesture = TapGestureRecognizer(target: window, action: #selector(UIView.endEditing))
        tapGesture.requiresExclusiveTouchType = false
        tapGesture.cancelsTouchesInView = false
        tapGesture.delegate = self
        window.addGestureRecognizer(tapGesture)
    }
}

extension UIApplication: UIGestureRecognizerDelegate {
    public func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true // set to `false` if you don't want to detect tap during other gestures
    }
}

class TapGestureRecognizer: UITapGestureRecognizer {
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touch = touches.first, touch.tapCount == 1 {
            super.touchesBegan(touches, with: event)
        } else {
            state = .cancelled
        }
    }

    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }

    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent) {
        if let touch = touches.first, touch.tapCount == 1 {
            super.touchesEnded(touches, with: event)
        } else {
            state = .cancelled
        }
    }

    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
        state = .cancelled
    }
}

//class AnyGestureRecognizer: UIGestureRecognizer {
//    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent) {
//        guard let touch = touches.first, touch.tapCount == 1 else {
//            state = .cancelled
//            return
//        }
//
//        if let touchedView = touches.first?.view, touchedView is UIControl {
//            state = .cancelled
//
//        } else if let touchedView = touches.first?.view as? UITextView, touchedView.isEditable {
//            state = .cancelled
//
//        } else {
//            state = .began
//        }
//    }
//
//    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
//        state = .ended
//    }
//
//    override func touchesCancelled(_ touches: Set<UITouch>, with event: UIEvent) {
//        state = .cancelled
//    }
//}

//extension View {
//    
//    @ViewBuilder func `if` <Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
//        if condition {
//            transform(self)
//        } else {
//            self
//        }
//    }
//    
//    func hideKeyboard() {
//        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
//    }
//    
//    var keyboardPublisher: AnyPublisher<Bool, Never> {
//       Publishers
//         .Merge(
//           NotificationCenter
//             .default
//             .publisher(for: UIResponder.keyboardWillShowNotification)
//             .map { _ in true },
//           NotificationCenter
//             .default
//             .publisher(for: UIResponder.keyboardWillHideNotification)
//             .map { _ in false })
//         .debounce(for: .seconds(0.1), scheduler: RunLoop.main)
//         .eraseToAnyPublisher()
//     }
//}
