# 简介

React篇，逐行分享react源码的阅读体会。

## ReactDom.render

react项目的开始

```js
function render(
  element: React$Element<any>,
  container: Container,
  callback: ?Function,
) {
  // 校验container是否有效
  invariant(
    isValidContainerLegacy(container),
    'Target container is not a DOM element.',
  );
  // fiber插入rootFiber并渲染
  return legacyRenderSubtreeIntoContainer(
    null,
    element,
    container,
    false,
    callback,
  );
}
```

## legacyRenderSubtreeIntoContainer

函数如其名，通过将react元素渲染后插入container

```js
function legacyRenderSubtreeIntoContainer(
  parentComponent: ?React$Component<any, any>,
  children: ReactNodeList,
  container: Container,
  forceHydrate: boolean,
  callback: ?Function,
) {
  // 首次挂载的时候container不存在该属性，挂在后会讲container
  let root = container._reactRootContainer;
  let fiberRoot: FiberRoot;
  // 根据container 元素创建rootFiber
  if (!root) {
    // Initial mount，根据container创建rootFiber
    root = container._reactRootContainer = legacyCreateRootFromDOMContainer(
      container,
      forceHydrate,
    );
    fiberRoot = root;
    if (typeof callback === 'function') {
      const originalCallback = callback;
      callback = function() {
        const instance = getPublicRootInstance(fiberRoot);
        originalCallback.call(instance);
      };
    }
    // Initial mount should not be batched.
    unbatchedUpdates(() => {
      updateContainer(children, fiberRoot, parentComponent, callback);
    });
  } else {
    fiberRoot = root;
    if (typeof callback === 'function') {
      const originalCallback = callback;
      callback = function() {
        const instance = getPublicRootInstance(fiberRoot);
        originalCallback.call(instance);
      };
    }
    // Update
    updateContainer(children, fiberRoot, parentComponent, callback);
  }
  return getPublicRootInstance(fiberRoot);
}
```

## updateContainer

更新container元素内部的内容

Reconciler阶段

```js
export function updateContainer(
  element: ReactNodeList,
  container: OpaqueRoot,
  parentComponent: ?React$Component<any, any>,
  callback: ?Function,
): Lane {
  // FiberRoot
  const current = container.current;
  /** 
   * 获取更新时间，如果是react内部，使用真实时间
   * 浏览器事件期间触发的更新，使用事件触发时间时间
   * react执行产生的首次更新，使用当前时间
  */
  const eventTime = requestEventTime();
  /** 
   * 获取优先级
   * 过渡transition优先级
   * 本轮更新优先级
   * 事件优先级
  */
  const lane = requestUpdateLane(current);

  if (enableSchedulingProfiler) {
    markRenderScheduled(lane);
  }
  // 获取当前节点和子节点的上下文
  const context = getContextForSubtree(parentComponent);
  if (container.context === null) {
    container.context = context;
  } else {
    container.pendingContext = context;
  }
  // 根据更新时间以及优先级创建更新对象
  const update = createUpdate(eventTime, lane);
  // Caution: React DevTools currently depends on this property
  // being called "element".
  update.payload = {element};

  callback = callback === undefined ? null : callback;
  if (callback !== null) {
    update.callback = callback;
  }
  // 插入更新
  enqueueUpdate(current, update, lane);
  const root = scheduleUpdateOnFiber(current, lane, eventTime);
  if (root !== null) {
    entangleTransitions(root, current, lane);
  }

  return lane;
}
```
