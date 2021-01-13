//
//  ViewController.m
//  CardShuffleAnimation
//
//  Created by LiaoYun on 2021/1/12.
//

#import "ViewController.h"

typedef enum : NSUInteger {
    CardAnimationType_Shuflle = 0,
    CardAnimationType_Sort,
    CardAnimationType_BySuit,
    CardAnimationType_Fan,
    CardAnimationType_Poker,
    CardAnimationType_Group,
} CardAnimationType;

@interface ViewController ()
//存放卡牌容器
@property (nonatomic, strong) NSMutableArray *cardViewArr;
//存放所有卡牌容器原始坐标
@property (nonatomic, strong) NSMutableArray *cardViewFrameArr;
//存放卡牌图片的下标
@property (nonatomic, strong) NSMutableArray *indexArr;

//用来标记是否正处在动画中
@property (nonatomic, assign) BOOL isAnimating;

//用来标记当前的动画类型
@property (nonatomic, assign) CardAnimationType currentAnimateType;
//用来标记随机洗牌的重复次数
@property (nonatomic, assign) int randomShuffleNum;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createCards];
    
}

//创建卡组
-(void)createCards
{
    _cardViewArr = [NSMutableArray new];
    _cardViewFrameArr = [NSMutableArray new];
    _indexArr = [NSMutableArray new];
    //默认从屏幕正中央开始堆叠
    CGFloat cardWHScale = 336.0/560.0;  //卡片的宽高比
    CGFloat x = 0.5;    //平均偏移x
    CGFloat y = 0.5;    //平均偏移y
    CGFloat cardW = 60;
    CGFloat cardH = cardW/cardWHScale;
    CGFloat centerMinX = (kScreenWidth - cardW)/2;
    CGFloat centerMinY = (kScreenHeight - cardH)/2;
    for (int i = 0; i < 22; i ++) {
        UIImageView *card = [[UIImageView alloc]initWithFrame:CGRectMake(centerMinX - x*i, centerMinY - y*i, cardW, cardH)];
//        card.layer.borderWidth = 0.5;
//        card.layer.borderColor = Card_RGB(238, 238, 238, 1).CGColor;
        card.layer.cornerRadius = 3.5;
        card.layer.masksToBounds = YES;
        card.tag = i;
        card.image = [UIImage imageNamed:[NSString stringWithFormat:@"divination_cards_%d",i]];
        //添加右下边框,模拟卡牌堆叠阴影
        [card addRightBorderWithColor:Card_RGB(225, 225, 225, 1) andWidth:0.5];
        [card addBottomBorderWithColor:Card_RGB(135, 135, 135, 1) andWidth:0.5];
        
        [self.view addSubview:card];
        [_cardViewArr addObject:card];
        [_cardViewFrameArr addObject:NSStringFromCGRect(card.frame)];
        [_indexArr addObject:@(i)];
    }
    
}

//上方按钮点击事件
- (IBAction)touchToChangeAnimation:(IBButton *)sender {
    
    if (_isAnimating) {
        return;
    }
    _isAnimating = YES;
    switch (sender.tag) {
        case 1:
        {
            NSLog(@"Sort动画开始");
            _currentAnimateType = CardAnimationType_Sort;
            [self startCardAnimation_sort];
        }
            break;
        case 2:
        {
            NSLog(@"BySuit动画开始");
            _currentAnimateType = CardAnimationType_BySuit;
            [self startCardAnimation_bySuit];
        }
            break;
        case 3:
        {
            NSLog(@"Fan动画开始");
            _currentAnimateType = CardAnimationType_Fan;
            [self startCardAnimation_fan];
        }
            break;
        case 4:
        {
            NSLog(@"Poker动画开始");
            _currentAnimateType = CardAnimationType_Poker;
            [self startCardAnimation_poker];
        }
            break;
        case 5:
        {
            NSLog(@"Group动画开始");
            _currentAnimateType = CardAnimationType_Group;
            [self startCardAnimation_shuflle];
        }
            break;
        default:
        {
            NSLog(@"Shuflle动画开始");
            _currentAnimateType = CardAnimationType_Shuflle;
            [self startCardAnimation_shuflle];
        }
            break;
    }
    
}

#pragma mark --- 动画 ---

