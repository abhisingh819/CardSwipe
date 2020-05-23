//
//  CardViewPresenter.swift
//  CardSwipe
//
//  Created by Abhinav Singh on 4/26/20.
//  Copyright © 2020 Abhinav. All rights reserved.
//

import Foundation

class CardViewPresenter {
    private weak var cardView: CardView?
    
    init(view: CardView){
        self.cardView = view
    }
    
    func updateModalToView(){
        guard let cardV = self.cardView else {
            return
        }
        var card = [Card]()
        card.append(Card(cardType: "amex", cardNumber: "3798 xxxxxx x1005", cardOwner: "Abhinav Singh", cardLogo: "amex", cardColor: "Green", cardButtons: ["Pay Now", "View Details","Watch Video"]))
        card.append(Card(cardType: "sbi", cardNumber: "3798 xxxxxx x1005", cardOwner: "Abhinav Singh", cardLogo: "sbi", cardColor: "Pink", cardButtons: ["Pay Now", "View Details"]))
        card.append(Card(cardType: "hdfc", cardNumber: "3798 xxxxxx x1005", cardOwner: "Abhinav Singh", cardLogo: "hdfc", cardColor: "Black", cardButtons: ["Pay Now", "View Details"]))
        card.append(Card(cardType: "idbi", cardNumber: "3798 xxxxxx x1005", cardOwner: "Abhinav Singh", cardLogo: "idbi", cardColor: "Black", cardButtons: ["Pay Now", "View Details"]))
        cardV.update(card: card)
        
    }
    
}
