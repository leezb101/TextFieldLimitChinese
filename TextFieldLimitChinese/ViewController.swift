//
//  ViewController.swift
//  TextFieldLimitChinese
//
//  Created by leezb101 on 2018/3/30.
//  Copyright © 2018年 luohe. All rights reserved.
//
//  这是一篇博客文章，确实解决了很大的问题，也打开了一些思路，所以记录一下，用代码的形式
//  http://www.hangge.com/blog/cache/detail_1907.html

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var inputArea: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        NotificationCenter.default.addObserver(self, selector: #selector(inputAreaTextDidChange(noti:)), name: NSNotification.Name.UITextFieldTextDidChange, object: inputArea)

    }
    
    @objc func inputAreaTextDidChange(noti: NSNotification) {
        
        let textField = noti.object as! UITextField
        textField.textColor = .black
        guard textField === inputArea else { return }
        guard let _: UITextRange = textField.markedTextRange else {
            // 判断输入框里已经没有待用户确认的拼音内容字符串（即输入框中输入拼音时灰色的字母部分）
            let cursorPosition = textField.offset(from: textField.endOfDocument, to: textField.selectedTextRange!.end) // 当前输入框光标的位置
            let pattern = "[^\\u4E00-\\u9FA5]" // 判断不是中文的正则
            var replacedStr = textField.text!.pregReplace(pattern: pattern, with: "")
            guard !replacedStr.hasPrefix("ReplaceError:")  else {
                return
            }
            if replacedStr.count > 5 {
                replacedStr = String(replacedStr.prefix(5))
                textField.textColor = .red
            }
            textField.text = replacedStr
            // 通过之前拿到的光标的offset，从文字末尾开始往回找到光标该存在的地方
            let finalPosition = textField.position(from: textField.endOfDocument, offset: cursorPosition)!
            textField.selectedTextRange = textField.textRange(from: finalPosition, to: finalPosition)
            
            return
        }
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        let touch = (touches as NSSet).anyObject() as! UITouch
        let point = touch.location(in: view)
        if !inputArea.point(inside: point, with: event) {
            inputArea.resignFirstResponder()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self, name: .UITextFieldTextDidChange, object: inputArea)
    }
}

extension String {
    func pregReplace(pattern: String, with: String, options: NSRegularExpression.Options = []) -> String {
        do {
            let regex = try NSRegularExpression(pattern: pattern, options: options)
            return regex.stringByReplacingMatches(in: self, options: [], range: NSMakeRange(0, self.count), withTemplate: with)
        } catch {
            return "ReplaceError:" + error.localizedDescription
        }
    }
}

