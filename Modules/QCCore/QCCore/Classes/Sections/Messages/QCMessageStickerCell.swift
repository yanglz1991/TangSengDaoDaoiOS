//
//  QCMessageSticker.swift
//  QCCore
//
//  Created by tt on 2022/6/18.
//

import Foundation


let lottieImgSize  = CGSize(width: 150.0, height: 150.0)

public class QCMessageStickerCell:QCMessageCell {
    let animatedStickerNode = AnimatedStickerNode(useMetalCache: false)
    let placeholderNode =  StickerShimmerEffectNode()
    public override class func contentSize(forMessage model: QCMessageModel) -> CGSize {
        return lottieImgSize
    }
    public override func prepareForReuse() {
        super.prepareForReuse()
        self.animatedStickerNode.stop()
    }
    
    public override func onWillDisplay() {
        super.onWillDisplay()
        animatedStickerNode.playIfNeeded()
    }
    
    public override func onEndDisplay() {
        super.onEndDisplay()
        animatedStickerNode.pause()
    }
    
    public override func initUI() {
        super.initUI()
        self.tailWrap = true
        
        self.placeholderNode.isUserInteractionEnabled = false
        self.animatedStickerNode.alpha = 0.0
        
        self.messageContentView.addSubnode(animatedStickerNode)
        
        self.messageContentView.bringSubviewToFront(self.trailingView)
        
        animatedStickerNode.updateLayout(size:lottieImgSize)
        animatedStickerNode.started = {[weak self] in
            if let strongSelf = self {
                if !strongSelf.placeholderNode.alpha.isZero {
                    strongSelf.animatedStickerNode.layer.animateAlpha(from: 0.0, to: 1.0, duration: 0.2)
                    strongSelf.removePlaceholder(animated: true)
                }
               
            }
        }
       
    }
    
    public override func refresh(_ model: QCMessageModel) {
        super.refresh(model)
        
//        self.placeholderNode.
        let content = model.content as! QCLottieStickerContent
        animatedStickerNode.setup(source: QCAnimatedStickerResourceSource(downloadURL: content.url), width: Int(lottieImgSize.width*2), height: Int(lottieImgSize.height*2),playbackMode: .loop, mode: .direct(cachePathPrefix: "sticker_"))
        
        
    }
    
    public override func layoutSubviews() {
        super.layoutSubviews()
       
    }
    
    private func removePlaceholder(animated: Bool) {
        self.placeholderNode.alpha = 0.0
        if !animated {
            self.placeholderNode.removeFromSupernode()
        } else {
            self.placeholderNode.layer.animateAlpha(from: 1.0, to: 0.0, duration: 0.2, completion: { [weak self] _ in
                self?.placeholderNode.removeFromSupernode()
            })
        }
    }
  
    public override class func hiddenBubble() -> Bool {
        return true
    }

}
