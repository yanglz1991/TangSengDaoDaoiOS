//
//  QCScanVC.h
//  QCCore
//
//  Created by tt on 2020/4/3.
//

#import <QCCore/QCCore.h>
#import <LBXScan/LBXScanViewController.h>
NS_ASSUME_NONNULL_BEGIN

@interface QCScanVC : LBXScanViewController

+(void) handleScanResult:(LBXScanResult*)result handlers:(NSArray<QCScanHandler*>*)handlers;

@end

NS_ASSUME_NONNULL_END
