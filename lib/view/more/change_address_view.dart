import 'package:flutter/material.dart';
import 'package:food_delivery/common/globs.dart';
import 'package:food_delivery/common/service_call.dart';
import '../../common/color_extension.dart';
import '../../common_widget/round_textfield.dart';

class ChangeAddressView extends StatefulWidget {
  const ChangeAddressView({super.key});

  @override
  State<ChangeAddressView> createState() => _ChangeAddressViewState();
}

class _ChangeAddressViewState extends State<ChangeAddressView> {
  List<Map<String, dynamic>> addresses = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchAddresses();
  }

  void _fetchAddresses() async {
    setState(() => isLoading = true);

    await ServiceCall.get(
      SVKey.svAddresses,
      isToken: true,
      withSuccess: (responseObj) async {
        if (!mounted) return;
        setState(() => isLoading = false);
        if (responseObj['status'] == 'success' && responseObj['data'] != null) {
          addresses = List<Map<String, dynamic>>.from(responseObj['data']);
          setState(() {});
        }
      },
      failure: (err) async {
        if (!mounted) return;
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(err.toString()), backgroundColor: Colors.red),
        );
      },
    );
  }

  void _showAddAddressDialog() {
    final txtLabel = TextEditingController(text: "Home");
    final txtStreet = TextEditingController();
    final txtCity = TextEditingController();
    final txtZipCode = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: const Text("Add New Address"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                RoundTitleTextfield(title: "Label", hintText: "Home/Work/Etc", controller: txtLabel),
                const SizedBox(height: 10),
                RoundTitleTextfield(title: "Street", hintText: "123 Main St", controller: txtStreet),
                const SizedBox(height: 10),
                RoundTitleTextfield(title: "City", hintText: "City Name", controller: txtCity),
                const SizedBox(height: 10),
                RoundTitleTextfield(title: "Zip Code", hintText: "Postal Code", controller: txtZipCode),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (txtStreet.text.trim().isEmpty || txtCity.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Street and City are required")));
                  return;
                }
                
                final payload = {
                  "label": txtLabel.text.trim(),
                  "street": txtStreet.text.trim(),
                  "city": txtCity.text.trim(),
                  "zipCode": txtZipCode.text.trim(),
                  "latitude": 0.0,
                  "longitude": 0.0,
                  "is_default": addresses.isEmpty,
                };

                Globs.showHUD();
                await ServiceCall.post(
                  payload,
                  SVKey.svAddresses,
                  isToken: true,
                  withSuccess: (res) async {
                    Globs.hideHUD();
                    Navigator.pop(ctx);
                    if (!mounted) return;
                    _fetchAddresses();
                  },
                  failure: (err) async {
                    Globs.hideHUD();
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err.toString()), backgroundColor: Colors.red),
                    );
                  },
                );
              },
              child: const Text("Add"),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TColor.white,
      appBar: AppBar(
        backgroundColor: TColor.white,
        scrolledUnderElevation: 0,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: Image.asset("assets/img/btn_back.png", width: 20, height: 20),
        ),
        title: Text(
          "My Addresses",
          style: TextStyle(color: TColor.primaryText, fontSize: 20, fontWeight: FontWeight.w800),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : addresses.isEmpty
              ? Center(
                  child: Text(
                    "No saved addresses",
                    style: TextStyle(color: TColor.secondaryText, fontSize: 16),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: addresses.length,
                  separatorBuilder: (context, index) => const Divider(),
                  itemBuilder: (context, index) {
                    final addr = addresses[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        addr['label']?.toString().toLowerCase() == 'work' ? Icons.work : Icons.home,
                        color: TColor.primary,
                      ),
                      title: Text(
                        addr['label']?.toString() ?? 'Address',
                        style: TextStyle(color: TColor.primaryText, fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        "${addr['street'] ?? ''}, ${addr['city'] ?? ''} - ${addr['zipCode'] ?? ''}",
                        style: TextStyle(color: TColor.secondaryText),
                      ),
                      trailing: addr['is_default'] == true
                          ? Icon(Icons.check_circle, color: TColor.primary)
                          : null,
                      onTap: () {
                        // Return the selected address if it was opened for selection
                        Navigator.pop(context, addr);
                      },
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddAddressDialog,
        backgroundColor: TColor.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
