//
//  GameView.swift
//  App09-Game
//
//  Created by Alumno on 01/11/21.
//

import SwiftUI
import SpriteKit

struct GameView: View {
    
    @Environment(\.presentationMode) var presentationMode
    @State var scene: SKScene = GameScene()
    @ObjectObserved currentScore
    
    
    var body: some View {
        ZStack {
            SpriteView(scene: scene)
                .frame(width: 926, height: 444)
            VStack {
                HStack {
                    VStack{
                        Text("Score: \(currentScore)")
                            .font(.body)
                            .background(Color.black)
                            .padding(.top, 10)
                    }
                    Spacer()
                    VStack {
                        Button {
                            presentationMode.wrappedValue.dismiss()
                        } label: {
                            Image(systemName: "x.circle.fill")
                                .foregroundColor(.red)
                                .font(.largeTitle)
                                .padding(.top,10)
                                .padding(.trailing,10)
                        }
                    }
                    .padding(.trailing,20)
                    .padding(.top, 20)
                }
                Spacer()
            }
        }
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            
            AppDelegate.orientationLock = UIInterfaceOrientationMask.landscapeRight
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeLeft.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
            scene = SKScene(fileNamed: "GameScene.sks")!
            scene.scaleMode = .aspectFit
            scene.size = CGSize(width: 926, height: 428)

        }
        .onDisappear {
            AppDelegate.orientationLock = UIInterfaceOrientationMask.portrait
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        }
    }
}

struct GameView_Previews: PreviewProvider {
    static var previews: some View {
        GameView(scene: SKScene())
    }
}