#pragma Shuflle
///Shuflle
-(void)startCardAnimation_shuflle
{
    [self reloadAllCardFrame];
    /*逻辑:
     1.左右各有多张拍进行移动,比如左边的,会向左移并还原,右边同理
     2.因为动画过快,慢放也不敢确定具体的切换逻辑
     3.目前简单的理一下,似乎是让所有的卡牌进行了x和y方向的平移
     4.平移动画开始时到回到起点的这个过程中快速的随机打乱卡牌顺序,似乎打乱了好几次
     5.将步骤3的操作重复一次即可
     */
    
    //1.快速让所有卡牌移动,并返回
    //随机x和y的范围
    CGFloat arcX = 0;
    CGFloat arcY = 0;
    
    for (int i = 0; i < _cardViewArr.count; i ++) {
        UIImageView *cardV = _cardViewArr[i];
        //设置个限制,单数向左,双数向右
        BOOL isEven = cardV.tag%2;
        if (isEven) {
            arcX = [self randomBetween:30.0 And:50.0];
        }else{
            arcX = [self randomBetween:-50.0 And:-30.0];
        }
        arcY = [self randomBetween:-5 And:5];
        
        //记录原来的位置
        CGPoint oldOrigin = cardV.frame.origin;
        
        NSDictionary *info = @{
            @"cardV" : cardV,
            @"frame" : NSStringFromCGPoint(oldOrigin),
            @"arcX"  : @(arcX),
            @"arcY"  : @(arcY),
            @"index" : @(i),
        };
        //间隔一点点时间再执行,可以有一个更好的视觉体验
        [self performSelector:@selector(positionAnimation:) withObject:info afterDelay:0.006*i];
        
    }
    
}

//修改卡牌原点的动画方法
-(void)positionAnimation:(NSDictionary *)info
{
    //总共有22张牌,就用取余的方式来决定具体打乱几次
    NSInteger animateNum = [info[@"index"] integerValue];
//    NSLog(@"第%ld次移动动画",animateNum);
    UIImageView *cardV = info[@"cardV"];
    CGPoint oldOrigin = CGPointFromString(info[@"frame"]);
    CGFloat arcX = [info[@"arcX"] floatValue];
    CGFloat arcY = [info[@"arcY"] floatValue];
    CGFloat cardW = CGRectGetWidth(cardV.frame);
    CGFloat cardH = CGRectGetHeight(cardV.frame);
    
    [UIView animateWithDuration:0.2 animations:^{
        
        cardV.frame = CGRectMake(oldOrigin.x + arcX, oldOrigin.y + arcY, cardW, cardH);
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.12 animations:^{
            cardV.frame = CGRectMake(oldOrigin.x, oldOrigin.y, cardW, cardH);
        } completion:^(BOOL finished) {
            BOOL changeSort = animateNum%6;
            if (changeSort) {
                //随机打乱下标顺序
                [self disruptCardSort:NO];
            }
            if (animateNum == 21) {
                self.randomShuffleNum ++;    //每次完结记得自增一下
                if (self.currentAnimateType == CardAnimationType_Shuflle) { //这个重复2次
                    if (self.randomShuffleNum == 2) {
                        NSLog(@"Shuflle动画完成");
                        self.isAnimating = NO;
                        self.randomShuffleNum = 0;
                    }else{
                        kGCDDelayDone(0.13, ^{
                            [self startCardAnimation_shuflle];  //重复执行
                        });
                    }
                }else if (self.currentAnimateType == CardAnimationType_Poker||self.currentAnimateType == CardAnimationType_Group) { //这个重复3次
                    if (self.randomShuffleNum == 3) {
                        self.randomShuffleNum = 0;
                        if (self.currentAnimateType == CardAnimationType_Group) {   //进入下一个动画
                            kGCDDelayDone(0.2, ^{
                                [self bySuitThanPutCard:0 completion:nil];
                                kGCDDelayDone(0.2, ^{
                                    [self bySuitThanPutCard:1 completion:nil];
                                });
                                kGCDDelayDone(0.4, ^{
                                    [self bySuitThanPutCard:2 completion:nil];
                                });
                            });
                        }else if (self.currentAnimateType == CardAnimationType_Poker) { //结束后有一个发牌的动画
                            kGCDDelayDone(0.4, ^{
                                [self pokerThanDealCardsAnimate];
                            });
                        }
                    }else{
                        kGCDDelayDone(0.13, ^{
                            [self startCardAnimation_shuflle];  //重复执行
                        });
                    }
                }
            }
        }];
    }];
}

