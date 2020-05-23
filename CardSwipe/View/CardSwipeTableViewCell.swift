//
//  CardSwipeTableViewCell.swift
//  CardSwipe
//
//  Created by Abhinav Singh on 4/25/20.
//  Copyright © 2020 Abhinav. All rights reserved.
//

import UIKit

class CardSwipeTableViewCell: UITableViewCell {
    
    @IBOutlet weak var leftStackView: UIStackView!
    @IBOutlet weak var rightStackView: UIStackView!
    @IBOutlet weak var cardFrontView: UIView!
    
    @IBOutlet weak var cardBackgroundView: UIView!
    @IBOutlet weak var cardBank: UILabel!
    @IBOutlet weak var cardLogo: UILabel!
    @IBOutlet weak var cardNumber: UILabel!
    @IBOutlet weak var cardOwner: UILabel!
    private var cardWidth: CGFloat = 0.0
    weak var delegate: CardSwipeCellDelegate?
    var panRecognizer: UIPanGestureRecognizer?
    private var index = -1
    var runningAnimations = [UIViewPropertyAnimator]()
    var animationProgressWhenInterrupted:CGFloat = 0
    
    enum CardState {
        case openRight
        case openLeft
        case center
    }
    
    var currentState: CardState {
        return (cardFrontView.center.x == cardBackgroundView.center.x) ? .center : cardFrontView.center.x < cardBackgroundView.center.x ? .openLeft : .openRight
    }
    

    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = UIColor.clear
        cardWidth = cardFrontView.bounds.width
        panRecognizer = UIPanGestureRecognizer(target: self, action: #selector(panThisCell(_:)))
        panRecognizer?.delegate = self
        self.addGestureRecognizer(panRecognizer!)
        
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        resetConstraintContstants()
    }
    
    func closeCell() {
        resetConstraintContstants()
    }
    
    func configureCell(_ card: Card, indexPath: IndexPath){
        cardBank.text = card.cardType.uppercased()
        cardLogo.text = card.cardLogo.uppercased()
        cardOwner.text = card.cardOwner
        cardNumber.text = card.cardNumber
        cardFrontView.backgroundColor = getColor(card.cardType)
        leftStackView.removeAllArrangedSubviews()
        rightStackView.removeAllArrangedSubviews()
        createButtons(card.cardButtons, In: leftStackView)
        createButtons(card.cardButtons, In: rightStackView)
        index = indexPath.row
    }
    
    func createButtons(_ buttonArray:[String] ,In stackview: UIStackView){
        for button in buttonArray {
            let cardButton = UIButton(frame: CGRect(x: 0, y: 0, width: 50, height: 30))
            cardButton.layer.cornerRadius = 5
            cardButton.layer.backgroundColor = UIColor.clear.cgColor
            cardButton.setTitle(button, for: .normal)
            cardButton.setTitleColor(.gray, for: .normal)
            cardButton.titleEdgeInsets = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
            cardButton.titleLabel?.numberOfLines = 0
            cardButton.titleLabel?.lineBreakMode = .byWordWrapping
            cardButton.titleLabel?.font = UIFont.systemFont(ofSize: 13, weight: .semibold)
            cardButton.addTarget(self, action: #selector(self.performButtonAction(sender:)), for: .touchUpInside)
            stackview.addArrangedSubview(cardButton)
        }
    }
    
    func getColor(_ type: String) -> UIColor{
        switch(type.lowercased()){
        case "sbi": return UIColor.blue
        case "amex": return UIColor.darkGray
        case "hdfc": return UIColor.brown
        default: return UIColor.orange
        }
    }
    
    @objc func performButtonAction(sender: UIButton) {
        self.delegate?.actionOnButtonClick(text: sender.titleLabel!.text!, forIndex: index)
    }
    
}

extension CardSwipeTableViewCell{
    
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        if let pan = gestureRecognizer as? UIPanGestureRecognizer {
            var point = gestureRecognizer.location(in: self.superview)
            point.y = point.y - self.frame.minY
            let translation = pan.translation(in: self.superview)
            return fabsf(Float(translation.x)) > fabsf(Float(translation.y)) && self.cardFrontView.frame.contains(point)
        }
        
        return false
    }
    
}

// pan gesture related methods
extension CardSwipeTableViewCell {
    
