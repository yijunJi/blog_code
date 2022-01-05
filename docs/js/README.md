# 简介

Javascript 篇，分享自己在 js 使用过程中遇到过的迷惑点。

## This

根据 MDN 的解释，函数的调用方式决定了 this 的值（运行时绑定）。即函数在创建时，this 并未被赋值，而是在调用时赋值。
::: 基本概念
bind 入参的含义([mdn](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Function/bind))：

```js
// 该函数创建时，this不指定任何值，调用时依据调用调用对象，进行赋值。
function getB() {
  return this.b;
}

// 此时打印结果为undefined，因为此时调用getB的对象为window对象，this === window
getB();

// 此时打印结果为1，因为此时调用getB的对象为obj，this === obj
const obj = {
  b: 1,
};
obj.getB = getB;
obj.getB();
// 此时打印结果为1，因为此时调用gebB方法的对象为函数func，因此打印func.b，即1
function func() {}
func.b = 1;
func.getB = getB;
func.getB();
```

```js
// 将基本数据类型转为引用数据类型
const changePrimaryToObject = (val) => {
  const type = typeof val;
  switch (type) {
    case "string":
      return new String(val);
    case "number":
      return new Number(val);
    case "boolean":
      return new Boolean(val);
    default:
      return val;
  }
};
// bind的实现原理
Function.prototype.myBind = function(that, ...args) {
  if (that === null) {
    that === undefined;
  }
  that = changePrimaryToObject(that);
  return function(...nextArg) {
    if (that === undefined) {
      return this(...args);
    }
    const fn = Symbol("fn");
    that[fn] = this;
    const res = that[fn](...args, ...nextArg);
    delete that[fn];
    return res;
  };
};
// call的实现原理
Function.prototype.myCall = function(that, ...args) {
  if (that === null) {
    that === undefined;
  }
  that = changePrimaryToObject(that);
  if (that === undefined) {
    return this(...args);
  }
  const fn = Symbol("fn");
  that[fn] = this;
  const res = that[fn](...args);
  delete that[fn];
  return res;
};
```

## Promise

学习 Promise 从`Promise A+`[规范](https://promisesaplus.com/)开始

### 规范

1. `promise` 是一个具有`then`方法的函数或对象。
2. `thenabel`是一个具有`then`方法的函数或对象。
3. `value`是任意合法的 JavaScript 值包括 undefined、thenable、promise。
4. `exception`是通过`throw`语句抛出的异常值。
5. `reason`是 promise reject 的原因，即 reject 参数。

### 要求

promise 仅有 pending、fulfilled、rejected 三种状态。

1. pending 状态可以转变为 fulfilled 或者 rejected 状态。
2. 一旦变为 fullfilled 状态后，这状态无法在发生改变，且必须存在一个不会发生变化的 value 值。
3. 一旦转变为 rejected 状态后，同样该状态无法发生改变，且必须存在一个不会发生变化的 reason 值。

### then 方法

promise 必须提供一个 then 方法，该方法接收当前的 value 或者 reason 值。
promise 的 then 方法必须接受两个参数：

```js
promise.then(onFulfilled, onRejected);
```

#### then 方法参数要求

1. **onFulfilled**或者**onRejected**都是可选的，且如果它们不是函数，则需要被忽略，忽略指的是原样返回。
2. **onFulfilled**必须在**promise**处于 fulfilled 状态后，才能调用，并且将**promise**的 value
   值作为第一个参数传入，且该函数仅能调用一次。
3. **onRejected**必须在**promise**处于 rejected 状态后，才能调用，并且将**promise**的 reason
   值作为第一个参数传入。且该函数仅能调用一次。
4. **onFulfilled**和**onRejected**都必须是异步执行。
5. **then**在同一个 promise 中，可以调用多次，且**promise**处于 fulfilled 状态时，
   **onFulfilled**必须按照**then**的调用顺序依次执行，即按照链式调用的顺序执行。同理**onRejected**。
6. **then**方法必须返回一个 promise。

### Promise Resolution 步骤

`promise resolution`步骤指的是输出 promise 的 value，可以表示为`[[Resolve]](promise, x)`，
如果 x 具有 then 方法，那么它会假设 x 为一个 Promise，将其作为 state 传入 promise，否则会直接 resolve x。
这样可以使得所有遵循 Promise A+规范的 promise 互相调用。

运行`[[Resolve]](promise, x)`，执行如下步骤:

1. 如果 promise 和 x 为同一个对象，reject `promise`并抛出`TypeError`作为 reason。

2. 如果 x 是一个`promise`，接收 x 的 value。
   1. 如果 x 处于`Pending`状态，`promise`必须等待`x`的状态变为`fulfilled`或者`rejected`。
   2. 如果 x 处于`fulfilled`或者`rejected`，返回相同的状态值。
3. 如果 x 是一个对象或者函数。
   1. `let x = x.then`，如果这一步检测到异常，`reject`并将捕获的错误作为`reason`。
   2. 如果`then`是一个函数，将`x`作为它的`this`，第一个参数为`resolvePromise`，第二个参数为`rejectPromise`
      1. `resolvePromise`调用时，传入 y 作为值，即执行`[[Resolve]](promise, y)`。
      2. `rejectPromise`调用时，使用 reason `r` reject promise，即执行`[[Resolve]](promise, y)`。
      3. 如果`resolvePromise`和`rejectPromise`同时调用，先执行完成的优先级更高，后续的调用都被忽略。
      4. 如果 then 方法抛出错误，如果`resolvePromise`和`rejectPromise`已经调用完毕，则忽略错误，
         否则使用错误作为 reject `promise`的 reason。
   3. 如果`then`方法不是函数，直接使用 x 作为 value，fullfil `promise`。
4. 如果x不是函数或者对象，直接使用 x 作为 value，fullfil `promise`。

::: tip
`onFulfilled`和`onRejected`都是异步的，可以通过宏任务例如`setTimeout`或者`setImmediate`，
微任务例如`MutationObserver`或者`process.nextTick`实现。
:::

```js
// 代码实现
```
