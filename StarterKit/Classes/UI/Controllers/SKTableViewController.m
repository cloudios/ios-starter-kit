//
// Created by Hammer on 1/19/16.
// Copyright (c) 2016 奇迹空间. All rights reserved.
//

#import <DZNEmptyDataSet/UIScrollView+EmptyDataSet.h>
#import <Masonry/MASConstraintMaker.h>
#import <Masonry/View+MASAdditions.h>
#import "SKTableViewController.h"
#import "SKTableViewCell.h"
#import "SKErrorResponseModel.h"
#import "SKFetchedResultsDataSource.h"
#import "SKFetchedResultsDataSourceBuilder.h"
#import "SKTableViewControllerBuilder.h"
#import <libextobjc/EXTScope.h>
#import <Overcoat/OVCResponse.h>
#import <HexColors/HexColors.h>
#import <DGActivityIndicatorView/DGActivityIndicatorView.h>
#import <UITableView_FDTemplateLayoutCell/UITableView+FDTemplateLayoutCell.h>
#import "SKManaged.h"
#import "SKLoadMoreTableViewCell.h"
#import "SKToastUtil.h"

static CGFloat const kIndicatorViewSize = 40.F;
#define kShowHideAnimateDuration 0.2

@interface SKTableViewController () <DZNEmptyDataSetSource, DZNEmptyDataSetDelegate>
@property(nonatomic, strong) DGActivityIndicatorView *indicatorView;

@property(nonatomic, copy) NSString *entityName;
@property(nonatomic, strong) Class modelOfClass;
@property(nonatomic, strong) NSMutableArray *cellMetadata;
@property(nonatomic, strong) SKPaginator *paginator;
@property(nonatomic, strong) AnyPromise *(^paginateBlock)(NSDictionary *parameters);

// optional
@property(nonatomic, copy) NSString *cellReuseIdentifier;
@property(nonatomic, copy) TGRDataSourceDequeueReusableCellBlock dequeueReusableCellBlock;
@property(nonatomic, copy) TGRDataSourceCellBlock configureCellBlock;
@property(nonatomic, copy) NSPredicate *predicate;

@end

@implementation SKTableViewController

- (void)createWithBuilder:(SKTableViewControllerBuilderBlock)block {
  NSParameterAssert(block);
  SKTableViewControllerBuilder *builder = [[SKTableViewControllerBuilder alloc] init];
  block(builder);
  [self initWithBuilder:builder];
}

- (void)initWithBuilder:(SKTableViewControllerBuilder *)builder {
  NSParameterAssert(builder);
  NSParameterAssert(builder.entityName);
  NSParameterAssert(builder.modelOfClass);
  NSParameterAssert(builder.cellMetadata);
  NSParameterAssert(builder.paginator);

  NSParameterAssert(builder.configureCellBlock);

  _entityName = builder.entityName;
  _modelOfClass = builder.modelOfClass;
  _paginator = builder.paginator;
  _paginator.delegate = self;
  _cellMetadata = [builder.cellMetadata mutableCopy];

  [self.cellMetadata addObject:[SKLoadMoreTableViewCell class]];
    
  _predicate = builder.predicate;
  
  _cellReuseIdentifier = builder.cellReuseIdentifier;
  _dequeueReusableCellBlock = builder.dequeueReusableCellBlock;
  _configureCellBlock = builder.configureCellBlock;

  // for core data entity name
  if ([_paginator isKindOfClass:[SKKeyPaginator class]]) {
    ((SKKeyPaginator *) _paginator).entityName = builder.entityName;
  }

  _paginateBlock = builder.paginateBlock;
  _httpSessionManager = [[SKManagedHTTPSessionManager alloc] initWithManagedObjectContext:[SKManaged sharedInstance].managedObjectContext];
}

- (void)viewDidLoad {
  [super viewDidLoad];
  [self setupTableView];
}

- (void)viewWillAppear:(BOOL)animated {
  [super viewWillAppear:animated];
  [self loadData];
}

