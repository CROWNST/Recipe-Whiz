//
//  CustomCollectionViewCell.swift
//  TinyChef
//
//  Created by David Hsieh on 1/4/22.
//

import UIKit

class CustomCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var statusTextView: UITextView!
    
    @IBOutlet weak var titleTextView: UITextView!
    
    @IBOutlet weak var infoTextView: UITextView!
    
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    @IBOutlet weak var detailTextView: UITextView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        titleTextView.textContainer.lineBreakMode = .byTruncatingTail
        infoTextView.textContainer.lineBreakMode = .byTruncatingTail
        titleTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0.0, bottom: 0.0, right: 0.0)
        infoTextView.textContainerInset = UIEdgeInsets(top: 0, left: 0.0, bottom: 0.0, right: 0.0)
        detailTextView.alpha = 0
        setupGestureRecognition(titleTextView, showDetail: true)
        setupGestureRecognition(infoTextView, showDetail: true)
        setupGestureRecognition(detailTextView, showDetail: false)
        
        contentView.layer.cornerRadius = 7.0
        contentView.layer.masksToBounds = true
        layer.cornerRadius = 7.0
        layer.masksToBounds = false
        
        layer.shadowRadius = 8.0
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.50
        layer.shadowOffset = CGSize(width: 0, height: 5)
    }
    
    fileprivate func setupGestureRecognition(_ textView: UITextView, showDetail: Bool) {
        let tapRecogniser: UITapGestureRecognizer!
        if (showDetail) {
            tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(showDetail(_:)))
        } else {
            tapRecogniser = UITapGestureRecognizer(target: self, action: #selector(hideDetail(_:)))
        }
        textView.addGestureRecognizer(tapRecogniser)
    }
    
    @objc func showDetail(_ sender: Any) {
        let infoComponents = infoTextView.text.components(separatedBy: "min ")
        let minutesString = "\(infoComponents[0])min"
        let servingsString = infoComponents[1]
        detailTextView.text = "\(titleTextView.text!)\n\n\(minutesString)\n\(servingsString)"
        titleTextView.isHidden = true
        infoTextView.isHidden = true
        UIView.animate(withDuration: 0.2) {
            self.detailTextView.alpha = 0.85
        }
    }
    
    @objc func hideDetail(_ sender: Any) {
        titleTextView.isHidden = false
        infoTextView.isHidden = false
        UIView.animate(withDuration: 0.2) {
            self.detailTextView.alpha = 0.0
        }
    }
}
