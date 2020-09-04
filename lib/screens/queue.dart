import 'package:flutter/material.dart';
import 'package:frappe_app/app.dart';
import 'package:frappe_app/config/palette.dart';
import 'package:frappe_app/main.dart';
import 'package:frappe_app/utils/backend_service.dart';
import 'package:frappe_app/utils/enums.dart';
import 'package:frappe_app/utils/helpers.dart';
import 'package:frappe_app/widgets/card_list_tile.dart';
import 'package:provider/provider.dart';

class QueueList extends StatefulWidget {
  @override
  _QueueListState createState() => _QueueListState();
}

class _QueueListState extends State<QueueList> {
  BackendService backendService;

  @override
  void initState() {
    super.initState();
    backendService = BackendService(context);
  }

  void _refresh() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    var connectionStatus = Provider.of<ConnectivityStatus>(
      context,
    );

    return Scaffold(
      backgroundColor: Palette.bgColor,
      appBar: AppBar(),
      body: ListView.builder(
        itemCount: queue.length,
        itemBuilder: (context, index) {
          var q = queue.getAt(index);
          return CardListTile(
            leading: IconButton(
              icon: Icon(Icons.cloud_upload),
              onPressed: () async {
                if (connectionStatus == ConnectivityStatus.offline) {
                  showSnackBar('Cant Sync, App is offline', context);
                  return;
                }
                if (q["type"] == "create") {
                  var response =
                      await backendService.saveDocs(q["doctype"], q["data"]);

                  if (response.statusCode == 200) {
                    queue.deleteAt(index);
                    _refresh();
                  }
                } else if (q["type"] == "update") {
                  var response = await backendService.updateDoc(
                    q["doctype"],
                    q["name"],
                    q["data"][0],
                  );

                  if (response.statusCode == 200) {
                    queue.deleteAt(index);
                    _refresh();
                  }
                }
              },
            ),
            title: Text(q['title']),
            subtitle: Text(q['doctype']),
            trailing: Text(q["type"]),
            onTap: () {
              q["qIdx"] = index;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return Router(
                      viewType: ViewType.form,
                      doctype: q['doctype'],
                      queued: true,
                      queuedData: q,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}