#pragma Sort
///Sort
-(void)startCardAnimation_sort
{
    [self reloadAllCardFrame];
    
    [self cardJumpAnimationToSort];
}

//模拟跳跃动画,从最底下的卡牌开始向上垂直移动后回到起点,后面的依次延迟重复,最后所有卡牌的卡面恢复初始
-(void)cardJumpAnimationToSort
{
    for (int i = 0; i < self.cardViewArr.count; i ++) {
        [self performSelector:@selector(sortThanDelayMoveTop:) withObject:@(i) afterDelay:0.03*i];
    }
}

//sort 的延迟动画
-(void)sortThanDelayMoveTop:(NSNumber *)index
{
    int i = index.intValue;
    UIImageView *cardV = self.cardViewArr[i];
    
    //暂时让所有卡牌的y轴上升同一个距离
    CGFloat avgMoveY = 120;
    CGRect newRect = CGRectMake(CGRectGetMinX(cardV.frame), CGRectGetMinY(cardV.frame) - avgMoveY, CGRectGetWidth(cardV.frame), CGRectGetHeight(cardV.frame));
    CGRect oldRect = CGRectFromString(self.cardViewFrameArr[i]);
    
    [UIView animateWithDuration:0.25 animations:^{
        cardV.frame = newRect;
    } completion:^(BOOL finished) {
        if (i == 11) {
            [self disruptCardSort:self.currentAnimateType == CardAnimationType_Sort];
        }
        [UIView animateWithDuration:0.35 animations:^{
            cardV.frame = oldRect;
            
        } completion:^(BOOL finished) {
            if (i == 21) {
                
                if (self.currentAnimateType == CardAnimationType_BySuit) {
                    
                    [self bySuitThanPutCard:0 completion:nil];
                    kGCDDelayDone(0.2, ^{
                        [self bySuitThanPutCard:1 completion:nil];
                    });
                    kGCDDelayDone(0.4, ^{
                        [self bySuitThanPutCard:2 completion:nil];
                    });
                    
                }else if (self.currentAnimateType == CardAnimationType_Group){  //进入下一个动画
                    
                    kGCDDelayDone(0.2, ^{
                        [self startCardAnimation_fan];
                    });
                    
                }else{
                    NSLog(@"Sort动画完成");
                    self.isAnimating = NO;
                }
            }
        }];
    }];
}

#pragma By suit
///By suit
-(void)startCardAnimation_bySuit
{
    [self reloadAllCardFrame];

    [self cardJumpAnimationToSort];
}

//摆放方式:展示三行卡牌,形式如下
/*
 7
 8
 7
 */
