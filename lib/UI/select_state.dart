
import 'package:flutter/material.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:hit_me_up/model/state_data.dart';

class SelectState extends StatefulWidget {
  final countryId;

  const SelectState({super.key,this.countryId});

  @override
  _SelectStateState createState() => _SelectStateState();

}

class _SelectStateState extends State<SelectState> {
  final List<StateListData> _searchResult = [];

  List<StateListData> stateList=[];
  TextEditingController controller = TextEditingController();

  // Get json result and convert it to model. Then add

  void getCountriesData() async {
    final url = '$baseUrl/states-list/${widget.countryId}';
    var result = await callApi('GET', null, url);
    hideLoader(context);
    if (result[kDataCode] == 200) {
      setState(() {
        var rest = result['data'] as List;
        stateList = rest
            .map<StateListData>((json) => StateListData.fromJson(json))
            .toList();
      });
    } else {
      showToast(context, result[kDataMessage]);
    }
  }

  @override
  void initState() {
    super.initState();
    showLoader(context);
    getCountriesData();
  }

  void _sendDataBack(String id, String value) {
    String values = '$id@$value';
    Navigator.pop(context, values);
  }

  onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }

    for (var userDetail in stateList) {
      if (userDetail.name.toUpperCase().contains(text.toUpperCase())) {
        _searchResult.add(userDetail);
      }
    }
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: buttonParrotColor,
        automaticallyImplyLeading: false,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Select Your State',
            style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
                fontStyle: FontStyle.normal,),
          ),
        ),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        elevation: 0.0,
      ),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Card(
              elevation: 8,
              child: ListTile(
                leading: const Icon(Icons.search),
                title: TextField(
                  controller: controller,
                  decoration: const InputDecoration(
                      hintText: 'Search', border: InputBorder.none,),
                  onChanged: onSearchTextChanged,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.cancel),
                  onPressed: () {
                    controller.clear();
                    onSearchTextChanged('');
                  },
                ),
              ),
            ),
          ),
          stateList.isNotEmpty
            ? Expanded(
                child: _searchResult.isNotEmpty || controller.text.isNotEmpty
                    ? ListView.builder(
                        itemCount: _searchResult.length,
                        itemBuilder: (context, i) {
                          return Card(
                            margin: const EdgeInsets.all(0.0),
                            child: ListTile(
                              onTap: () => _sendDataBack(
                                  _searchResult[i].id.toString(),
                                  _searchResult[i].name,),
                              leading: const CircleAvatar(
                                backgroundColor: buttonParrotColor,
                              ),
                              title: Text(_searchResult[i].name),
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        itemCount: stateList.length,
                        itemBuilder: (context, index) {
                          return Card(
                            margin: const EdgeInsets.all(0.0),
                            child: ListTile(
                              onTap: () => _sendDataBack(
                                  stateList[index].id.toString(),
                                  stateList[index].name,),
                              leading: const CircleAvatar(
                                backgroundColor: buttonParrotColor,
                              ),
                              title: Text(stateList[index].name),
                            ),
                          );
                        },
                      ),
              )
            : noDataFound('No State List Found!'),
        ],
      ),
    );
  }
}
