import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:honeychain/blocs/session/bloc.dart';

class HistoryScreen extends StatefulWidget {
  int index;

  HistoryScreen(this.index);
  @override
  _HistoryScreenState createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  UserSessionBloc userSessionBloc;

  @override
  void initState() {
    userSessionBloc = BlocProvider.of<UserSessionBloc>(context);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text("Honey Chain"),
        ),body: BlocBuilder(

          builder: (context, state)  {
            if(state is HistoryLoaded){
             return  ListView.builder(itemBuilder: (context, index) => {

              },
                itemCount: ,)
            }

            if(state is HistoryLoading){
              return Center(child: CircularProgressIndicator(),);
            }

            if(state is HistoryError){
              return Center(child: Column(crossAxisAlignment: CrossAxisAlignment.center,mainAxisAlignment: MainAxisAlignment.center,children: <Widget>[
                Icon(Icons.warning,color: Colors.red,size: MediaQuery.of(context).size.,)
              ],),);
            }
          },
        ),
    );
  }
}