- (void)viewDidDisappear:(BOOL)animated {
  [super viewDidDisappear:animated];

  if ([self isMovingFromParentViewController]) {
    [self cancelAllRequests];
  }

  if (self.refreshControl && self.refreshControl.isRefreshing) {
    [self.refreshControl endRefreshing];
  }
}

- (void)cancelAllRequests {
  [self.httpSessionManager invalidateSessionCancelingTasks:YES];
  _httpSessionManager = nil;
}

- (void)setupTableView {
  self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
  self.tableView.emptyDataSetSource = self;
  self.tableView.emptyDataSetDelegate = self;

  self.tableView.delegate = self;
    
  for (Class clazz in self.cellMetadata) {
    [self.tableView registerClass:clazz
           forCellReuseIdentifier:[clazz cellIdentifier]];
  }

  self.tableView.backgroundColor = [UIColor clearColor];
  [self setupDataSource];
  [self setupRefreshControl];
}

- (void)setupDataSource {
  @weakify(self);
  self.dataSource = [SKFetchedResultsDataSource createWithBuilder:^(SKFetchedResultsDataSourceBuilder *builder) {
    @strongify(self);
    builder.modelOfClass = [self modelOfClass];
    builder.entityName = [self entityName];
    builder.predicate = [self predicate];
    builder.dequeueReusableCellBlock = self.dequeueReusableCellBlock;
    builder.dequeueReusableCellBlock = ^NSString *(id item, NSIndexPath *indexPath) {
      id<NSFetchedResultsSectionInfo> sectionInfo = self.dataSource.fetchedResultsController.sections[indexPath.section];
      NSUInteger numbers = [sectionInfo numberOfObjects];
      if (self.paginator.hasMorePages && indexPath.item == numbers - 1) {
        return [SKLoadMoreTableViewCell cellIdentifier];
      }
      return self.dequeueReusableCellBlock(item, indexPath);
    };
    builder.configureCellBlock = self.configureCellBlock;
  }];
}

- (void)setupRefreshControl {
  self.refreshControl = [UIRefreshControl new];
  self.refreshControl.backgroundColor = [UIColor clearColor];
  [self.refreshControl addTarget:self action:@selector(refreshData) forControlEvents:UIControlEventValueChanged];
}

#pragma mark - IndicatorView Methods

- (void)setupIndicatorView {
  self.indicatorView = [[DGActivityIndicatorView alloc]
                        initWithType:DGActivityIndicatorAnimationTypeBallScale
                           tintColor:[UIColor redColor]
                                size:kIndicatorViewSize];
  [self.view addSubview:self.indicatorView];
  [self.indicatorView mas_makeConstraints:^(MASConstraintMaker *make) {
    make.center.mas_equalTo(self.view);
  }];
}

- (void)showIndicatorView {
  [self setupIndicatorView];
  [self.indicatorView startAnimating];
  [self.tableView reloadEmptyDataSet];
}

- (void)hideIndicatorView {
  if (_indicatorView) {
    [self.indicatorView stopAnimating];
    [self.indicatorView removeFromSuperview];
    _indicatorView = nil;
  }
}

- (void)shouldShowIndicatorView {
  if (self.paginator.isRefresh &&
      !self.paginator.hasDataLoaded &&
      [self.dataSource.fetchedResultsController.fetchedObjects count] <= 0) {
    [self showIndicatorView];
    return;
  }
  [self hideIndicatorView];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  id<NSFetchedResultsSectionInfo> sectionInfo = self.dataSource.fetchedResultsController.sections[section];
  NSUInteger numbers = [sectionInfo numberOfObjects];
  return numbers + 1;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
  id<NSFetchedResultsSectionInfo> sectionInfo = self.dataSource.fetchedResultsController.sections[indexPath.section];
  NSUInteger numbers = [sectionInfo numberOfObjects];
  if (self.paginator.hasMorePages && indexPath.item == numbers - 1) {
    [self loadMoreData];
  }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
  id item = [self.dataSource itemAtIndexPath:indexPath];
  NSString *cellIdentifier = self.dequeueReusableCellBlock(item, indexPath);
  // @weakify(self);
  return [tableView fd_heightForCellWithIdentifier:cellIdentifier cacheByIndexPath:indexPath
    configuration:^(SKTableViewCell *cell) {
      // 配置 cell 的数据源，和 "cellForRow" 干的事一致，比如：
      // @strongify(self);
      [cell configureCellWithData:item];
  }];
}


