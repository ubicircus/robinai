import 'package:flutter/material.dart';
import 'package:robin_ai/presentation/config/context/model/context_model.dart';

class ContextOptionsWidget extends StatelessWidget {
  final Future<List<ContextModel>> futureOptions;

  ContextOptionsWidget({Key? key, required this.futureOptions})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<ContextModel>>(
      future: futureOptions,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          List<ContextModel> prompts = snapshot.data!;
          return SizedBox(
            height: 100,
            child: Column(
              children: [
                SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: prompts.length,
                    itemBuilder: (context, index) {
                      ContextModel prompt = prompts[index];
                      return Container(
                        margin: EdgeInsets.symmetric(horizontal: 8.0),
                        padding: EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          border:
                              Border.all(color: Colors.grey[400]!, width: 1),
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text(
                              prompt.name,
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            SizedBox(height: 5),
                            Text(
                              prompt.text,
                              style: TextStyle(fontWeight: FontWeight.normal),
                              overflow: TextOverflow.fade,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
                SizedBox(height: 20),
              ],
            ),
          );
        }
      },
    );
  }
}
