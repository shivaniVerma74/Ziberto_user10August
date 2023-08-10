import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class New extends StatefulWidget {
  const New({Key? key}) : super(key: key);

  @override
  State<New> createState() => _NewState();
}

class _NewState extends State<New> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.green,
        centerTitle: true,
        title: Text("PNB College Student Table"),
      ),
      backgroundColor: Colors.green,

      body:
          Column(
            children: [

              Container(
                color: Colors.blue,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Name"),
                      Text("Class"),
                      Text("Roll No"),
                      Text("Address"),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: ListView.builder(
                  physics: ClampingScrollPhysics(),
                  shrinkWrap: true,
                  scrollDirection: Axis.vertical,
                  itemCount: 30,
                  prototypeItem: ListTile(
                    title: Text(""),
                  ),
                  itemBuilder: (context, index) {
                    return  Column(
                      children: [
                        Container(
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Container(
                            height: 50,
                            color: Colors.white,

                            child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text("Surendra"),
                                  Text("12th"),
                                  Text("782100"),
                                  Text("MR-10")
                                ],
                              ),
                            ),
                          )
                          ,
                        )
                      ],
                    );
                  },
                ),
              )
            ],
          )



  );
  }
}
