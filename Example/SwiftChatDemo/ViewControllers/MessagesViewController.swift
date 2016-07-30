//
//  MessagesViewController.swift
//  SwiftChatDemo
//
//  Created by Piotr Jamróz on 29.07.2016.
//  Copyright © 2016 Piotr Jamróz. All rights reserved.
//

import UIKit

class MessagesViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate {
    
    @IBOutlet private weak var askAnotherQuestionTextView: UITextView!
    @IBOutlet private weak var askAnotherQuestionTextViewHeightContraint: NSLayoutConstraint!
    @IBOutlet private weak var headerView: UIView!
    @IBOutlet private weak var profileView: UIView!
    @IBOutlet private weak var tableView: UITableView!
    @IBOutlet private weak var textInputView: UIView!
    @IBOutlet private weak var textInputViewBottomToSuperviewConstraint: NSLayoutConstraint!
    
    private lazy var offscreenCell: QuestionCell = {
        let questionCell = NSBundle.mainBundle().loadNibNamed(String(QuestionCell), owner: self, options: nil)[0] as? QuestionCell
        questionCell!.contentView.translatesAutoresizingMaskIntoConstraints = false
        questionCell!.contentView.addConstraint(NSLayoutConstraint(item: questionCell!.contentView,
            attribute: .Width,
            relatedBy: .Equal,
            toItem: nil,
            attribute: .NotAnAttribute,
            multiplier: 1.0,
            constant: CGRectGetWidth(UIScreen.mainScreen().bounds))
        )
        return questionCell!
    }()
    
    private var keyboardHeight: Double?
    private var isKeyboardVisible = false
    private var questions: [String] = []
    
    private let questionCell = "Question Cell"
    private let placeholderText = "Ask another question"
    
    // MARK: - Life cycle
    
    class func create() -> (MessagesViewController?) {
        let storyboard = UIStoryboard(name: String(MessagesViewController), bundle: nil)
        let instance = storyboard.instantiateViewControllerWithIdentifier(String(MessagesViewController))
        return instance as? MessagesViewController
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NSNotificationCenter.defaultCenter().addObserver(self, selector:#selector(keyboardChangedFrame(_:)), name: UIKeyboardWillChangeFrameNotification, object: nil)
        askAnotherQuestionTextView.delegate = self
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.registerNib(UINib(nibName: String(QuestionCell), bundle: nil), forCellReuseIdentifier: questionCell)
        
        let tapGesture = UITapGestureRecognizer(target: self, action:#selector(MessagesViewController.keyboardDismissAction(_:)))
        headerView.addGestureRecognizer(tapGesture)
        tableView.addGestureRecognizer(tapGesture)
        
        setupAppearance()
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(questionCell, forIndexPath: indexPath)
        if let questionCell = cell as? QuestionCell {
            configureCell(questionCell, forIndexPath: indexPath)
            return questionCell
        }
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        configureCell(offscreenCell, forIndexPath: indexPath)
        offscreenCell.setNeedsUpdateConstraints()
        offscreenCell.updateConstraintsIfNeeded()
        offscreenCell.contentView.setNeedsLayout()
        offscreenCell.contentView.layoutIfNeeded()
        let size = offscreenCell.contentView.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize)
        return size.height
    }
    
    // MARK: - UITextViewDelegate
    
    func textViewShouldBeginEditing(textView: UITextView) -> Bool {
        textView.textColor = UIColor.blackColor()
        return true
    }

    func textViewDidBeginEditing(textView: UITextView) {
        askAnotherQuestionTextView.text = ""
        adjustMessageTextViewSize(textView)
        isKeyboardVisible = true
        adjustAskAnotherQuestionTextViewBottomConstraint()
    }
    
    func textViewDidChange(textView: UITextView) {
        adjustMessageTextViewSize(textView)
    }
    
    func textViewDidEndEditing(textView: UITextView) {
        isKeyboardVisible = false
        adjustAskAnotherQuestionTextViewBottomConstraint()
    }
    
    // MARK: - Action
    
    @IBAction private func sendButtonTapped(sender: UIButton) {
        if askAnotherQuestionTextView.text.characters.count > 0 && askAnotherQuestionTextView.text != placeholderText {
            questions.append(askAnotherQuestionTextView.text)
            tableView.insertRowsAtIndexPaths([NSIndexPath(forRow: questions.count-1 , inSection: 0)], withRowAnimation: .Automatic)
            askAnotherQuestionTextView.text = ""
            adjustMessageTextViewSize(askAnotherQuestionTextView)
            adjustScrollFor(tableView, animated: true)
        }
    }
    
    @objc private func keyboardDismissAction(sender: AnyObject) {
        askAnotherQuestionTextView.resignFirstResponder()
    }
    
    // MARK: - Private
    
    private func setupAppearance() {
        profileView.layer.cornerRadius = profileView.bounds.size.width/2.0
        profileView.layer.borderWidth = 4.0
        profileView.layer.borderColor = CustomColors.hexStringToUIColor("8B95C9").CGColor
        
        askAnotherQuestionTextView.layer.cornerRadius = 8.0
        askAnotherQuestionTextView.layer.borderWidth = 1.0
        askAnotherQuestionTextView.layer.borderColor = UIColor.lightGrayColor().CGColor
        askAnotherQuestionTextView.textContainerInset = UIEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
        
        askAnotherQuestionTextView.text = placeholderText
    }
    
    private func adjustMessageTextViewSize(textView: UITextView) {
        let sizeThatFits = textView.sizeThatFits(CGSizeMake(textView.frame.size.width, CGFloat(MAXFLOAT)))
        askAnotherQuestionTextViewHeightContraint.constant = sizeThatFits.height
        textView.superview?.layoutIfNeeded()
        
        textView.layoutManager.allowsNonContiguousLayout = false
        textView.scrollRangeToVisible(textView.selectedRange)
        adjustScrollFor(tableView, animated: false)
    }
    
    private func adjustAskAnotherQuestionTextViewBottomConstraint() {
        textInputViewBottomToSuperviewConstraint.constant = isKeyboardVisible ? CGFloat(keyboardHeight!) : CGFloat(0.0)
        UIView.animateWithDuration(0.25, animations: { [unowned self] in
            self.textInputView.superview?.layoutIfNeeded()
            }) { [unowned self] (finished) in
                self.adjustScrollFor(self.tableView, animated: true)
        }
    }
    
    private func adjustScrollFor(tableView: UITableView, animated: Bool) {
        if questions.count > 0 {
            tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: questions.count-1 , inSection: 0), atScrollPosition: .Bottom, animated: animated)
        }
    }
    
    private func configureCell(cell: QuestionCell, forIndexPath indexPath: NSIndexPath) {
        cell.questionLabel.text = questions[indexPath.row]
    }
    
    @objc private func keyboardChangedFrame(notification: NSNotification) {
        if let info = notification.userInfo {
            let keyboardFrame = info[UIKeyboardFrameEndUserInfoKey] as? NSValue
            let keyboardRect = keyboardFrame?.CGRectValue()
            keyboardHeight = Double((keyboardRect?.size.height)!)
            adjustAskAnotherQuestionTextViewBottomConstraint()
        }
    }
}