# pragma mark - SKPaginatorDelegate

- (void)networkOnStart:(BOOL)isRefresh {
  if (isRefresh) {
    [self shouldShowIndicatorView];
  }
}

- (AnyPromise *)paginate:(NSDictionary *)parameters {
  if (self.paginateBlock) {
    return self.paginateBlock(parameters);
  }
  return nil;
}

#pragma mark - Load data

- (void)refreshData {
  AnyPromise *promise = [self.paginator refresh];
  if (promise) {
    @weakify(self);
    promise.then(^(NSArray *result) {
      if (!result || result.count <= 0) {
        [SKToastUtil toastWithText:@"没有最新数据"];
      }
    }).catch(^(NSError *error) {
      @strongify(self);
      [self setupNetworkError:error isRefresh:YES];
    }).finally(^{
      @strongify(self);
      [self endRefresh];
    });
    return;
  }
  self.paginator.loading = NO;
  self.paginator.refresh = NO;
  [self.tableView reloadEmptyDataSet];
  [self shouldShowIndicatorView];
}

- (void)endRefresh {
  [self.refreshControl endRefreshing];
  [self.tableView reloadEmptyDataSet];
  [self shouldShowIndicatorView];
}

- (void)loadData {
  AnyPromise *promise = [self.paginator refresh];
  if (promise) {
    @weakify(self);
    promise.then(^(NSArray *result) {
      // Left Blank
    }).catch(^(NSError *error) {
      @strongify(self);
      [self setupNetworkError:error isRefresh:NO];
    }).finally(^{
      @strongify(self);
      [self.tableView reloadEmptyDataSet];
      [self shouldShowIndicatorView];
    });
    return;
  }
  self.paginator.loading = NO;
  self.paginator.refresh = NO;
  [self.tableView reloadEmptyDataSet];
  [self shouldShowIndicatorView];
}

- (void)loadMoreData {
  AnyPromise *promise = [self.paginator loadMore];
  if (promise) {
    @weakify(self);
    promise.then(^(NSArray *result) {
      if (!result || result.count <= 0) {
        [SKToastUtil toastWithText:@"没有更多数据"];
      }
    }).catch(^(NSError *error) {
      @strongify(self);
      [self setupNetworkError:error isRefresh:NO];
    }).finally(^{
        // TODO
      @strongify(self);
      [self.tableView reloadEmptyDataSet];
    });
    return;
  }
}

- (void)setupNetworkError:(NSError *)error isRefresh:(BOOL)isRefresh {
  NSDictionary *userInfo = [error userInfo];
  if (userInfo[@"NSUnderlyingError"]) {
    [SKToastUtil toastWithText:userInfo[@"NSLocalizedDescription"]];
    return;
  }
  OVCResponse *response = userInfo[@"OVCResponse"];
  SKErrorResponseModel *errorModel = response.result;
  [SKToastUtil toastWithText:errorModel.message];
}

#pragma mark - DZNEmptyDataSetSource Methods

