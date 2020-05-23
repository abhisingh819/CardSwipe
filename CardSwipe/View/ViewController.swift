//
//  ViewController.swift
//  CardSwipe
//
//  Created by Abhinav Singh on 4/25/20.
//  Copyright © 2020 Abhinav. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    @IBOutlet weak var cardTableView: UITableView!
    private var cardDataSource = [Card]()
    private var openedCell: UITableViewCell?
    private var cardPresenter : CardViewPresenter?
    private var firstLoad = true
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cardPresenter = CardViewPresenter(view: self)
        cardPresenter?.updateModalToView()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if firstLoad {
            let index = IndexPath(row: 0, section: 0)
            if let cell = cardTableView.cellForRow(at: index) {
                animateOpening(cell: cell)
            }
            firstLoad = false
        }
    }
    
    func animateOpening(cell: UITableViewCell){
        if let inputCell = cell as? CardSwipeTableViewCell {
            var velocity = CGPoint(x: -1.0, y: 0.0)
            inputCell.animateTransitionIfNeeded(state: .center, duration: 1.5, velocity: velocity){ completed in
                if completed {
                    velocity = CGPoint(x:1.0, y:0.0)
                    inputCell.animateTransitionIfNeeded(state:.openLeft, duration: 1.5, velocity: velocity){ completed in
                        velocity = CGPoint(x:1.0, y:0.0)
                        inputCell.animateTransitionIfNeeded(state:.center, duration: 1.5, velocity: velocity){ completed in
                            
                            velocity = CGPoint(x:-1.0, y:0.0)
                            inputCell.animateTransitionIfNeeded(state:.openRight, duration: 1.5, velocity: velocity)
                        }
                        
                    }
                }
            }
        }
    }
    
    @objc func alertClose(gesture: UITapGestureRecognizer) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return cardDataSource.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = cardTableView.dequeueReusableCell(withIdentifier: "cardCell") as? CardSwipeTableViewCell else {
            return UITableViewCell()
        }
        cell.delegate = self
        cell.configureCell(cardDataSource[indexPath.row], indexPath: indexPath)
        return cell
    }
    
}

extension ViewController : UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if(scrollView == cardTableView){
            if let alreadyOpenedCell = openedCell as? CardSwipeTableViewCell {
                alreadyOpenedCell.closeCell()
                openedCell = nil
            }
        }
    }
    
}

extension ViewController: CardView {
    
    func update(card: [Card]) {
        cardDataSource = []
        cardDataSource.append(contentsOf: card)
    }
    
}

// CardSwipeCellDelegate Methods
extension ViewController : CardSwipeCellDelegate {
    
    func actionOnButtonClick(text: String, forIndex: Int) {
        let objAlertController = UIAlertController(title: text, message: "\(text) for \(cardDataSource[forIndex].cardType.uppercased())", preferredStyle: UIAlertController.Style.alert)
        let objAction = UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler:
        {Void in
            
            
        })
        
        
        objAlertController.addAction(objAction)
        present(objAlertController, animated: true, completion:  {
            objAlertController.view.superview?.isUserInteractionEnabled = true
            objAlertController.view.superview?.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertClose(gesture:))))
        })
    }
    
    func cellDidOpen(cell: UITableViewCell) {
        if let alreadyOpenedCell = openedCell as? CardSwipeTableViewCell {
            alreadyOpenedCell.closeCell()
        }
        openedCell = cell
    }
    
    func cellDidClose(cell: UITableViewCell) {
        if let alreadyOpenedCell = openedCell as? CardSwipeTableViewCell, openedCell != cell {
            alreadyOpenedCell.closeCell()
            openedCell = cell
        } else {
            openedCell = nil
        }
    }
    
}

