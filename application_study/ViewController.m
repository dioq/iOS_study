#import "ViewController.h"
#import "NextViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"自己测试工程";
    
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeSystem];
    btn.frame = CGRectMake(10, 80, self.view.frame.size.width - 20, 45);
    [btn setTitle:@"点击测试" forState:UIControlStateNormal];
    btn.backgroundColor = [UIColor cyanColor];
    [btn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.view addSubview:btn];
    
    [btn addTarget:self action:@selector(click:) forControlEvents:UIControlEventTouchUpInside];
}

-(void)click:(UIButton *)button {
    UIAlertController *alterCtrl = [UIAlertController alertControllerWithTitle:@"点击提示" message:@"纯代码编译" preferredStyle:UIAlertControllerStyleAlert] ;
    UIAlertAction *alterAction = [UIAlertAction actionWithTitle:@"在这个页面" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        NSLog(@"什么也不做");
    }] ;
    UIAlertAction *alterAction2 = [UIAlertAction actionWithTitle:@"跳转到下个页面" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self jumpNextPage];
    }] ;
    [alterCtrl addAction:alterAction];
    [alterCtrl addAction:alterAction2];
    [self presentViewController:alterCtrl animated:YES completion:nil];
}

-(void)jumpNextPage {
    NextViewController *next = [[NextViewController alloc] initWithNibName:@"NextViewController" bundle:nil];
    [self.navigationController pushViewController:next animated:YES];
}

@end