    @objc func panThisCell(_ recognizer: UIPanGestureRecognizer?) {
        switch recognizer!.state {
        case .began:
            // start transition
            let velocity = recognizer?.velocity(in: self.cardFrontView)
            if let vel = velocity {
                
                startInteractiveTransition(state: currentState, duration: 1.0, velocity: vel)
            }
        case .changed:
            // update transition
            let translation = recognizer?.translation(in: self.cardFrontView)
            if let trans = translation {
                let fractionComplete = trans.x/(self.cardFrontView.frame.width)
                var fraction:CGFloat = 0.0;
                if(fractionComplete < 0){
                    fraction = -fractionComplete
                }else {
                    fraction = fractionComplete
                }
              updateInteractiveTransition(fractionCompleted: fraction)
            }
       
        case .ended:
            continueInteractiveTransition()
        default:
            print("Nothing in gesture")
            
        }
    }
    
    func startInteractiveTransition(state: CardState, duration: TimeInterval, velocity: CGPoint){
        if runningAnimations.isEmpty {
            // run animation
            animateTransitionIfNeeded(state: state, duration: duration, velocity:velocity)
        }
        
        for animator in runningAnimations {
            animator.pauseAnimation()
            animationProgressWhenInterrupted = animator.fractionComplete
        }
    }
    
    func updateInteractiveTransition(fractionCompleted: CGFloat){
        for animator in runningAnimations {
            animator.fractionComplete = fractionCompleted + animationProgressWhenInterrupted
        }
        
    }
    
    func continueInteractiveTransition(){
        for animator in runningAnimations {
            animator.continueAnimation(withTimingParameters: nil, durationFactor: 0)
        }
        
    }
    
    
}

// position update to a particular spot with animation
extension CardSwipeTableViewCell {
    
    func animateTransitionIfNeeded(state:CardState, duration:TimeInterval, velocity:CGPoint, completion: ((Bool) -> Void)? = nil){
        if runningAnimations.isEmpty {
            let frameAnimator = UIViewPropertyAnimator(duration: duration, curve: .easeOut){
                switch state {
                case .center:
                    if(velocity.x > 0) {
                        self.cardFrontView.center = CGPoint(x: self.cardBackgroundView.frame.maxX, y: self.cardBackgroundView.center.y)
                        self.delegate?.cellDidOpen(cell: self)
                    }else {
                        self.cardFrontView.center = CGPoint(x: self.cardBackgroundView.frame.origin.x, y: self.cardBackgroundView.center.y)
                        self.delegate?.cellDidOpen(cell: self)
                    }
                case .openLeft:
                    if(velocity.x > 0) {
                        self.cardFrontView.center = CGPoint(x: self.cardBackgroundView.center.x, y: self.cardBackgroundView.center.y)
                        self.delegate?.cellDidClose(cell: self)
                    }
                case .openRight:
                    if(velocity.x < 0) {
                        self.cardFrontView.center = CGPoint(x: self.cardBackgroundView.center.x, y: self.cardBackgroundView.center.y)
                        self.delegate?.cellDidClose(cell: self)
                    }
                }
            }
            
            frameAnimator.addCompletion{ _ in
                self.runningAnimations.removeAll()
                completion?(true)
            }
            
            frameAnimator.startAnimation()
            runningAnimations.append(frameAnimator)
        }
    }
    
    func resetConstraintContstants(){
        
        let frameAnimator = UIViewPropertyAnimator(duration: 1.0, curve: .easeOut){
            
            self.cardFrontView.center = CGPoint(x: self.cardBackgroundView.center.x, y: self.cardBackgroundView.center.y)
            self.delegate?.cellDidClose(cell: self)
            
        }
        
        frameAnimator.startAnimation()
        
    }
    
}

extension UIStackView {
    
    func removeAllArrangedSubviews() {
        
        let removedSubviews = arrangedSubviews.reduce([]) { (allSubviews, subview) -> [UIView] in
            self.removeArrangedSubview(subview)
            return allSubviews + [subview]
        }
        
        // Deactivate all constraints
        NSLayoutConstraint.deactivate(removedSubviews.flatMap({ $0.constraints }))
        
        // Remove the views from self
        removedSubviews.forEach({ $0.removeFromSuperview() })
    }
    
}


