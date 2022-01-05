# 简介

<<<<<<< Updated upstream
**Javascript** 篇

## This 篇
=======
Javascript 篇，分享自己在js使用过程中遇到过的迷惑点。

## This
>>>>>>> Stashed changes

根据 MDN 的解释，函数的调用方式决定了 this 的值（运行时绑定）。即函数在创建时，this 并未被赋值，而是在调用时赋值。
::: tip
bind 入参的含义([mdn](https://developer.mozilla.org/zh-CN/docs/Web/JavaScript/Reference/Global_Objects/Function/bind))：

<<<<<<< Updated upstream
1. that：调用绑定函数时作为 this 参数传递给目标函数的值。 如果使用 new 运算符构造绑定函数，则忽略该值。当使用 bind 在 setTimeout 中创建一个函数（作为回调提供）时，作为 thisArg 传递的任何原始值都将转换为 object。如果 bind 函数的参数列表为空，或者 thisArg 是 null 或 undefined，执行作用域的 this 将被视为新函数的 thisArg。
   :::
=======
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

现在对于如何实现 bind、apply、call 是否有一些思路了呢？接下来让我们自己实现一个 call 函数。
>>>>>>> Stashed changes

```js
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

<<<<<<< Updated upstream
<!-- ## Promise 篇
=======
::: tip 结语
This 的学习到这里就告一段落了。
:::

## Promise

相信所有接触前端的童鞋，对`Promise`都不会陌生，我们几乎无时无刻不在使用它。那么到底`Promise`到底是什么呢？
首先让我们来了解下`Promise`的实现规范，再通过手写 Promise 帮助大家深入了解`Pormise`。
>>>>>>> Stashed changes

手写一个符合 Promise/A+规范的代码前([官网规范链接](https://promisesaplus.com/#notes))，必须知道 Promise/A+规范到底是什么：
::: tip 前置知识点

1. "promise" 是一个具有`then`方法的函数或对象。
2. "thenabel"是一个具有`then`方法的函数或对象。
3. "value"是任意合法的 JavaScript 值包括 undefined、thenable、promise。
4. "exception"是通过`throw`语句抛出的异常值。
5. "reason"是 promise reject 的原因，即 reject 参数。

:::

::: tip 要求
promise 仅有 pending、fulfilled、rejected 三种状态。

1. pending 状态可以转变为 fulfilled 或者 rejected 状态。
2. 一旦变为 fullfilled 状态后，这状态无法在发生改变，且必须存在一个不会发生变化的 value 值。
3. 一旦转变为 rejected 状态后，同样该状态无法发生改变，且必须存在一个不会发生变化的 reason 值。

promise 必须提供一个 then 方法，该方法接收当前的 value 或者 reason 值。
promise 的 then 方法必须接受两个参数：

```js
promise.then(onFulfilled, onRejected);
```

::: tip 参数要求

1. **onFulfilled**或者**onRejected**都是可选的，且如果它们不是函数，则需要被忽略，忽略指的是原样返回。
2. **onFulfilled**必须在**promise**处于 fulfilled 状态后，才能调用，并且将*\*\*promise*的 value 值作为第一个参数传入，且该函数仅能调用一次。
3. **onRejected**必须在**promise**处于 rejected 状态后，才能调用，并且将*\*\*promise*的 reason 值作为第一个参数传入。且该函数仅能调用一次。
4. **onFulfilled**和**onRejected**都必须是异步执行。
5. **then**在同一个 promise 中，可以调用多次，且**promise**处于 fulfilled 状态时，**onFulfilled**必须按照**then**的调用顺序依次执行，即按照链式调用的顺序执行。同理**onRejected**。
6. **then**方法必须返回一个 promise。

   :::

::: -->
