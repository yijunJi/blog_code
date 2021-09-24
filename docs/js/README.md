# 简介

Javascript篇，旨在通过通俗易懂的语言、demo分享js学习过程中的难点、痛点

## 1. This篇

根据MDN的解释，函数的调用方式决定了this的值（运行时绑定）。即函数在创建时，this并未被赋值，  
而是在调用时赋值。

``` js
// 该函数创建时，this不指定任何值，调用时依据调用调用对象，进行赋值。
function getB() {
  return this.b
}

// 此时打印结果为undefined，因为此时调用getB的对象为window对象，this === window
getB()

// 此时打印结果为1，因为此时调用getB的对象为obj，this === obj
const obj = {
  b: 1,
}
obj.getB = getB
obj.getB() 
// 如果调用getB的是一个函数打印结果会是什么。这里的this指的是什么？提示：函数亦是对象
function func() {}
func.b = 1
func.getB = getB
func.getB()
```

现在对于如何实现bind、apply、call是否有一些思路了呢？接下来让我们自己实现一个call函数。

```js
// call的功能：
Function.prototype.myCall = function(thisArg, ...args) {
  // 此时myBind方法内部的this值为调用myBind的函数，即this = 调用函数
  // 传入参数为null或者undefined时，绑定window对象
  if (thisArg === null || thisArg === undefined) {
    thisArg = window
  }
  // 将调用函数通过thisArg调用，实现内部this值绑定为thisArg
  const fn = Symbol('fn')
  thisArg[fn] = this
  const res = thisArg[fn](...args)
  // 避免在传入对象上增加新的属性
  delete thisArg[fn]
  return res
}
```

bind函数如何实现呢？bind返回的是一个绑定的函数

```js
Function.prototype.myBind = function(thisArg, ...args) {
  if (thisArg === null || thisArg === undefined) {
    thisArg = window
  }
  const func = this
  const res = function(...arguments) {
    const fn = Symbol()
    thisArg[fn] = func
    const res = thisArg[fn](...args, ...arguments)
    delete thisArg[fn]
    return res
  }
  return res
}
```
