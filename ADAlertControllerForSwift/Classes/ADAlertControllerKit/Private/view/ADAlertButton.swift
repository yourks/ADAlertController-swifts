//
//  ADAlertButton.swift
//  ADAlertController-swift
//
//  Created by apple on 2021/7/1.
//

import UIKit


class ADAlertButton: UIButton {
    
    init(title: String?, image: UIImage?, imagePosition: ButtonImagePosition = .top, imageSpace: CGFloat = 5) {
        super.init(frame: .zero)
        
        setBackgroundImage(UIImage.ad_imageWithTheColor(color: UIColor.white.withAlphaComponent(0)), for: .normal)
        setBackgroundImage(UIImage.ad_imageWithTheColor(color: UIColor.white.withAlphaComponent(0)), for: .highlighted)

        if image != nil, title != nil {
            setImage(image, for: .normal)
            setTitle(title, for: .normal)
            setImagePosition(postion: imagePosition, spacing: imageSpace)
        } else if image != nil {
            setImage(image, for: .normal)
        } else if title != nil {
            setTitle(title, for: .normal)
        }

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
