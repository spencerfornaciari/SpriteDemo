//
//  SFMyScene.m
//  SpriteDemo
//
//  Created by Spencer Fornaciari on 2/17/14.
//  Copyright (c) 2014 Spencer Fornaciari. All rights reserved.
//

#import "SFMyScene.h"

static const uint32_t batmanCategory = 0x1 << 0;
static const uint32_t penguinCategory = 0x1 << 1;

@interface SFMyScene ()
{
    int _nextFlappy;
    double _nextFlappySpawn;
    int lives, score, time;
}

@property (nonatomic) SKSpriteNode *mainCharacter;
@property (nonatomic) NSMutableArray *flappyArray;
@property (nonatomic) SKLabelNode *label, *label2, *label3;

@end

#define kNumFlappys 10

@implementation SFMyScene

-(id)initWithSize:(CGSize)size {    
    if (self = [super initWithSize:size]) {
        /* Setup your scene here */
        
        self.physicsWorld.contactDelegate = self;
        //self.physicsWorld.
        
        self.label = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-CondensedMedium"];
        self.label.fontColor = [UIColor blackColor];
        self.label.name = @"lives";
        self.label.fontSize = 20;
        self.label.position = CGPointMake(50, 280);
        lives = 1;
        time = 0;
        
        self.label.text = [NSString stringWithFormat:@"Lives: %d", lives];
        
        self.label2 = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-CondensedMedium"];
        self.label2.fontColor = [UIColor blackColor];
        self.label2.name = @"score";
        self.label2.fontSize = 20;
        self.label2.position = CGPointMake(50, 260);
        
        score = 0;
        
        self.label2.text = [NSString stringWithFormat:@"Score: %d", score];

        self.label3 = [SKLabelNode labelNodeWithFontNamed:@"Helvetica-CondensedMedium"];
        self.label3.fontSize = 20;
        self.label3.name = @"time";
        self.label3.fontColor = [UIColor blackColor];
        self.label3.position = CGPointMake(50, 240);
        
        _nextFlappy = 0;
        
        self.physicsBody = [SKPhysicsBody bodyWithEdgeLoopFromRect:self.frame];
        
        for (int i = 0; i < 2; i++) {
            SKSpriteNode *bg = [SKSpriteNode spriteNodeWithImageNamed:@"background2.png"];
            bg.anchorPoint = CGPointZero;
            bg.size = self.size;
            bg.position = CGPointMake(i * bg.size.width, 0);
            bg.name = @"background";
            
            [self addChild:bg];
        }
        
        self.mainCharacter = [SKSpriteNode spriteNodeWithImageNamed:@"batman.png"];
        self.mainCharacter.position = CGPointMake(50, 150);
        self.mainCharacter.name = @"batman";
        
        [self addChild:self.mainCharacter];
        self.mainCharacter.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:self.mainCharacter.size];
        self.mainCharacter.physicsBody.categoryBitMask = batmanCategory;
        self.mainCharacter.physicsBody.allowsRotation = NO;
        self.mainCharacter.physicsBody.usesPreciseCollisionDetection = TRUE;
        self.mainCharacter.physicsBody.collisionBitMask = penguinCategory;
        //self.mainCharacter.physicsBody.contactTestBitMask = penguinCategory;
        
        //self.mainCharacter.physicsBody.dynamic = YES;
        //self.mainCharacter.physicsBody.affectedByGravity = YES;
        self.mainCharacter.physicsBody.mass = 0.02;
        
        self.flappyArray = [[NSMutableArray alloc] initWithCapacity:kNumFlappys];
        
        for (int i = 0; i < kNumFlappys; i++) {
            SKSpriteNode *flappy = [SKSpriteNode spriteNodeWithImageNamed:@"penguin.png"];
            flappy.hidden = YES;
            flappy.physicsBody = [SKPhysicsBody bodyWithRectangleOfSize:flappy.size];
            flappy.physicsBody.categoryBitMask = penguinCategory;
            flappy.physicsBody.collisionBitMask = batmanCategory;
            //flappy.physicsBody.contactTestBitMask = batmanCategory;
            flappy.physicsBody.dynamic = NO;
            [self.flappyArray addObject:flappy];
            flappy.position = CGPointMake(1000, 300);
            [self addChild:flappy];
           
            
     
        
        }
        
            [self addChild:self.label];
            [self addChild:self.label2];
            [self addChild:self.label3];
    }
    return self;
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    /* Called when a touch begins */
    
    [self.mainCharacter.physicsBody setVelocity:CGVectorMake(0, 0)];
    [self.mainCharacter.physicsBody applyImpulse:CGVectorMake(0, 7)];

}

