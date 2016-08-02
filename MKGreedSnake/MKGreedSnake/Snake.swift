//
//  SnakeCell.swift
//  MKTest
//
//  Created by DONLINKS on 16/8/1.
//  Copyright © 2016年 Donlinks. All rights reserved.
//

import Foundation
import UIKit

//走向
enum Direction: Int {
    case stat = 0
    case right
    case left
    case up
    case down
}

class Snake {
    var cells: [SnakeCell] = []
    var speed = 0.7 //n秒走一格
    var map: [(x: Int, y: Int)]?
    
    var started = false
    
    var delegate: SnakeDelegate?
    
    var color: UIColor {
        willSet {
            for cell in cells {
                cell.backgroundColor = color
            }
        }
    }
    
    init(color: UIColor) {
        self.color = color
        
    }
    
    func start() {
        started = true
        move()
    }
    
    func end() {
        started = false
        for cell in cells {
            cell.removeFromSuperview()
        }
        cells.removeAll()
    }
    
    //走
    private func move() {
        if !started {
            return
        }
        delegate?.snakeWillMove(self)
        var lastCellPoint: (x: Int, y: Int)?
        for (index, cell) in cells.enumerate() {
            UIView.animateWithDuration(speed, animations: {
                if lastCellPoint == nil {
                    lastCellPoint = cell.position
                    cell.moveToNextPoint()
                } else {
                    let temp = cell.position
                    cell.moveToNextPoint(lastCellPoint!)
                    lastCellPoint = temp
                }
                }, completion: { (completion) in
                    if index == self.cells.count-1 {
                        self.delegate?.snakeDidMove(self)
                        self.move()
                    }
            })
        }
    }
    
    //吃
    func feed(cell: SnakeCell, handler: () -> ()) {
        cell.direction = cells.first!.direction
        cells.insert(cell, atIndex: 0)
        handler()
    }
}

protocol SnakeDelegate {
    func snakeWillMove(snake: Snake)
    func snakeDidMove(snake: Snake)
}

class SnakeCell: UIView {
    var position: (x: Int, y: Int) = (x: 0, y: 0)
    var direction: Direction = .stat
    var cellWidth: CGFloat = 0.0
    var cellColor: UIColor {
        set {
            contentCell?.backgroundColor = newValue
        }
        
        get {
            return (contentCell?.backgroundColor)!
        }
    }
    
    private var contentCell: UIView?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(width: CGFloat, position: (x: Int, y: Int), direction: Direction) {
        super.init(frame: CGRect(x: CGFloat(position.x) * width, y: CGFloat(position.y) * width, width: width, height: width))
        self.direction = direction
        self.cellWidth = width
        self.position = position
        self.backgroundColor = UIColor.clearColor()
        
        contentCell = UIView(frame: CGRect(x: 1, y: 1, width: width-1, height: width-1))
        contentCell!.backgroundColor = UIColor.blackColor()
        self.addSubview(contentCell!)
    }
    
    func nextPointByDirection() -> (x: Int, y: Int) {
        var nextPoint: (x: Int, y: Int)
        switch self.direction {
        case .up:
            nextPoint = (x: position.x, y: position.y-1)
        case .down:
            nextPoint = (x: position.x, y: position.y+1)
        case .right:
            nextPoint = (x: position.x+1, y: position.y)
        case .left:
            nextPoint = (x: position.x-1, y: position.y)
        default:
            nextPoint = (x: position.x, y: position.y)
        }
        return nextPoint
    }
    
    
    func moveToNextPoint() {
        let nextPoint = self.nextPointByDirection()
        self.moveToNextPoint(nextPoint)
    }
    
    func moveToNextPoint(point: (x: Int, y: Int)) {
        self.position = point
        self.frame = CGRect(origin: CGPoint(x: CGFloat(point.x) * cellWidth, y: CGFloat(point.y) * cellWidth), size: self.frame.size)
    }
}