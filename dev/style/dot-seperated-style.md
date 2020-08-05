# Use dot-sperated, or NOT

采用点号分割，确实带来了很多问题：

1. 无法兼容shell

但是如果用户场景是bash，这问题不大。

采用bash completion进行提示，设计超级命令的做法，其实是不错的。

譬如 `str.trim` 变成 `str trim`，好处是：

1. 节省函数空间
2. 减少函数命名占用

这两个都是伪需求，
1. 我发现bash内能定义100000个函数以上 `for i in `seq 100000`; do eval "w$i() { echo $i; }"; done`
2. 命名冲突，只要模块和函数名称定义好，问题不大。

这样写还有一个好处，就是可以当作cookbook使用：

```bash
type str.trim
```

可以马上查阅使用方法