-(void)bySuitThanPutCard:(NSInteger)tcb completion:(void(^)(void))finish
{
    UIImageView *topCardV = self.cardViewArr.lastObject;
    //分别计算上中下三组卡牌的中心点
    CGFloat cardCenterX = kScreenWidth/2;
    CGFloat centerCardCenterY = kScreenHeight/2;
    
    CGFloat avgY = 30;      //每行卡牌的距离
    CGFloat cardAvgX = 16;  //每张卡牌的间距
    
    CGFloat avgCardH = CGRectGetHeight(topCardV.frame);
    
    CGFloat topCardCenterY = centerCardCenterY - avgCardH - avgY;
    CGFloat bottomCardCenterY = centerCardCenterY + avgCardH + avgY;
    
    CGPoint centerPoint = CGPointZero;
    if (tcb == 0) {
        for (int i = 0; i < 7; i ++) {
            UIImageView *topCardV = self.cardViewArr[i];
            centerPoint = topCardV.center;
            if (i < 3) {
                centerPoint = CGPointMake(cardCenterX - cardAvgX*(3-i), topCardCenterY);
            }else if (i == 3) {
                centerPoint = CGPointMake(cardCenterX, topCardCenterY);
            }else{
                centerPoint = CGPointMake(cardCenterX + cardAvgX*(i-3), topCardCenterY);
            }
            
            NSDictionary *info = @{
                @"cardV" : topCardV,
                @"centerPoint" : NSStringFromCGPoint(centerPoint),
            };
            
            [self performSelector:@selector(bysuitThanDelayMove:) withObject:info afterDelay:0.02*i];
        }
    }else if (tcb == 1) {
        for (int i = 7; i < 15; i ++) {
            UIImageView *cardV = self.cardViewArr[i];
            centerPoint = cardV.center;
            if (i < 11) {
                centerPoint = CGPointMake(cardCenterX - cardAvgX*(10-i) - cardAvgX/2, centerCardCenterY);
            }else{
                centerPoint = CGPointMake(cardCenterX + cardAvgX*(i-11) + cardAvgX/2, centerCardCenterY);
            }
            
            NSDictionary *info = @{
                @"cardV" : cardV,
                @"centerPoint" : NSStringFromCGPoint(centerPoint),
            };
            
            [self performSelector:@selector(bysuitThanDelayMove:) withObject:info afterDelay:0.02*(i-7)];
        }
    }else if (tcb == 2) {
        for (int i = 15; i < 22; i ++) {
            UIImageView *cardV = self.cardViewArr[i];
            centerPoint = cardV.center;
            if (i < 18) {
                centerPoint = CGPointMake(cardCenterX - cardAvgX*(18-i), bottomCardCenterY);
            }else if (i == 18) {
                centerPoint = CGPointMake(cardCenterX, bottomCardCenterY);
            }else{
                centerPoint = CGPointMake(cardCenterX + cardAvgX*(i-18), bottomCardCenterY);
            }
            
            NSDictionary *info = @{
                @"cardV" : cardV,
                @"centerPoint" : NSStringFromCGPoint(centerPoint),
            };
            
            [self performSelector:@selector(bysuitThanDelayMove:) withObject:info afterDelay:0.02*(i-15)];
        }
    }
    
}

//sort 的延迟动画
-(void)bysuitThanDelayMove:(NSDictionary *)info
{
    UIImageView *cardV = info[@"cardV"];
    CGPoint centerPoint = CGPointFromString(info[@"centerPoint"]);
    
    [UIView animateWithDuration:0.3 animations:^{
        cardV.center = centerPoint;
    } completion:^(BOOL finished) {
        if (cardV.tag == 21) {
            if (self.currentAnimateType == CardAnimationType_BySuit) {
                NSLog(@"By suit动画完成");
                self.isAnimating = NO;
            }else if (self.currentAnimateType == CardAnimationType_Group) { //再进入下一个动画

                kGCDDelayDone(0.2, ^{
                    [self startCardAnimation_sort];
                });
            }
        }
    }];
}

#pragma Fan
///Fan
-(void)startCardAnimation_fan
{
    [self reloadAllCardFrame];

    kGCDDelayDone(0.25, ^{
        
        [self fanThanLeftCircle];
        
        [self fanThanRightCircle];
    });
}

//以最底层卡片宽度中点为锚点,进行扇形扩散
-(void)fanThanLeftCircle
{
    for (int i = 0; i < self.cardViewArr.count/2; i++) {
        
        NSDictionary *info = @{
            @"carV" : self.cardViewArr[i],
            @"index": @(i),
            @"isLeft" : @(YES),
        };
        
        [self performSelector:@selector(changeCardPointAndTransform:) withObject:info afterDelay:0.008*i];
    }
}

-(void)fanThanRightCircle
{
    for (int i = (int)self.cardViewArr.count/2; i < self.cardViewArr.count; i++) {
        
        NSDictionary *info = @{
            @"carV" : self.cardViewArr[i],
            @"index": @(i),
            @"isLeft" : @(NO),
        };
        
        [self performSelector:@selector(changeCardPointAndTransform:) withObject:info afterDelay:0.008*i];
    }
}

