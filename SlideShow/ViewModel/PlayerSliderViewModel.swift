//
//  PlayerSliderViewModel.swift
//  SlideShow
//
//  Created by Anuj Joshi on 05/06/24.
//

import Foundation
import Combine

//class PlayerSliderViewModel: ObservableObject {
//    @Published var progressValue: Float = 0
//    
//    var player: MediaPlayer
//    var acceptProgressUpdates = true
//    var subscriptions: Set<AnyCancellable> = .init()
//    
//    init(player: MediaPlayer) {
//        self.player = player
//        listenToProgress()
//    }
//    
//    private func listenToProgress() {
//        player.currentProgressPublisher.sink { [weak self] progress in
//            guard let self = self,
//                  self.acceptProgressUpdates else { return }
//            self.progressValue = progress
//        }.store(in: &subscriptions)
//    }
//    
//    func didSliderChanged(_ didChange: Bool) {
//        acceptProgressUpdates = !didChange
//        if didChange {
//            player.pause()
//        } else {
//            player.seek(to: progressValue)
//            player.play()
//        }
//    }
//}
