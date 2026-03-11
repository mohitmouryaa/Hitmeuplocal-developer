import 'package:flutter/material.dart';
import 'package:hit_me_up/common/common.dart';
import 'package:hit_me_up/common/service_api.dart';
import 'package:hit_me_up/model/country_list_data.dart';

class SelectCountry extends StatefulWidget {
  const SelectCountry({super.key});

  @override
  _SelectCountryState createState() => _SelectCountryState();
}

class _SelectCountryState extends State<SelectCountry> {
  final List<CountryListData> _searchResult = [];
  late List<CountryListData> countryData = [];
  TextEditingController controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showLoader(context);
      getCountriesData();
    });
  }

  void getCountriesData() async {
    const url = '$baseUrl/countries-list';
    var result = await callApi('GET', null, url);
    if (!mounted) return;
    hideLoader(context);
    if (result[kDataCode] == 200) {

        final data = result['data'] as Map<String, dynamic>;
        var rest = data['countries'] as List;
        countryData = rest
            .map<CountryListData>((json) => CountryListData.fromJson(json))
            .toList();
        setState(() {});
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
    for (var userDetail in countryData) {
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
            'Select Your Country',
            textAlign: TextAlign.center,
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
                    itemCount: countryData.length,
                    itemBuilder: (context, index) {
                      return Card(
                        margin: const EdgeInsets.all(0.0),
                        child: ListTile(
                          onTap: () => _sendDataBack(
                              countryData[index].id.toString(),
                              countryData[index].name,),
                          leading: const CircleAvatar(
                            backgroundColor: buttonParrotColor,
                          ),
                          title: Text(countryData[index].name,style: const TextStyle(color: Colors.black),),
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