//修改卡片的弧度和位置
-(void)changeCardPointAndTransform:(NSDictionary *)info
{
    
    BOOL isLeft = [info[@"isLeft"] boolValue];
    
    UIImageView *cardV = info[@"carV"];
    NSInteger index = cardV.tag;
    //计算弧度
    float angle = 0.0;
    if (isLeft) {
        NSInteger currentNum = index+1 - (self.cardViewArr.count/2);
        angle = M_PI * (0.04 * currentNum - 0.02);
    }else{
        NSInteger currentNum = index - (self.cardViewArr.count/2);
        angle = M_PI * (0.02 + 0.04 * currentNum);
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        //移动的同时统一frame,这样视觉差就看不出来卡牌原点其实全部叠在同一个点了
        cardV.frame = CGRectFromString(self.cardViewFrameArr.firstObject);
        CGPoint oldOrigin = cardV.frame.origin;
        if (isLeft) {
            cardV.layer.anchorPoint = CGPointMake(0.5, 1);
        }else{
            cardV.layer.anchorPoint = CGPointMake(0.5, 1);
        }
        //替换锚点后,frame会发生变化
        CGPoint newOrigin = cardV.frame.origin;
        
        CGPoint transition;
        transition.x = newOrigin.x - oldOrigin.x;
        transition.y = newOrigin.y - oldOrigin.y;
        
        cardV.center = CGPointMake (cardV.center.x - transition.x, cardV.center.y - transition.y);
        
        
        cardV.transform = CGAffineTransformMakeRotation(angle);

    } completion:^(BOOL finished) {
        if (index == 21) {
            if (self.currentAnimateType == CardAnimationType_Fan) {
                NSLog(@"Fan动画完成");
                self.isAnimating = NO;
                
            }else if (self.currentAnimateType == CardAnimationType_Group) { //进入下一个动画
                
                kGCDDelayDone(0.2, ^{
                    [self reloadCardToBack];
                });
            }
        }
    }];
}

#pragma Poker
///Poker
-(void)startCardAnimation_poker
{
    [self startCardAnimation_shuflle];
}

//重复3次随机洗牌后,将卡组最上面的5张卡牌从左至右发到上方的空位
-(void)pokerThanDealCardsAnimate
{
    //计算5张卡牌的新位置
    UIImageView *topCardV = self.cardViewArr.lastObject;
    
    CGFloat cardW = CGRectGetWidth(topCardV.frame);
    CGFloat cardH = CGRectGetHeight(topCardV.frame);
    CGFloat topCardY = CGRectGetMinY(topCardV.frame) - cardH - 20;
    CGFloat lrX = 20;   //左右边距
    int cardNum = 5;    //卡牌数量
    CGFloat avgX = (kScreenWidth - cardW*cardNum - lrX*2)/(cardNum - 1); //卡牌平均间距
    
    int count = (int)self.cardViewArr.count - 1;
    int add = 0;
    for (int i = count; i > count - 5; i --) {
        UIImageView *cardV = self.cardViewArr[i];
        CGRect newFrame = CGRectMake(lrX + (cardW + avgX)*add, topCardY, cardW, cardH);
        
        NSDictionary *info = @{
            @"cardV" : cardV,
            @"newFrame" : NSStringFromCGRect(newFrame),
            @"add"  : @(add),
        };
        
        [self performSelector:@selector(pokerThanDelayMoveTopCard:) withObject:info afterDelay:0.2*add];
        
        add ++;
    }
    
}

//延时移动卡牌
-(void)pokerThanDelayMoveTopCard:(NSDictionary *)info
{
    UIImageView *cardV = info[@"cardV"];
    CGRect newFrame = CGRectFromString(info[@"newFrame"]);
    int add = [info[@"add"] intValue];
    [UIView animateWithDuration:0.2 animations:^{
        cardV.frame = newFrame;
        
    } completion:^(BOOL finished) {
        if (add == 4) {
            NSLog(@"Poker动画完成");
            self.isAnimating = NO;
        }
    }];
}

#pragma 其他处理方法
//打乱卡牌顺序(yes代表正序,no代表随机打乱)
-(void)disruptCardSort:(BOOL)sort
{
    if (sort) { //回正
        [self.indexArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            return [obj1 compare:obj2];
        }];
        
    }else{
        //随机打乱下标顺序
        [self.indexArr sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
            
            NSInteger randomResult = (NSInteger)arc4random() % 3 - 1;
            
            return randomResult;
            
        }];
    }
