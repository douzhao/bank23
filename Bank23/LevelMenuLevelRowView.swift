//
//  LevelMenuLevelRowView.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/21/17.
//  Copyright © 2017 Ian Vonseggern. All rights reserved.
//

import Foundation

import UIKit

class LevelMenuLevelRowView: UIView {
  let _levelName = UILabel()
  let _creatorName = UILabel()
  var _bestTime: UILabel?
  var _checkmark: UIImageView? // Shown if they have beaten the level before
  let _boardView = BoardView(frame: CGRect.zero)
  
  init(gameModel: GameModel, levelBeatenTime: Int?) {
    super.init(frame: CGRect.zero)
    
    _levelName.text = gameModel._levelName
    _levelName.font = UIFont.boldSystemFont(ofSize: 16.0)
    _levelName.sizeToFit()
    self.addSubview(_levelName)
    
    if gameModel._creatorName != nil || gameModel._levelType == LevelType.UserCreated {
      let creatorNameString: String
      if gameModel._levelType == LevelType.UserCreated {
        creatorNameString = "You!"
      } else {
        creatorNameString = gameModel._creatorName!
      }
      _creatorName.text = "Created by ".appending(creatorNameString)

      _creatorName.font = UIFont.systemFont(ofSize: 12.0)
      _creatorName.textColor = UIColor.gray
      _creatorName.sizeToFit()
      self.addSubview(_creatorName)
    }
    
    if levelBeatenTime != nil {
      _checkmark = UIImageView()
      _checkmark!.image = UIImage(named: "checkmark.png")!
      self.addSubview(_checkmark!)
      
      // For levels beaten before we stored the time we set time to INT_MAX
      // Skip showing the time in that case
      if levelBeatenTime != Int(INT_MAX) {
        _bestTime = UILabel()
        _bestTime!.text = secondsToTimeString(time: levelBeatenTime!)
        _bestTime!.font = UIFont.systemFont(ofSize: 12.0)
        _bestTime!.sizeToFit()
        self.addSubview(_bestTime!)
      }
    }
    
    _boardView.showCountLabels = false
    _boardView.updateModel(board: gameModel._board._board)
    self.addSubview(_boardView)
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    _levelName.frame = CGRect(x: 10,
                              y: 10,
                              width: _levelName.frame.width,
                              height: _levelName.frame.height)
    
    _creatorName.frame = CGRect(x: 10,
                                y: _levelName.frame.maxY,
                                width: _creatorName.frame.width,
                                height: _creatorName.frame.height)
    
    _boardView.frame =  CGRect(x: self.frame.width - 100,
                               y: 10,
                               width: 90,
                               height: 90)
    
    _checkmark?.frame = CGRect(x: 10,
                               y: 90 - 20,
                               width: 20,
                               height: 20)
    
    _bestTime?.frame = CGRect(x: _checkmark!.frame.maxX + 5,
                              y: 90 - _bestTime!.frame.height,
                              width: _bestTime!.frame.width,
                              height: _bestTime!.frame.height)
  }
}
