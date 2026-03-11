import 'package:flutter/material.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:hit_me_up/model/phone_code_list_data.dart';

class SelectPhoneCode extends StatefulWidget {

  const SelectPhoneCode({super.key});

  @override
  _SelectPhoneCodeState createState() => _SelectPhoneCodeState();
}

class _SelectPhoneCodeState extends State<SelectPhoneCode> {
  final List<PhoneCodeListData> _searchResult = [];
  late List<PhoneCodeListData> countryCodeData = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoader(context);
      getPhoneCodeData();
    });
  }

  void getPhoneCodeData() async {
    const url = '$baseUrl/countries-list';
    var result = await callApi('GET', null, url);
    if (!mounted) return;
    hideLoader(context);
    if (result[kDataCode] == 200) {
      setState(() {
        final data = result['data'] as Map<String, dynamic>;
        var rest = data['phonecodesList'] as List;
        countryCodeData = rest
            .map<PhoneCodeListData>((json) => PhoneCodeListData.fromJson(json))
            .toList();
      });
    } else {
      showToast(context, result[kDataMessage]);
    }
  }

  void _sendDataBack(String id, String value) {
    String values = '$id@$value';
    Navigator.pop(context, values);
  }

  Future<void> onSearchTextChanged(String text) async {
    _searchResult.clear();
    if (text.isEmpty) {
      setState(() {});
      return;
    }
    for (var userDetail in countryCodeData) {
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
        centerTitle: true,
        title: const Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Select Your Country Code',
            textAlign: TextAlign.left,
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
          Expanded(
            child: _searchResult.isNotEmpty || controller.text.isNotEmpty
                ? ListView.builder(
              itemCount: _searchResult.length,
              itemBuilder: (context, i) {
                return Card(
                  margin: const EdgeInsets.all(0.0),
                  child: ListTile(
                    onTap: () => _sendDataBack(
                        _searchResult[i].id.toString(),
                        _searchResult[i].phonecode.toString(),),
                    leading: Stack(
                      children: [
                        const SizedBox(
                          height: 45,
                          width: 45,
                          child: CircleAvatar(
                            backgroundColor: buttonParrotColor,
                          ),
                        ),
                        SizedBox(
                          height: 45,
                          width: 45,
                          child: Center(
                            child: Text('+${_searchResult[i].phonecode.toString()}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12,color: Colors.white),),
                          ),
                        ),
                      ],
                    ),
                    title: Text(_searchResult[i].name),
                  ),
                );
              },
            )
                : ListView.builder(
              itemCount: countryCodeData.length,
              itemBuilder: (context, index) {
                return Card(
                  margin: const EdgeInsets.all(0.0),
                  child: ListTile(
                    onTap: () => _sendDataBack(
                        countryCodeData[index].id.toString(),
                        countryCodeData[index].phonecode.toString(),),
                    leading: Stack(
                      children: [
                        const SizedBox(
                          height: 45,
                          width: 45,
                          child: CircleAvatar(
                            backgroundColor: buttonParrotColor,
                          ),
                        ),
                        SizedBox(
                          height: 45,
                          width: 45,
                          child: Center(
                            child: Text('+${countryCodeData[index].phonecode.toString()}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 12,color: Colors.white),),
                          ),
                        ),
                      ],
                    ),
                    title: Text(countryCodeData[index].name,style: const TextStyle(color: Colors.black),),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
