//
//  BoardView.swift
//  Bank23
//
//  Created by Ian Vonseggern on 12/27/16.
//  Copyright © 2016 Ian Vonseggern. All rights reserved.
//

import Foundation
import UIKit
import QuartzCore

class BoardView: UIImageView {
  var _rowCount = 0
  var _columnCount = 0
  
  var showCountLabels = true
  
  static func backgroundColor() -> UIColor {
    return UIColor(red:0.83, green:0.91, blue:0.88, alpha:1.0) // D3E8E1
  }
  
  static func lineColor() -> UIColor {
    return UIColor(red:0.42, green:0.56, blue:0.33, alpha:1.0)
  }
  
  override init(frame: CGRect) {
    super.init(frame:frame)
    
    self.backgroundColor = BoardView.backgroundColor()
    self.isUserInteractionEnabled = true
  }
  
  required init?(coder aDecoder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func layoutSubviews() {
    // draw lines
    UIGraphicsBeginImageContext(self.frame.size)
    let context = UIGraphicsGetCurrentContext()
    context?.setStrokeColor(BoardView.lineColor().cgColor)
    for i in 0..._columnCount {
      let float_i = CGFloat(i)
      context?.move(to: CGPoint(x: self.singleSquareSize() * float_i, y: 0))
      context?.addLine(to: CGPoint(x: self.singleSquareSize() * float_i,
                                   y: self.singleSquareSize() * CGFloat(_rowCount)))
      context?.strokePath()
    }
    for i in 0..._rowCount {
      let float_i = CGFloat(i)
      context?.move(to: CGPoint(x: 0, y: self.singleSquareSize() * float_i))
      context?.addLine(to: CGPoint(x: self.singleSquareSize() * CGFloat(_columnCount),
                                   y: self.singleSquareSize() * float_i))
      context?.strokePath()
    }
    self.image = UIGraphicsGetImageFromCurrentImageContext()
    UIGraphicsEndImageContext()
    
    // layout pieces
    for subview in self.subviews {
      let pieceview = subview as! PieceView
      pieceview.frame = CGRect(x: self.singleSquareSize() * CGFloat(pieceview._column),
                               y:self.singleSquareSize() * CGFloat(_rowCount - 1 - pieceview._row),
                               width:self.singleSquareSize(),
                               height:self.singleSquareSize())
    }
  }
  
  func singleSquareSize() -> CGFloat {
    return self.bounds.width / CGFloat(_columnCount)
  }
  
  override func sizeThatFits(_ size: CGSize) -> CGSize {
    var singleSquareSize = SINGLE_SQUARE_SIZE
    if singleSquareSize * CGFloat(_rowCount) > size.height {
      singleSquareSize = size.height / CGFloat(_rowCount)
      singleSquareSize.round(.down)
    }
    if singleSquareSize * CGFloat(_columnCount) > size.width {
      singleSquareSize = size.width / CGFloat(_columnCount)
      singleSquareSize.round(.down)
    }
    return CGSize(width: singleSquareSize * CGFloat(_columnCount) + 2,
                  height: singleSquareSize * CGFloat(_rowCount) + 2)
  }
  
  // Used to animate user pans, moves all the pieces that move that amount from their normal position in that direction
  // TODO make 'by' 0-1 as a ratio of a square size instead of an actual distance
  func adjust(movablePieceMask: [[Bool]], by: CGFloat, inDirection: Direction) {
    var xOffset: CGFloat
    var yOffset: CGFloat
    switch inDirection {
    case .bottom:
      xOffset = 0
      yOffset = -1 * by
      break
    case .top:
      xOffset = 0
      yOffset = by
    case .right:
      xOffset = -1 * by
      yOffset = 0
    case .left:
      xOffset = by
      yOffset = 0
    }
    
    for subview in self.subviews {
      let pieceview = subview as! PieceView
      if movablePieceMask[pieceview._column][pieceview._row] {
        pieceview.frame = CGRect(x: self.singleSquareSize() * CGFloat(pieceview._column) + xOffset,
                                 y:self.singleSquareSize() * CGFloat(_rowCount - 1 - pieceview._row) + yOffset,
                                 width:self.singleSquareSize(),
                                 height:self.singleSquareSize())
      }
    }
  }
  
  // First half of an animation used to show pieces combining with themselves, basically
  // a spin simply by shrinking and expanding
  func spinIn(pieceMask: [[Bool]]) {
//    var transition = CATransition()
//    var animation = CAAnimation()
//    animation.beginTime = 0.0
//    animation.duration = 0.3
//    animation.type
    for subview in self.subviews {
      let pieceview = subview as! PieceView
      if pieceMask[pieceview._column][pieceview._row] {
        pieceview.frame = CGRect(x: self.singleSquareSize() * (CGFloat(pieceview._column) + 0.5),
                                 y:self.singleSquareSize() * CGFloat(_rowCount - 1 - pieceview._row),
                                 width:1.0,
                                 height:self.singleSquareSize())
      }
    }
  }
  
  func updateModel(board: [[Piece]]) {
    _columnCount = board.count
    if (_columnCount == 0) {
      return
    }
    _rowCount = board[0].count

    for subview in self.subviews {
      subview.removeFromSuperview()
    }
    
    var pieceViews = [PieceView]()
    for (columnIndex, column) in board.enumerated() {
      for (rowIndex, piece) in column.enumerated() {
        if (piece != Piece.empty) {
          let pieceView = addPiece(piece: piece, row: rowIndex, col: columnIndex)
          pieceViews.append(pieceView)
        }
      }
    }
    
    // We want to show the sand and the coins on top of the stationary pieces
    for pieceView in pieceViews {
      if pieceView._model.moves() {
        self.bringSubview(toFront: pieceView)
      }
    }

    self.setNeedsLayout()
  }
  
  func addPiece(piece: Piece, row: Int, col: Int) -> PieceView {
    if (row < 0 || col < 0 || row >= _rowCount || col >= _columnCount) {
      assertionFailure("invalide row /(row) or col /(col) value passed to view")
    }
    let pieceView = PieceView(frame: CGRect.zero,
                              model: piece,
                              row:row,
                              column:col)
    
    if !showCountLabels {
      pieceView.showCount = false
    }
    
    self.addSubview(pieceView)

    return pieceView
  }
}