-(float)randomValueBetween:(float)low andValue:(float)high
{
    return (((float) arc4random() / 0xFFFFFFFFu) * (high - low)) + low;
}

-(void)update:(CFTimeInterval)currentTime {
    /* Called before each frame is rendered */
    [self enumerateChildNodesWithName:@"background" usingBlock:^(SKNode *node, BOOL *stop) {
        SKSpriteNode * bg = (SKSpriteNode *)node;
        bg.position = CGPointMake(bg.position.x - 5, bg.position.y);
        
        if (bg.position.x <= -bg.size.width) {
            bg.position = CGPointMake(bg.position.x + bg.size.width * 2, bg.position.y);
        }
    }];
    
    double curTime = CACurrentMediaTime();
    
    if (curTime > _nextFlappySpawn) {
        float randSeconds = [self randomValueBetween:0.20f andValue:1.0f];
        _nextFlappySpawn = randSeconds + curTime;
        
        float randY = [self randomValueBetween:0.0f andValue:self.frame.size.height];
        float randDuration = [self randomValueBetween:5.0f andValue:8.0f];
        
        SKSpriteNode *flappy = self.flappyArray[_nextFlappy];
        _nextFlappy++;
        
        if (_nextFlappy >= self.flappyArray.count) {
            _nextFlappy = 0;
        }
        
        [flappy removeAllActions];

        //flappy.physicsBody.affectedByGravity = TRUE;
        
        
        flappy.position = CGPointMake(self.frame.size.width + flappy.size.width / 2, randY);
        flappy.hidden = NO;
        
        CGPoint location = CGPointMake(-600, randY);
        
        SKAction *moveAction = [SKAction moveTo:location duration:randDuration];
        SKAction *doneAction = [SKAction runBlock:^{
            flappy.hidden = YES;
        }];
        
        SKAction *moveFlappyActionWithDone = [SKAction sequence:@[moveAction, doneAction]];
        
        [flappy runAction:moveFlappyActionWithDone];
        
    }
    
    BOOL hurt = FALSE;
    
//    for (SKSpriteNode *flappy in self.flappyArray) {
//        if ([self.mainCharacter intersectsNode:flappy]) {
//            [self.mainCharacter removeFromParent];
//            
//            NSString *explosionPath = [[NSBundle mainBundle] pathForResource:@"SparkParticle" ofType:@"sks"];
//            SKEmitterNode *burstNode = [NSKeyedUnarchiver unarchiveObjectWithFile:explosionPath];
//            
//            burstNode.position = self.mainCharacter.position;
//            [self addChild:burstNode];
//            hurt = TRUE;
//            
//            [SKAction removeFromParent];
//            
//            break;
//        }
    //}

    time++;
    
    if (time % 5 == 0) {
        score++;
        self.label2.text = [NSString stringWithFormat:@"Score: %d", score / 35];

    }
    int addLife = (time / 60) % 5;
    if (!addLife == 0) {
        //lives++;
        //self.label.text = [NSString stringWithFormat:@"Livs: %d", lives/ 35];

    }
    
    self.label3.text = [NSString stringWithFormat:@"Time: %d", time / 35];
    
    if (hurt) {
        lives--;
    }
    if (lives > 0) {
        self.label.text = [NSString stringWithFormat:@"Lives: %d", lives];
    } else {
        self.label.text = @"LOSER";
    }
}

-(void)didBeginContact:(SKPhysicsContact *)contact
{
    NSLog(@"Contact");
}


@end