//    NSLog(@"排序完成:%@",self.indexArr);
    
    for (int i = 0; i < self.cardViewArr.count; i ++) {
        UIImageView *cardV = self.cardViewArr[i];
        NSNumber *nub = self.indexArr[i];
        int index = nub.intValue;
        //替换图片
        cardV.image = [UIImage imageNamed:[NSString stringWithFormat:@"divination_cards_%d",index]];
    }
}

//还原所有卡牌的原始位置
-(void)reloadAllCardFrame
{
    for (int i = 0; i < self.cardViewArr.count; i ++) {
        UIImageView *cardV = self.cardViewArr[i];
        NSNumber *imgIndex = self.indexArr[i];
        cardV.image = [UIImage imageNamed:[NSString stringWithFormat:@"divination_cards_%d",imgIndex.intValue]];
        CGRect oldRect = CGRectFromString(self.cardViewFrameArr[i]);
        
        [UIView animateWithDuration:0.2 animations:^{
            cardV.transform = CGAffineTransformIdentity;
            cardV.frame = oldRect;
        }];
    }
}

//让卡牌变成背面朝上
-(void)reloadCardToBack
{
    for (int i = 0; i < self.cardViewArr.count; i ++) {
        UIImageView *cardV = self.cardViewArr[i];
        CGRect oldRect = CGRectFromString(self.cardViewFrameArr[i]);
        [self animateToShowCard:i];
        [UIView animateWithDuration:0.2 animations:^{
            cardV.transform = CGAffineTransformIdentity;
            cardV.frame = oldRect;
        } completion:^(BOOL finished) {
            if (i == 21) {  //进入发牌动画
                kGCDDelayDone(0.2, ^{
                    [self newShowCardView];
                });
            }
        }];
    }
}

//最后的卡片发牌布局
-(void)newShowCardView
{
    NSLog(@"开始发牌动画");
    for (int i = 1; i <= 22; i++) {
        
        UIImageView *cardV = self.cardViewArr[i-1];
        
        [self performSelector:@selector(transformCards:) withObject:cardV afterDelay:0.05*(i-1)];
        
    }
}

//塔罗牌布局动画
-(void)transformCards:(UIImageView *)cardV
{
    float angle;
    CGFloat cardH = CGRectGetHeight(cardV.frame);
    float radius = cardH + 20;//半径
    
    NSInteger index = cardV.tag;
    //计算弧度
    angle = (225 + (90/22)*(index + 1));
    //弧度转角度,再通过三角函数计算x和y
    CGFloat x = radius * cosf(angle * M_PI/180);
    CGFloat y = radius * sinf(angle * M_PI/180);
    
    [UIView animateWithDuration:0.12 animations:^{
        CGPoint center = CGPointMake(self.view.center.x + x, self.view.center.y + y);
        cardV.center = center;
        
        CGFloat angle2 = 0.0;
        if (index<11) {
            angle2 = - M_PI_2*(11-index)/22;
        }else if (index>=11){
            angle2 = M_PI_2*(index-10)/22;
        }
        cardV.transform = CGAffineTransformMakeRotation(angle2);
        
    } completion:^(BOOL finished) {
        if (index == 21) {
            NSLog(@"Group动画完成");
            self.isAnimating = NO;
        }
    }];
}

//设置图片时渐变动画
-(void)animateToShowCard:(NSInteger)index
{
    //创建转换动画
    CATransition *transition = [CATransition animation];
    transition.type = kCATransitionFade;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.duration = 0.3f;
    
    UIImageView *cardV = self.cardViewArr[index];
    
    [cardV.layer addAnimation:transition forKey:@"trans"];
    
    cardV.image = [UIImage imageNamed:@"divination_backCard"];
    
}

//某个范围内的随机浮点数
- (float)randomBetween:(float)smallerNumber And:(float)largerNumber
{
    //设置精确的位数
    int precision = 100;
    //先取得他们之间的差值
    float subtraction = largerNumber - smallerNumber;
    //取绝对值,ABS整数绝对值
    subtraction = ABS(subtraction);
    //乘以精度的位数
    subtraction *= precision;
    //在差值间随机
    float randomNumber = arc4random() % ((int)subtraction+1);
    //随机的结果除以精度的位数
    randomNumber /= precision;
    //将随机的值加到较小的值上
    float result = MIN(smallerNumber, largerNumber) + randomNumber;
    //返回结果
    return result;
}

@end
