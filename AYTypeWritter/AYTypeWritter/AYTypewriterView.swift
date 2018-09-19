//
//  AYTypeWritterLabel.swift
//  AYTypeWritter
//
//  Created by Anson Yao on 2018-09-05.
//  Copyright © 2018 Anson Yao. All rights reserved.
//

import UIKit

//TODO
protocol AYTypeWriterLabelDelegate: class {
    func animationFinished()
}

public class AYTypewriterView: UIView {
    public var shouldPlayTypingSound = false //TODO
    
    public var shouldShowCursor = true
    ///Will use the default cursor if cursorImage is unspecified.
    public var cursorImage: UIImage? = nil
    ///Will use white color if unspecified
    public var cursorColor: UIColor? = nil
    ///Will use default size if unsepficied
    public var cursorSize: CGSize? = nil
    
    ///The interval between characters are typed. Unit is second.
    public var typingInterval = 0.3
    ///Add some randomness for the typing interval, which will make it feel like a real typewritter. 🤓
    public var randomTypingInterval = 0.3
    
    public let label = UILabel()
    private let displayingLabel = UILabel()
    private let defaultcursorWidth = 8.0
    private let defaultcursorHeight = 18.0
    
    private var originalAttributedString: NSAttributedString {
        return label.attributedText ?? NSAttributedString()
    }
    private var locationArray: [Int] {
        return originalAttributedString.string.enumerated().map({$0.0})
    }
    private var currentLocation: Int {
        if currentLocationIndex >= locationArray.count {
            return 0
        } else {
            return locationArray[currentLocationIndex]
        }
    }
    
    private var isAttributedStringSet = false
    private var timer: Timer?
    private var currentLocationIndex = 0
    private var paused = false
    
    //MARK: - Init
    public override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        self.addSubview(label)
        self.addSubview(displayingLabel)
        addConstraintsToFillParent(label)
        addConstraintsToFillParent(displayingLabel)
        label.isHidden = true
        displayingLabel.textAlignment = NSTextAlignment.center
    }

    //MARK: - Actions
    public func startAnimation() {
        resetAnimation()
        setTimerToPrintNextCharacter()
    }
    
    public func setTimerToPrintNextCharacter() {
        timer = Timer.scheduledTimer(withTimeInterval: getNextInterval(), repeats: false, block: { [weak self] (timer) in
            guard let strongSelf = self else { return }
            if strongSelf.paused {
                strongSelf.setTimerToPrintNextCharacter()
            } else {
                strongSelf.isHidden = false
                if strongSelf.currentLocation == strongSelf.locationArray.count - 1 {
                    strongSelf.finishAnimation()
                } else {
                    strongSelf.animate(location: strongSelf.currentLocation)
                    strongSelf.currentLocationIndex += 1
                    strongSelf.setTimerToPrintNextCharacter()
                }
            }
        })
    }
    
    public func pauseAnimation() {
        paused = true
    }
    
    public func resumeAnimation() {
        paused = false
    }
    
    public func finishAnimation() {
        timer?.invalidate()
        timer = nil
        animate(index: originalAttributedString.string.endIndex)
    }
    
    public func clearAnimation() {
        resetAnimation()
        self.animate(index: originalAttributedString.string.startIndex)
    }
    
    private func resetAnimation() {
        if currentLocationIndex != 0 {
            currentLocationIndex = 0
        }
        timer?.invalidate()
        timer = nil
        paused = false
    }
    
    deinit {
        timer?.invalidate()
        timer = nil
    }
    
    //MARK: - Private Helper
    private func animate(location: Int) {
        let text = originalAttributedString.string
        let startIndex = originalAttributedString.string.startIndex
        let index = text.index(startIndex, offsetBy: location)
        animate(index: index)
    }
    
    private func animate(index: String.Index) {
        let startIndex = originalAttributedString.string.startIndex
        let endIndex = originalAttributedString.string.endIndex
        
        let combinedAttributedString = NSMutableAttributedString()
        let showingAttributedString = subAttributedString(from: startIndex, to: index, attributedString: originalAttributedString)
        let hidingAttributedStringOriginal = subAttributedString(from: index, to: endIndex, attributedString: originalAttributedString)
        let hidingAttributedStringMutable = NSMutableAttributedString(attributedString: hidingAttributedStringOriginal)
        let range = hidingAttributedStringMutable.string.startIndex..<hidingAttributedStringMutable.string.endIndex
        hidingAttributedStringMutable.addAttributes([
                NSAttributedStringKey.foregroundColor : UIColor.clear,
                NSAttributedStringKey.strikethroughColor : UIColor.clear,
                NSAttributedStringKey.underlineColor : UIColor.clear
            ], range: NSRange(range, in: hidingAttributedStringMutable.string))
        let hidingAttributedString = hidingAttributedStringMutable as NSAttributedString
        combinedAttributedString.append(showingAttributedString)
        if shouldShowCursor {
            combinedAttributedString.append(getcursorString(hidden: hidingAttributedString.string.isEmpty))
        }
        combinedAttributedString.append(hidingAttributedString)
        displayingLabel.attributedText = combinedAttributedString
    }
    
    private func getcursorString(hidden: Bool) -> NSAttributedString {
        let attachment = NSTextAttachment()
        let cursorColor = self.cursorColor ?? UIColor.red
        let cursorImage = hidden ? UIImage.from(color: UIColor.clear) : (self.cursorImage ?? UIImage.from(color: cursorColor))
        let cursorSize = self.cursorSize.map({CGRect(x: 0.0, y: displayingLabel.font.descender, width: $0.width, height: $0.height)}) ?? CGRect(x: 0.0, y: Double(displayingLabel.font.descender), width: defaultcursorWidth, height: defaultcursorHeight)
        attachment.image = cursorImage
        attachment.bounds = cursorSize
        return NSAttributedString(attachment: attachment)
    }
    
    private func subAttributedString(from startIndex: String.Index, to endIndex: String.Index, attributedString: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString()
        let string = attributedString.string
        for (location, _) in string[startIndex..<endIndex].enumerated() {
            let index = string.index(startIndex, offsetBy: location)
            let tmp = NSAttributedString(string: String(string[index]), attributes: attributedString.attributes(at: location, effectiveRange: nil))
            result.append(tmp)
        }
        return result
    }

    private func addConstraintsToFillParent(_ view: UIView) {
        guard let parentView = view.superview else { return }
        view.translatesAutoresizingMaskIntoConstraints = false
        let constraintLeft = NSLayoutConstraint(item: view, attribute: .left, relatedBy: .equal, toItem: parentView, attribute: .left, multiplier: 1.0, constant: 0.0)
        let constraintRight = NSLayoutConstraint(item: view, attribute: .right, relatedBy: .equal, toItem: parentView, attribute: .right, multiplier: 1.0, constant: 0.0)
        let constraintTop = NSLayoutConstraint(item: view, attribute: .top, relatedBy: .equal, toItem: parentView, attribute: .top, multiplier: 1.0, constant: 0.0)
        let constraintBottom = NSLayoutConstraint(item: view, attribute: .bottom, relatedBy: .equal, toItem: parentView, attribute: .bottom, multiplier: 1.0, constant: 0.0)
        parentView.addConstraints([constraintLeft, constraintRight, constraintTop, constraintBottom])
    }
    
    private func getNextInterval() -> Double {
       return max(0.01, typingInterval + (Double(arc4random_uniform(256)) - 128) / 128.0 * randomTypingInterval)
    }
}

extension UIImage {
    static func from(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0, y: 0, width: 1, height: 1)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor)
        context!.fill(rect)
        let img = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return img!
    }
}
