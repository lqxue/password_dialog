import 'dart:async';
import 'package:flutter/material.dart';

///输入密码完成回调 返回值决定是否关闭弹窗
typedef InputPasswordCompleteCallback = FutureOr<bool?> Function(
    String password);

///点击忘记密码 返回值决定是否关闭弹窗
typedef ForgetPasswordClickCallback = FutureOr<bool?> Function();

/*
使用方法
var passwordFutureString = await showPasswordDialog(
      context,
      title: S.current.please_input_pay_pwd,
      forgetPasswordText: S.current.forget_pay_pwd,
      inputPasswordCompleteCallback: (password) async {
        //返回值决定弹窗是否消失
        return await verifyPassword(password);
      },
    );
 */

///支付密码弹窗
///此弹窗里面不要耦合业务
///此弹窗里面不要耦合业务
///此弹窗里面不要耦合业务
Future<String?> showPasswordDialog(
  BuildContext context, {
  String? title,
  String? forgetPasswordText,
  ForgetPasswordClickCallback? forgetPasswordCallback,
  required InputPasswordCompleteCallback? inputPasswordCompleteCallback,
}) {
  return showModalBottomSheet<String>(
    isScrollControlled: true,
    //可滚动 解除showModalBottomSheet最大显示屏幕一半的限制
    enableDrag: true,
    //是否可以 上下拖动并通过向下滑动关闭。
    isDismissible: true,
    //是否当用户点击 scrim 时关闭。
    context: context,
    builder: (context) {
      return PinDialog(
        title: title,
        forgetPasswordText: forgetPasswordText,
        forgetPasswordCallback: forgetPasswordCallback,
        inputPasswordCompleteCallback: inputPasswordCompleteCallback,
      );
    },
    backgroundColor: Colors.transparent,
  );
}

///支付密码弹窗
///实现思路:
///先将inputPasswordList内容展示到方格中
///在通过用户点击的方格判断当前方格内容是否可以添加到密码list中
///最后判断passwordList的长度到达topWidgetTagList的长度直接进行密码整理输出判断
class PinDialog extends StatefulWidget {
  final String? title;
  final String? forgetPasswordText;
  final ForgetPasswordClickCallback? forgetPasswordCallback;
  final InputPasswordCompleteCallback? inputPasswordCompleteCallback;

  const PinDialog(
      {Key? key,
      this.title,
      this.forgetPasswordText,
      this.forgetPasswordCallback,
      this.inputPasswordCompleteCallback})
      : super(key: key);

  @override
  State<PinDialog> createState() => _PinDialogState();
}

class _PinDialogState extends State<PinDialog> {
  ///删除密码
  static const int DELETE_TAG = -1;

  ///空白键
  static const int BLANK_TAG = -2;

  ///存储用户可输入的键盘内容
  ///-1 代表删除 通过判断是-1 显示删除widget
  ///-2 代表空位 通过判断是-2 显示空的SizeBox
  List<int> inputPasswordList = [
    1,
    2,
    3,
    4,
    5,
    6,
    7,
    8,
    9,
    BLANK_TAG,
    0,
    DELETE_TAG
  ];

  ///存储用户输入的密码
  List<int> passwordList = [];

  ///用于展示密码输入显示几个方框
  List<int> topWidgetTagList = [1, 2, 3, 4, 5, 6];