- (NSAttributedString *)titleForEmptyDataSet:(UIScrollView *)scrollView {
  NSMutableDictionary *attributes = [NSMutableDictionary new];

  NSString *text = nil;
  UIFont *font = nil;
  UIColor *textColor = nil;

  text = @"No Photos";
  font = [UIFont boldSystemFontOfSize:17.0];
  textColor = [UIColor hx_colorWithHexString:@"545454"];

  if (!text) {
    return nil;
  }

  if (font) [attributes setObject:font forKey:NSFontAttributeName];
  if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];

  return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (NSAttributedString *)descriptionForEmptyDataSet:(UIScrollView *)scrollView {
  NSString *text = nil;
  UIFont *font = nil;
  UIColor *textColor = nil;

  NSMutableDictionary *attributes = [NSMutableDictionary new];

  NSMutableParagraphStyle *paragraph = [NSMutableParagraphStyle new];
  paragraph.lineBreakMode = NSLineBreakByWordWrapping;
  paragraph.alignment = NSTextAlignmentCenter;

  text = @"Get started by uploading a photo.";
  font = [UIFont boldSystemFontOfSize:15.0];
  textColor = [UIColor hx_colorWithHexString:@"545454"];

  if (!text) {
    return nil;
  }

  if (font) [attributes setObject:font forKey:NSFontAttributeName];
  if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];
  if (paragraph) [attributes setObject:paragraph forKey:NSParagraphStyleAttributeName];

  NSMutableAttributedString *attributedString = [[NSMutableAttributedString alloc] initWithString:text attributes:attributes];

  return attributedString;

}

- (UIImage *)imageForEmptyDataSet:(UIScrollView *)scrollView {
  NSString *imageName = @"Frameworks/StarterKit.framework/StarterKit.bundle/placeholder";

  return [UIImage imageNamed:imageName];
}

- (CAAnimation *)imageAnimationForEmptyDataSet:(UIScrollView *)scrollView {
  CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform"];
  animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
  animation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeRotation(M_PI_2, 0.0, 0.0, 1.0)];
  animation.duration = 0.25;
  animation.cumulative = YES;
  animation.repeatCount = MAXFLOAT;

  return animation;
}

- (NSAttributedString *)buttonTitleForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
  NSString *text = nil;
  UIFont *font = nil;
  UIColor *textColor = nil;

  if (!text) {
    return nil;
  }

  NSMutableDictionary *attributes = [NSMutableDictionary new];
  if (font) [attributes setObject:font forKey:NSFontAttributeName];
  if (textColor) [attributes setObject:textColor forKey:NSForegroundColorAttributeName];

  return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIImage *)buttonBackgroundImageForEmptyDataSet:(UIScrollView *)scrollView forState:(UIControlState)state {
  NSString *imageName = @"Frameworks/StarterKit.framework/StarterKit.bundle/button_background_kickstarter";

  if (state == UIControlStateNormal) imageName = [imageName stringByAppendingString:@"_normal"];
  if (state == UIControlStateHighlighted) imageName = [imageName stringByAppendingString:@"_highlight"];

  UIEdgeInsets capInsets = UIEdgeInsetsMake(10.0, 10.0, 10.0, 10.0);
  UIEdgeInsets rectInsets = UIEdgeInsetsZero;

  return [[[UIImage imageNamed:imageName] resizableImageWithCapInsets:capInsets resizingMode:UIImageResizingModeStretch] imageWithAlignmentRectInsets:rectInsets];
}

- (CGFloat)verticalOffsetForEmptyDataSet:(UIScrollView *)scrollView {
  return 0.0;
}

- (CGFloat)spaceHeightForEmptyDataSet:(UIScrollView *)scrollView {
  return 9.0;
}

#pragma mark - DZNEmptyDataSetDelegate Methods

- (BOOL)emptyDataSetShouldDisplay:(UIScrollView *)scrollView {
  return !self.paginator.isLoading;
}

- (BOOL)emptyDataSetShouldAllowTouch:(UIScrollView *)scrollView {
  return YES;
}

- (BOOL)emptyDataSetShouldAllowScroll:(UIScrollView *)scrollView {
  return YES;
}

- (BOOL)emptyDataSetShouldAnimateImageView:(UIScrollView *)scrollView {
  return NO;
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapView:(UIView *)view {
  [self refreshData];
}

- (void)emptyDataSet:(UIScrollView *)scrollView didTapButton:(UIButton *)button {
  [self refreshData];
}


@end