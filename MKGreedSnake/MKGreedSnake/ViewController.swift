//
//  ViewController.swift
//  MKGreedSnake
//
//  Created by Liujh on 16/8/2.
//  Copyright © 2016年 cn.mkapple. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    var snake: Snake!
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    private var cellWidth: CGFloat {
        return contentView.frame.size.width/CGFloat(numberOfColumn)
    }
    
    //列数
    let numberOfColumn = 10
    //行数
    private var numberOfLine: Int {
        return Int(contentView.frame.size.height/cellWidth)
    }
    
    //地图
    private var map: Array<(x: Int, y: Int)> {
        var temp = [(x: Int, y: Int)]()
        for line in 0..<numberOfLine {
            for column in 0..<numberOfColumn {
                temp.append((x: column, y: line))
            }
        }
        return temp
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setupBase()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setupBase() {
        if snake == nil {
            contentView.layer.cornerRadius = 8
            contentView.layer.borderWidth = 1
            contentView.layer.borderColor = UIColor.lightGrayColor().CGColor
            contentView.layer.masksToBounds = true
            
            //约束 contentView 底下间隔
            let contentViewHeight = contentView.frame.size.height
            let contentViewTrueHeight = cellWidth * CGFloat(numberOfLine)
            contentViewBottomConstraint.constant += (contentViewHeight - contentViewTrueHeight)
            
            for i in 1 ..< numberOfLine {
                let line = UIView(frame: CGRect(x: 0, y: cellWidth*CGFloat(i), width: contentView.frame.size.width, height: 1))
                line.backgroundColor = UIColor.lightGrayColor()
                contentView.addSubview(line)
            }
            
            for i in 1 ..< numberOfColumn {
                let line = UIView(frame: CGRect(x: cellWidth*CGFloat(i), y: 0, width: 1, height: contentViewTrueHeight))
                line.backgroundColor = UIColor.lightGrayColor()
                contentView.addSubview(line)
            }
            
            //初始化蛇
            snake = Snake(cellWidth: cellWidth, color: UIColor.orangeColor(), delegate: self)
        }
    }
    
    //MARK: 按下方向
    @IBAction func directionClick(sender: UIButton) {
        snake.turn(Direction(rawValue: sender.tag)!)
    }
    
    //MARK: 开始游戏
    @IBAction func startGame(sender: UIButton) {
        if snake.started {
            //结束
            sender.setTitle("开始", forState: .Normal)
            
            snake.bait?.removeFromSuperview()
            
            snake.end()
            
        } else {
            //开始
            sender.setTitle("结束", forState: .Normal)
            scoreLabel.text = "0"
            
            snake.start()
        }
    }
    
    @IBAction func testMove(sender: AnyObject) {
        snake.move()
    }
    
}

//MARK: SnakeDelegate
extension ViewController: SnakeDelegate {
    func snakeWillMove(snake: Snake) {
        //判断是否越轨或者吃自己
        if let position = snake.head?.nextPointByDirection() where (!map.contains({$0 == position}) || snake.cells.contains({$0.position == position})) {
            let source = snake.cells.count-1
            startGame(startBtn)
            let alertCtrl = UIAlertController(title: "Game Over!", message: "得分：\(source)分", preferredStyle: .Alert)
            alertCtrl.addAction(UIAlertAction(title: "好的", style: .Default, handler: nil))
            presentViewController(alertCtrl, animated: true, completion: nil)
            return
        }
        
    }
    
    func snakeDidMove(snake: Snake) {
        //判断下一个位置是否有吃的
        let position = snake.bait?.position
        if  let headPosition = snake.head?.nextPointByDirection() where headPosition ==  position! {
            snake.feed()
        }
        
    }
    
    func didFeed() {
        //吃完以后生成一个新的随机 cell
        scoreLabel!.text = String(snake!.cells.count-1)
        print("蛇吃了(\(snake!.bait?.position))的 cell")
    }
    
    //MARK: 生成地图一个随机点
    func randomPoint() -> (x: Int, y: Int)? {
        //生成蛇头的时候不能放在距离边栏3距离以内
        var tempMap = map
        let limit = 3
        if snake.cells.count == 0 {
            for point in map {
                if point.x < limit || point.x > (numberOfColumn - limit - 1) || point.y < limit || point.y > (numberOfLine - limit - 1) {
                    if let tempIndex = tempMap.indexOf({$0 == point}) {
                        tempMap.removeAtIndex(tempIndex)
                    }
                }
            }
        }
        
        //删去已被使用的点
        for cell in snake.cells {
            
            if let index = tempMap.indexOf({$0 == cell.position}) {
                tempMap.removeAtIndex(index)
            }
            
        }
        
        let randomIndex = 0.randomIntTo(tempMap.count-1)
        if randomIndex < tempMap.count {
            return tempMap[randomIndex]
        }
        return nil
    }
    
    func addbaitToMap(bait: SnakeCell) {
        contentView.addSubview(bait)
        print("位置：(\(bait.position.x), \(bait.position.y)), 方向：\(bait.direction), 放置了一个诱饵")
    }

}