  ///防止异步等待的时候出现乱输入密码的情况
  bool canInputPassword = true;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      bottom: false,
      child: showBody(),
    );
  }

  Widget buildTopTitle() {
    return Row(
      children: [
        Expanded(
          child: Container(
            alignment: Alignment.center,
            margin: EdgeInsets.only(
              left: 48,
              top: 10,
            ),
            child: Text(
              widget.title ?? "",
              maxLines: 1,
              softWrap: true,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xff1b1b1b),
                fontSize: 19,
                height: 1,
              ),
            ),
          ),
        ),
        GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {
            //关闭弹窗
            Navigator.pop(context);
          },
          child: Container(
            width: 48,
            height: 43,
            padding: EdgeInsets.only(
              top: 10,
              bottom: 10,
              left: 20,
              right: 15,
            ),
            child: Icon(Icons.close),
          ),
        ),
      ],
    );
  }

  Widget showBody() {
    return Column(
      children: [
        Expanded(
          child: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(),
          ),
        ),
        Stack(children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(10),
                topRight: Radius.circular(10),
              ),
            ),
            child: Column(
              children: [
                buildTopTitle(),
                SizedBox(
                  height: 13,
                ),
                showPasswordText(),
                SizedBox(
                  height: 10,
                ),
                InkWell(
                  onTap: () async {
                    //将密码回调出去
                    if (widget.forgetPasswordCallback != null) {
                      bool result =
                          await widget.forgetPasswordCallback!() ?? false;
                      if (result) {
                        //关闭弹窗
                        Navigator.pop(context);
                      }
                    }
                  },
                  child: Container(
                    margin: EdgeInsets.only(
                      right: 15,
                    ),
                    alignment: Alignment.centerRight,
                    child: Text(
                      widget.forgetPasswordText ?? "",
                      softWrap: true,
                      textAlign: TextAlign.left,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        color: Color(0xfffc244a),
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                showPasswordList(),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            bottom: 0,
            child: Center(
              child: Visibility(
                  visible: !canInputPassword,
                  child: CircularProgressIndicator()),
            ),
          )
        ]),
      ],
    );
  }

  Widget showPasswordList() {
    return GridView.builder(
      padding: EdgeInsets.only(
        left: 35,
        right: 35,
        bottom: 15,
        top: 15,
      ),
      physics: new NeverScrollableScrollPhysics(),
      //增加
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // 横轴元素个数
        mainAxisSpacing: 0, // 纵轴间距
        crossAxisSpacing: 0, // 横轴间距
        childAspectRatio: 1.5, // 子组件宽高长度比例
      ),
      itemCount: inputPasswordList.length,
      shrinkWrap: true,
      itemBuilder: (context, index) {
        var itemValue = inputPasswordList.elementAt(index);
        return TextButton(
            onPressed: () async {
              //如果不可以输入 直接返回
              if (!canInputPassword) {
                return;
              }
              if (itemValue == DELETE_TAG) {
                if (passwordList.isNotEmpty) {
                  //删除输入的密码
                  setState(() {
                    passwordList.removeLast();
                  });
                }
              } else if (itemValue != BLANK_TAG) {
                if (passwordList.length < topWidgetTagList.length) {
                  //密码输入完毕
                  //校验密码
                  //添加输入的密码
                  setState(() {
                    passwordList.add(itemValue);
                  });
                  if (passwordList.length >= topWidgetTagList.length) {
                    StringBuffer passwordStringBuffer = new StringBuffer();
                    passwordList.forEach((e) {
                      passwordStringBuffer.write(e);
                    });
                    var string = passwordStringBuffer.toString();
                    //将密码回调出去
                    if (widget.inputPasswordCompleteCallback != null) {
                      //不可以输入和删除密码
                      canInputPassword = false;
                      bool result =
                          await widget.inputPasswordCompleteCallback!(string) ??
                              false;
                      //此时可以输入和删除密码
                      canInputPassword = true;
                      setState(() {
                        //清空密码
                        passwordList.clear();
                      });
                      if (result) {
                        //关闭弹窗
                        Navigator.pop(context, string);
                      }
                    }
                  }
                }
              }
            },
            child: getPasswordInputItemWidget(itemValue));
      },
    );
  }

  Widget showPasswordText() {
    return Container(
      margin: EdgeInsets.only(
        left: 25,
        right: 25,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: topWidgetTagList.map((e) {
          var length = passwordList.length;
          return Container(
            alignment: Alignment.center,
            height: 40,
            width: 35,
            decoration: BoxDecoration(
                color: Colors.transparent,
                border: Border.all(color: Color(0xff666666), width: 1),
                borderRadius: BorderRadius.circular(3)),
            child: Icon(
              Icons.circle,
              size: 10,
              color: e <= length ? Colors.black : Colors.transparent,
            ),
          );
        }).toList(),
      ),
    );
  }

  ///显示输入格子内容
  Widget getPasswordInputItemWidget(int itemValue) {
    switch (itemValue) {
      case BLANK_TAG:
        return SizedBox();
      case DELETE_TAG:
        return Icon(
          Icons.backspace,
          color: Colors.black,
        );
      default:
        return Text(
          itemValue.toString(),
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        );
    }
  }
}
