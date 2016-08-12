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
    case right = 1
    case left = 2
    case up = 3
    case down = 4
    
    //取反向
    func reverse() -> Direction {
        switch self {
        case .right:
            return .left
        case .left:
            return .right
        case .up:
            return .down
        case .down:
            return .up
        default:
            return .stat
        }
    }
}

class Snake {
    var cells: [SnakeCell] = []
    var head: SnakeCell? {
        return cells.first
    }
    var tempHeadDirection: Direction!
    
    var speed = 0.7 //n秒走一格
    
    var started = false
    var isMoving: Bool = false {
        willSet {
            if !newValue {
                head?.direction = tempHeadDirection
            }
        }
    }
    
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
    
    //MARK: 开始
    func start() {
        //生成蛇头
        if let headCell = delegate?.addRandomCell() {
            headCell.direction = Direction(rawValue: 1.randomIntTo(4))!
            cells.append(headCell)
        }
        
        //放置一个初始方块
        delegate?.addRandomCell()
        
        started = true
        tempHeadDirection = head?.direction
        isMoving = false
        move()
    }
    
    //MARK: 结束
    func end() {
        started = false
        for cell in cells {
            cell.removeFromSuperview()
        }
        cells.removeAll()
    }
    
    //MARK: 走
    func move() {
        if !started || isMoving {
            return
        }
        delegate?.snakeWillMove(self)
        var lastCellPoint: (x: Int, y: Int)!
        let tempCells = cells
        isMoving = true
        for (index, cell) in tempCells.enumerate() {
            UIView.animateWithDuration(speed, animations: {
                if lastCellPoint == nil {
                    
                    lastCellPoint = cell.position
                    cell.moveToNextPoint()
                    
                } else {
                    
                    let temp = cell.position
                    cell.position = lastCellPoint
                    lastCellPoint = temp
                    
                }
                }, completion: { (completion) in
                    if index == 0 {
                        self.delegate?.snakeDidMove(self)
                        self.isMoving = false
                    }
                    
                    //tail did move
                    if index == tempCells.count-1 {
                        self.move()
                    }
            })
        }
    }
    
    //MARK: 转
    func turn(direction: Direction) {
        //两个块时点击相反方向无效
        if !(cells.count > 1 && head?.direction == direction.reverse()) {
            tempHeadDirection = direction
        }
    }
    
    //MARK: 吃
    func feed(cell: SnakeCell, handler: () -> ()) {
        cell.direction = head!.direction
        cells.insert(cell, atIndex: 0)
        handler()
    }
}

protocol SnakeDelegate {
    /**
     小蛇将要走动
     
     - parameter snake: 小蛇实例
     */
    func snakeWillMove(snake: Snake)
    
    /**
     小蛇已经移动
     
     - parameter snake: 小蛇实例
     */
    func snakeDidMove(snake: Snake)
    
    /**
     生成随机蛇块
     */
    func addRandomCell() -> SnakeCell? 
}

class SnakeCell: UIView {
    var position: (x: Int, y: Int) = (x: 0, y: 0) {
        willSet {
            frame = CGRect(origin: CGPoint(x: CGFloat(newValue.x) * cellWidth, y: CGFloat(newValue.y) * cellWidth), size: frame.size)
        }
    }
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
        cellWidth = width
        self.position = position
        self.direction = direction
        backgroundColor = UIColor.clearColor()
        
        contentCell = UIView(frame: CGRect(x: 1, y: 1, width: width-1, height: width-1))
        contentCell!.backgroundColor = UIColor.blackColor()
        addSubview(contentCell!)
    }
    
    func nextPointByDirection() -> (x: Int, y: Int) {
        var nextPoint: (x: Int, y: Int)
        switch direction {
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
        position = nextPointByDirection()
    }
}

extension Int {
    func randomIntTo(end: Int) -> Int {
        var a = self
        var b = end
        if a > b {
            swap(&a, &b)
        }
        return Int(arc4random_uniform(UInt32(b - a + 1))) + a
    }
}
