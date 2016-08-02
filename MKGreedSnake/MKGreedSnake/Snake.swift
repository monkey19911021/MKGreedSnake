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
    var speed = 0.8 //n秒走一格
    var map: [(x: Int, y: Int)]?
    
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
        if cells.count > 0 {
            moveCell(cells.first!)
        }
    }
    
    //走
    private func moveCell(cell: SnakeCell) {
        UIView.animateWithDuration(speed, animations: {
                cell.moveToNextPoint()
            }, completion: { (completion) in
                
                if completion {
                    let nextIndex = self.cells.indexOf(cell)! + 1
                    if nextIndex < self.cells.count {
                       let nextCell = self.cells[nextIndex]
                        nextCell.direction = cell.direction
                        self.moveCell(nextCell)
                    } else {
                        self.moveCell(self.cells.first!)
                    }
                }
                
        })
    }
    
    //吃
    func feed(cell: SnakeCell) {
        
    }
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
    
    func moveToNextPoint() -> (x: Int, y: Int) {
        var nextPoint: (x: Int, y: Int)?
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
        self.position = nextPoint!
        self.frame = CGRect(origin: CGPoint(x: CGFloat(nextPoint!.x) * cellWidth, y: CGFloat(nextPoint!.y) * cellWidth), size: self.frame.size)
        return nextPoint!
    }
}