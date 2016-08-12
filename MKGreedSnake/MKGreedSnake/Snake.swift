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
    var cellWidth: CGFloat
    
    //诱饵
    var bait: SnakeCell? {
        didSet {
            //放到地图
            delegate?.addbaitToMap(bait!)
        }
    }
    
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
    
    //屏蔽无参数初始方法
    private init(){
        self.cellWidth = 0
        self.color = UIColor.orangeColor()
        self.delegate = nil
    }
    
    init(cellWidth: CGFloat, color: UIColor, delegate: SnakeDelegate) {
        self.cellWidth = cellWidth
        self.color = color
        self.delegate = delegate
    }
    
    //MARK: 开始
    func start() {
        //生成蛇头
        let headCell = SnakeCell(width: cellWidth, color: color, position: delegate!.randomPoint()!, direction: Direction(rawValue: 1.randomIntTo(4))!)
        headCell.cellColor = color
        cells.append(headCell)
        delegate?.addbaitToMap(headCell)
        
        //放置一个初始方块
        bait = SnakeCell(width: cellWidth, color: color, position: delegate!.randomPoint()!, direction: .stat)
        
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
        
        //如果转方向遇到诱饵时就吃了它
        if bait!.position == head!.pointAt(.up, distance: 1) ||
            bait!.position == head!.pointAt(.down, distance: 1) ||
            bait!.position == head!.pointAt(.left, distance: 1) ||
            bait!.position == head!.pointAt(.right, distance: 1){
            
            feed()
        }
    }
    
    //MARK: 吃
    func feed() {
        bait!.direction = head!.direction
        cells.insert(bait!, atIndex: 0)
        
        //吃完以后生成新的诱饵
        bait = SnakeCell(width: cellWidth, color: color, position: delegate!.randomPoint()!, direction: .stat)
        
        delegate?.didFeed()
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
    
    func didFeed()
    
    /**
     添加诱饵到地图
     */
    func addbaitToMap(bait: SnakeCell)
    
    /**
     生成随机诱饵地点
     */
    func randomPoint() -> (x: Int, y: Int)?
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
    
    init(width: CGFloat, color: UIColor, position: (x: Int, y: Int), direction: Direction) {
        super.init(frame: CGRect(x: CGFloat(position.x) * width, y: CGFloat(position.y) * width, width: width, height: width))
        cellWidth = width
        self.position = position
        self.direction = direction
        self.cellColor = color
        backgroundColor = UIColor.clearColor()
        
        contentCell = UIView(frame: CGRect(x: 1, y: 1, width: width-1, height: width-1))
        contentCell!.backgroundColor = color
        addSubview(contentCell!)
    }
    
    //本身方向的下一个点
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
            nextPoint = position
        }
        return nextPoint
    }
    
    //移动到下一个点
    func moveToNextPoint() {
        position = nextPointByDirection()
    }
    
    //自身某个方向距离为 x 的点
    func pointAt(direction: Direction, distance: Int) -> (x: Int, y: Int) {
        var nextPoint: (x: Int, y: Int)
        switch direction {
        case .up:
            nextPoint = (x: position.x, y: position.y-distance)
        case .down:
            nextPoint = (x: position.x, y: position.y+distance)
        case .right:
            nextPoint = (x: position.x+distance, y: position.y)
        case .left:
            nextPoint = (x: position.x-distance, y: position.y)
        default:
            nextPoint = position
        }
        return nextPoint
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
