//
//  QuestionCell.swift
//  SwiftChatDemo
//
//  Created by Piotr Jamróz on 29.07.2016.
//  Copyright © 2016 Piotr Jamróz. All rights reserved.
//

import UIKit

class QuestionCell: UITableViewCell {
    @IBOutlet private weak var borderView: UIView!
    @IBOutlet weak var questionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        setupAppearance()
    }
    
    // MARK: - Private
    private func setupAppearance() {
        borderView.layer.borderColor = CustomColors.hexStringToUIColor("B09E99").CGColor
        borderView.layer.borderWidth = 2.0
        borderView.layer.cornerRadius = 8.0
    }
}
