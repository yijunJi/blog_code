# 简介

Javascript 篇，旨在通过通俗易懂的语言、demo 分享 js 学习过程中的难点、痛点

## 1. This 篇

根据 MDN 的解释，函数的调用方式决定了 this 的值（运行时绑定）。即函数在创建时，this 并未被赋值，  
而是在调用时赋值。

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
// 如果调用getB的是一个函数打印结果会是什么。这里的this指的是什么？提示：函数亦是对象
function func() {}
func.b = 1;
func.getB = getB;
func.getB();
```

现在对于如何实现 bind、apply、call 是否有一些思路了呢？接下来让我们自己实现一个 call 函数。

```js
// call的功能：
Function.prototype.myCall = function(thisArg, ...args) {
  // 此时myBind方法内部的this值为调用myBind的函数，即this = 调用函数
  // 传入参数为null或者undefined时，绑定window对象
  if (thisArg === null || thisArg === undefined) {
    thisArg = window;
  }
  // 将调用函数通过thisArg调用，实现内部this值绑定为thisArg
  const fn = Symbol("fn");
  thisArg[fn] = this;
  const res = thisArg[fn](...args);
  // 避免在传入对象上增加新的属性
  delete thisArg[fn];
  return res;
};
```

bind 函数如何实现呢？bind 返回的是一个绑定的函数

```js
Function.prototype.myBind = function(thisArg, ...args) {
  if (thisArg === null || thisArg === undefined) {
    thisArg = window;
  }
  const func = this;
  const res = function(...arguments) {
    const fn = Symbol();
    thisArg[fn] = func;
    const res = thisArg[fn](...args, ...arguments);
    delete thisArg[fn];
    return res;
  };
  return res;
};
```

::: tip 结语
This 的学习到这里就告一段落了。
:::

## Promise 篇

相信所有接触前端的童鞋，对`Promise`都不会陌生，我们几乎无时无刻不在使用它。那么到底`Promise`到底是什么呢？
首先让我们来了解下`Promise`的实现规范，再通过手写 Promise 帮助大家深入了解`Pormise`。

手写一个符合 Promise/A+规范的代码前，必须知道 Promise/A+规范到底是什么：
::: tip 补充知识点

1. "promise" 是一个具有`then`方法的函数或对象。
2. "thenabel"是一个具有`then`方法的函数或对象。
3. "value"是任意合法的 JavaScript 值包括 undefined、thenable、promise。
4. "exception"是通过`throw`语句抛出的异常值。
5. "reason"是promise reject的原因，即reject参数。

:::
