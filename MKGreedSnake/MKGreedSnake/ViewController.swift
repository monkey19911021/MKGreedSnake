//
//  ViewController.swift
//  MKGreedSnake
//
//  Created by Liujh on 16/8/2.
//  Copyright © 2016年 cn.mkapple. All rights reserved.
//

import UIKit

//列数
enum MapColoum {
    static let numberOfColumn = 10
}

class ViewController: UIViewController {
    var snake: Snake!
    var currentRandomCell: SnakeCell?
    
    @IBOutlet weak var contentView: UIView!
    
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var startBtn: UIButton!
    @IBOutlet weak var scoreLabel: UILabel!
    
    private var cellWidth: CGFloat {
        return contentView.frame.size.width/CGFloat(MapColoum.numberOfColumn)
    }
    
    //行数
    private var numberOfLine: Int {
        return Int(contentView.frame.size.height/cellWidth)
    }
    
    //地图
    private var map: Array<(x: Int, y: Int)> {
        var temp = [(x: Int, y: Int)]()
        for line in 0..<numberOfLine {
            for column in 0..<MapColoum.numberOfColumn {
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
            
            for i in 1 ..< MapColoum.numberOfColumn {
                let line = UIView(frame: CGRect(x: cellWidth*CGFloat(i), y: 0, width: 1, height: contentViewTrueHeight))
                line.backgroundColor = UIColor.lightGrayColor()
                contentView.addSubview(line)
            }
            
            //初始化蛇
            snake = Snake(color: UIColor.orangeColor())
            snake.delegate = self
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
            
            currentRandomCell?.removeFromSuperview()
            
            snake.end()
            
        } else {
            //开始
            sender.setTitle("结束", forState: .Normal)
            scoreLabel.text = "0"
            //生成蛇头
            if let headCell = addRandomCell() {
                headCell.direction = Direction(rawValue: 1.randomIntTo(4))!
                snake.cells.append(headCell)
            }
            
            //放置一个初始方块
            addRandomCell()
            snake.start()
        }
    }
    
    @IBAction func testMove(sender: AnyObject) {
        snake.move()
    }
    
    
    //MARK: 生成地图一个随机点
    func randomPoint() -> (x: Int, y: Int)? {
        var tempMap = map
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
    
    //MARK: 生成一个随机位置 cell
    func addRandomCell() -> SnakeCell? {
        if let point = randomPoint() {
            let cell = SnakeCell(width: cellWidth, position: point, direction: .stat)
            cell.cellColor = snake.color
            contentView.addSubview(cell)
            currentRandomCell = cell
            print("位置：(\(cell.position.x), \(cell.position.y)), 方向：\(cell.direction), 放置了一个 cell")
            return cell
        }
        return nil
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
        let position = currentRandomCell?.position
        if  let headPosition = snake.head?.nextPointByDirection() where headPosition ==  position! {
            snake.feed(currentRandomCell!, handler: {
                
                [unowned self,
                weak _cell = currentRandomCell,
                weak _snake = snake,
                weak _scoreLabel = scoreLabel] in
                
                //吃完以后生成一个新的随机 cell
                self.addRandomCell()
                _scoreLabel!.text = String(_snake!.cells.count-1)
                print("蛇吃了(\(_cell!.position))的 cell")
                
                })
        }
        
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

