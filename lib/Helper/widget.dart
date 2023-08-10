 import 'package:eshop_multivendor/Helper/String.dart';
import 'package:eshop_multivendor/Model/ClearCartModel.dart';
import 'package:eshop_multivendor/api/globalApi/api.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

showToast(msg){
   Fluttertoast.showToast(
       msg: "$msg",
       toastLength: Toast.LENGTH_SHORT,
       gravity: ToastGravity.SNACKBAR,
       timeInSecForIosWeb: 1,
       backgroundColor: Colors.black,
       textColor: Colors.white,
       fontSize: 12.0
   );
 }


 clearCart(context , msg){
  return showDialog(context: context, builder: (context){
    return AlertDialog(
      title: Text("Items", style: TextStyle(color: Colors.red),),
      content: Text(msg),
      actions: [
        TextButton(onPressed: () async {
          ClearCartModel? model = await clearCartApi(CUR_USERID);
          if(model!.error == false){
            Navigator.pop(context , true);
          }else{
            Navigator.pop(context , false);
          }
        }, child: Text("Yes")),
        TextButton(onPressed: (){
          Navigator.pop(context , false);
        }, child: Text("No")),
      ],
    );
  });
 }