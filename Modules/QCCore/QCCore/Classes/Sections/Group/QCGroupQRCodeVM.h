//
//  QCGroupQRCodeVM.h
//  QCCore
//
//  Created by tt on 2020/4/3.
//

#import "QCBaseVM.h"
#import <QCIM/QCIM.h>
#import "QCCore.h"
NS_ASSUME_NONNULL_BEGIN

@interface QCGroupQRCodeInfoModel : QCModel

@property(nonatomic,assign) NSInteger day; // 几天过期
@property(nonatomic,copy) NSString *qrcode; // 二维码内容
@property(nonatomic,copy) NSString *expire; // 过期日期


@end


@interface QCGroupQRCodeVM : QCBaseVM

-(instancetype) initWithChannel:(QCChannel*)channel;


/// 请求获取二维码信息
-(AnyPromise*) requestGetQRCodeInfo;

@end

NS_ASSUME_NONNULL_END
